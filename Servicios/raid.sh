#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "RAID: Error en el paso de parametros a la configuracion del raid"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $2 existe
if [ ! -f $1 ]
then
    echo "RAID: El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

#Leemos el fichero pasado por parametros
IFS_antiguo=$IFS
IFS=$'\n' 
linea=0
#Extraemos los datos necesarios para configurar el raid
for comand in `cat $1`; do
    if [ $linea == 0 ]
    then
        #Nombre del dispositivo
		DESTINO=$comand
    elif [ $linea == 1 ]
    then
        #Nivel de raid
		NIVEL=$comand
    elif [ $linea == 2 ]
    then
        #Dispositivos
		DISPOSITIVOS=$comand
    fi
    let linea+=1
done
IFS=' '
read -a NUM_DISP <<< "$DISPOSITIVOS"
IFS=$IFS_antiguo

#Instalo la herramienta mdadm
echo "RAID: Preparando el RAID $DESTINO con nivel $NIVEL"
echo "RAID: Instalando mdadm..."
#Instalamos mdadm sin que necesite input de parte del usuario
export DEBIAN_FRONTEND=noninteractive
apt-get -y install mdadm --no-install-recommends > /dev/null 2>&1 && echo "RAID: mdadm instalado" 
#Creamos el raid finalmente
#Montar el RAID y guardar la configuración
echo "RAID: Creando raid..."
#Como daba algun tipo de error de formato en la peticion he tenido que hacer el echo y pasarle la salida a mdadm
mdadm --create $DESTINO -R --name=$DESTINO --level=$NIVEL --metadata=0.90 --raid-devices=${#NUM_DISP[*]} $DISPOSITIVOS > /dev/null && echo "RAID: raid creado" || echo "RAID: Fallo al crear el RAID"