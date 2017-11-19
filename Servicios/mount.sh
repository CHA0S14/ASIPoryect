#!/bin/bash
#Fichero de montaje

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "Error en el paso de parametros a la configuracion del montaje"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $2 existe
if [ ! -f $1 ]
then
    echo "El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

#Extraemos los datos necesarios para configurar el montaje
linea=0
for comand in $(cat $1); do
	if [ $linea = 0 ] 
	then
		#Nombre Dispositivo
		NOMBRE_DEL_DISPOSITIVO=$comand
	elif [ $linea = 1 ] 
	then
		#Punto de Montaje
		PUNTO_DE_MONTAJE=$comand
	fi
	let linea+=1
done

#Comprobamos si el dispositivo ya esta montado
#Si no esta montado, lo montamos
montaje="$NOMBRE_DEL_DISPOSITIVO $PUNTO_DE_MONTAJE auto defaults,auto,rw 0 0";
if [ grep -q "$NOMBRE_DEL_DISPOSITIVO" /etc/fstab ]
then
	echo "El dispositivo ya esta montado en fstab"
elif [ ! grep -q "$NOMBRE_DEL_DISPOSITIVO" /etc/fstab ]
	'mount $NOMBRE_DEL_DISPOSITIVO $PUNTO_DE_MONTAJE' && echo "#Dispositivo: $NOMBRE_DEL_DISPOSITIVO" >> /etc/fstab && echo "$montaje" >> /etc/fstab && echo "Montaje realizado correctamente"
then
else
	echo "Error al montar el dispositivo"
fi
