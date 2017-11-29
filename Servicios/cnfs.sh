#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "CNFS: Error en el paso de parametros a la configuracion del cliente nfs"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $1 existe
if [ ! -f $1 ]
then
    echo "CNFS: El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

#Leemos el fichero pasado por parametros
IFS_antiguo=$IFS
IFS=$'\n' 
linea=0
#Extraemos los datos necesarios para configurar el raid
for comand in `cat $1`; do
    #Nombre del dispositivo
	DIRECTORIOS[$linea]=$comand
    let linea+=1
done

#Comprobamos que el fichero tenia lineas
if [ $linea -lt 1 ]
then
    echo "CNFS: Error en el fichero de configuracion del servicio, esta vacio"
    exit 1
fi
IFS=$oldIFS

#Actualizamos los paquetes
apt-get -y update > /dev/null && echo "CNFS: Actualizamos los paquetes"
#Evitamos que pidan cosas por la linea de comando
export DEBIAN_FRONTEND=noninteractive
echo "CNFS: Instalamos nfs-common"
apt-get -y install nfs-common --no-install-recommends > /dev/null
echo "CNFS: Configuramos el cliente nfs"
for PARAMETROS in ${DIRECTORIOS[*]}
do
	echo $PARAMETROS
    #Montamos la carpeta de PARAMETROS[0] en PARAMETROS[1]
	mount $PARAMETROS > /dev/null 2>&1
    #Preparamos /etc/fstab para que se monten al inicio del equipo
    echo "$PARAMETROS nfs defaults,auto 0 0" >> /etc/fstab
done

IFS=$oldIFS