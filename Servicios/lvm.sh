#!/bin/bash

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "LVM: Error en el paso de parametros a la configuracion del raid"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $1 existe
if [ ! -f $1 ]
then
    echo "LVM: El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

#Leemos el fichero pasado por parametros
IFS_antiguo=$IFS
IFS=$'\n' 
linea=0
#Extraemos los datos necesarios para configurar el lvm
for comand in `cat $1`; do
    if [ $linea == 0 ]
    then
        #Nombre del grupo
		NOMBRE=$comand
    elif [ $linea == 1 ]
    then
        #Dispositivos en el grupo
		DISPOSITIVOS=$comand
    elif [ $linea > 1 ]
    then
        #Volumenes
		VOLUMENES[$(($linea-2))]=$comand
    else
		echo "LVM: Error en el formato del fichero de configuracion del servicio"
		exit 1
	fi
    let linea+=1
done
IFS=' '

#Comprobamos si hay un numero de lineas en la configuracion suficiente
if [ -z "$VOLUMENES" ]
then
    echo "LVM: Error en el fichero de configuracion, no hay suficientes argumentos"
    exit 1
fi

#Instalamos el servicio
echo 'LVM: Instalando lvm...'
apt-get -y update > /dev/null 2>&1 && echo "LVM: Actualizando paquetes..." || echo "LVM: Error al actualizar los paquetes"
export DEBIAN_FRONTEND=noninteractive
apt-get -y install lvm2 --no-install-recommends > /dev/null && echo "LVM: Instalado lvm2" || echo "LVM: Error al instalar lvm2"

#Inicializamos los volumenes fisicos
echo 'LVM: Inicializando volumenes fisicos...'
pvcreate $DISPOSITIVOS >> /dev/null

#Creamos el grupo
echo 'LVM: Creando el grupo de volumenes...'
vgcreate $NOMBRE $DISPOSITIVOS >> /dev/null

IFS=$'\n'
#Creamos los volumenes logicos
echo 'LVM: Creando volumenes logicos...'
for volumen in ${VOLUMENES[*]}; do
    IFS=$' '
	read -a VOLUMEN <<< "$volumen"
	NOMBRE_VOL=${VOLUMEN[0]}
	SIZE_VOL=${VOLUMEN[1]}
	lvcreate --name $NOMBRE_VOL --size $SIZE_VOL $NOMBRE >> /dev/null && echo "LVM: Volumen $NOMBRE_VOL $SIZE_VOL creado" || echo "LVM: Fallo al crear el volúmen $NOMBRE_VOL"
done

IFS=$oldIFS