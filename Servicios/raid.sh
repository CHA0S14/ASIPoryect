#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Error en el paso de parametros a la configuracion del raid"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $2 existe
if [ ! -f $1 ]
then
    echo "El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

#Leemos el fichero pasado por parametros
IFS_antiguo = $IFS
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
IFS=$IFS_antiguo

#Instalo la herramienta mdadm
echo "Preparando el RAID $NOMBRE con nivel $NIVEL"
echo "Instalando mdadm..."
