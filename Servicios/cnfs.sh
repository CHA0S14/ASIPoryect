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

function montar {
    echo "CNFS: Ejecutando montado de $1:$2 $3"
    if mount $1":"$2 $3 > /dev/null
    then
        #Preparamos /etc/fstab para que se monten al inicio del equipo
        echo "$1:$2 $3 nfs defaults,auto 0 0" >> /etc/fstab
        return 0
    else 
        return 1    
    fi
}

#Leemos el fichero pasado por parametros
IFS_antiguo=$IFS
IFS=$'\n' 
linea=0
#Extraemos los datos necesarios para configurar el raid
for comand in `cat $1`; do
    #Nombre del dispositivo
	directorios[$linea]=$comand
    let linea+=1
done

#Comprobamos que el fichero tenia lineas
if [ $linea -lt 1 ]
then
    echo "CNFS: Error en el fichero de configuracion del servicio, esta vacio"
    exit 1
fi

#Actualizamos los paquetes
apt-get -y update > /dev/null && echo "CNFS: Actualizamos los paquetes"
#Evitamos que pidan cosas por la linea de comando
export DEBIAN_FRONTEND=noninteractive
echo "CNFS: Instalamos nfs-common"
apt-get -y install nfs-common --no-install-recommends > /dev/null
echo "CNFS: Configuramos el cliente nfs"
salida=0
for parametros in ${directorios[*]}
do  
    if [ `echo "$parametros" | wc -w` -ne 3 ]
    then
        echo "CNFS: No hay suficientes parametros en la linea de $parametros"
        salida=1
    else
        IFS=" "
        read -a aux <<< "$parametros"
        if ping -c 1 ${aux[0]} &> /dev/null
        then
            montar $parametros
            if [ $? -ne 0 ]
            then 
                salida=1
            fi
        else
            echo "CNFS: el host no es valido en la linea de $parametros"
            salida=1
        fi
        IFS=$'\n'
    fi
done

IFS=$oldIFS
# Se sale con 0 si no hay errores y 1 si falta algun parametro en una linea
exit $salida