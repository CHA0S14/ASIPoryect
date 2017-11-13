#!/bin/bash

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Uso: $0 <fichero_configuracion>"
	exit 1
fi

#Comprobar ficheros
ficheros="configurar_mount.sh"

for fich in $ficheros; do
	if [ ! -f $fich ]
	then
		echo "El fichero "$fich" no esta disponible."
		exit 1
	fi
done