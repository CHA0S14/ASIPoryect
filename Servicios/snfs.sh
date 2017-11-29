#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "SNFS: Error en el paso de parametros a la configuracion del servidor nfs"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $1 existe
if [ ! -f $1 ]
then
    echo "SNFS: El fichero $1 no esta disponible. Abortando ejecución."
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
    echo "SNFS: Error en el fichero de configuracion del servicio, esta vacio"
    exit 1
fi
IFS=$oldIFS


#Instalamos los paquetes necesarios
apt-get -y update > /dev/null && echo "SNFS: Ejecutamos el update de apt-get"
#Evitamos que pidan cosas por la linea de comando
export DEBIAN_FRONTEND=noninteractive
echo "SNFS: Instalando nfs-common"
apt-get -y install nfs-common --no-install-recommends > /dev/null
echo "SNFS: Instalando nfs-kernel-server"
apt-get -y install nfs-kernel-server --no-install-recommends > /dev/null


echo "SNFS: Configurar servidor nfs"
#salida del programa 0 si va bien 1 si va mal
for DIRECTORIO in ${DIRECTORIOS[*]}
do
    #Aniadimos al final del fichero las lineas para los directorios
    #El solo avisa de si no exite un fichero
    echo "$DIRECTORIO *(rw,sync)" >> /etc/exports
done
/etc/init.d/nfs-kernel-server restart
echo "SNFS: Finalizada configuración del servidor nfs"