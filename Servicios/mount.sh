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

echo "-------------------------------------"
echo "########## INICIO DE MOUNT ##########"
echo "-------------------------------------"
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

if [ -z "$NOMBRE_DEL_DISPOSITIVO" ]
then
    echo "MOUNT: Error! Falta uno de los parametros"
    exit 1
fi

if [ -z "$PUNTO_DE_MONTAJE" ]
then
    echo "MOUNT: Error! Falta uno de los parametros"
    exit 1
fi


#Comprobamos si el dispositivo ya esta montado
#Si no esta montado, lo montamos
mkdir --parents $PUNTO_DE_MONTAJE > /dev/null
echo "MOUNT: Intentando montar el dispositivo $NOMBRE_DEL_DISPOSITIVO en $PUNTO_DE_MONTAJE"
montaje="$NOMBRE_DEL_DISPOSITIVO     $PUNTO_DE_MONTAJE   auto    auto    0   0";

grep -q "$NOMBRE_DEL_DISPOSITIVO" /etc/fstab && echo "MOUNT: El dispositivo $NOMBRE_DEL_DISPOSITIVO ya esta en fstab" || (echo "$montaje" >> /etc/fstab && echo "MOUNT: Configuración del montaje de $NOMBRE_DEL_DISPOSITIVO completada") || echo "MOUNT: Error al montar el dispositivo $NOMBRE_DEL_DISPOSITIVO"
mount -a > /dev/null
echo "----------------------------------"
echo "########## FIN DE MOUNT ##########"
echo "----------------------------------"
