#!/bin/bash

# Archivo del backup del servidor
# Recogemos la informacion necesaria para el perfil del servicio

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "BACKUP SERVIDOR: Error en el paso de parametros a la configuracion del montaje."
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $2 existe
if [ ! -f $1 ]
then
    echo "BACKUP SERVIDOR: El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

echo 'BACKUP SERVIDOR: Configurando.....'
oldIFS=$IFS
IFS=$'\n'

IFS=$oldIFS
# Se crea directorio para backup
echo 'BACKUP SERVIDOR: Creando directorio de backup en $DIR.....'
mkdir -p `cat $1`
echo 'BACKUP SERVIDOR: Finalizada configuracion.'