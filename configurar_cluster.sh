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
	if [ ! -f "./Servicios/"$fich ]
	then
		echo "El fichero ./conf/"$fich" no esta disponible. Abortando ejecución."
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
}

#Comprobamos que existe el fichero de configuracion
if [ ! -f $1 ]
then
	echo "No existe el fichero $1"
	exit 1
fi
#Obtenemos las lineas que no sean blancos o comentarios
#Source http://es.ccm.net/faq/2136-bash-mostrar-un-archivo-sin-lineas-de-comentarios
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

