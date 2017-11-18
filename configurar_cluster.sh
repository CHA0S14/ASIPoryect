#!/bin/bash

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Uso: $0 <fichero_configuracion>"
	exit 1
fi

#Comprobacion de que estan todos los ficheros
scripts="montaje.sh raid.sh lvm.sh snis.sh cnis.sh snfs.sh cnfs.sh backup.sh"

for fich in $scripts; do
	if [ ! -f "./Servicios/$fich" ]
	then
		echo "El fichero ./conf/$fich no esta disponible. Abortando ejecución."
		exit 1
	fi
done

function tratarComando {
	#Comprobacion argumentos correctos
	if [ $# -ne 4 ]
	then
		echo "Error en el mandato de la linea $1"
		exit 1
	fi

	#####################################################
	#	Aqui tenemos en los parametros los datos:		#
	#		$1 linea del fichero de config				#
	#		$2 ip de la maquina del destino				#
	#		$3 servicio a configurar					#
	#		$4 fichero de configuracion del servicio	#
	#####################################################
	echo "Comienzo de la configuracion de $4 con el servicio $3 en la maquina '$2'"
	case $3 in
	"raid" )
		SCRIPT="./Servicios/raid.sh"
		;;
	*)
		echo "Error en el servicio indicado ($SERVICIO). Abortando..."
		exit 1
		;;
	esac

	echo "Fichero de perfil de configuración: $1"
	echo 'Preparando archivos...'
	#Creamos la carpeta del proyecto
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$2 'mkdir ~/ASI2014/' > /dev/null 2>&1 || { 
		echo "No es posible establecer conexion con la máquina. Abortando..."
		exit 1
		}
	#Copiamos los archivos necesarios
	scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $4 root@$2:~/ASI2014/config.cfg > /dev/null 2>&1
	scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $SCRIPT root@$2:~/ASI2014/servicio > /dev/null 2>&1
	#Ejecutamos el servicio
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$2 "chmod +x ~/ASI2014/servicio" > /dev/null 2>&1
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$2 "~/ASI2014/servicio ~/ASI2014/config.cfg" 2>&1
	#Eliminamos los ficheros de configuración temporales utilizados
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$2 'rm -r ~/ASI2014/' > /dev/null 2>&1
}

#Comprobamos que existe el fichero de configuracion
if [ ! -f $1 ]
then
	echo "No existe el fichero $1"
	exit 1
fi
#Obtenemos las lineas que no sean blancos o comentarios
comands=`grep -E -v '^(#|$)' $1`
#Con esto hacemos que en el siguiente for la linea divisoria entre el valor de comand 
#en cada vuelta sea el salto de linea
IFS=$'\n' 
linea=1
for comand in $comands; do
	#Hacemos que el espacio separe las variables
	IFS=$' '
	tratarComando $linea $comand
	let linea+=1
done

