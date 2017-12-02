#!/bin/bash

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

echo "BACKUP CLIENTE: Configurando....."
# Editamos con sed la linea para sacar los parametros necesarios
desde=`sed '1q;d' $1`
servidor=`sed '2q;d' $1`
para=`sed '3q;d' $1`
hora=`sed '4q;d' $1`

#comprobamos la existencia de la carpeta de origen
if [ ! -d $desde ]
then
    echo "BACKUP CLIENTE: No existe la carpeta de origen"
    exit 1
fi

#comprobamos si la ip corresponde a una maquina
ping -c 1 $servidor > /dev/null 2> /dev/null
if [ $? -ne 0 ] 
then
    echo "BACKUP CLIENTE: La ip del servidor no corresponde con una maquina valida"
    exit 1
fi

#comprobamos la existencia de la carpeta de destino
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$servidor test -d $para > /dev/null 2> /dev/null
if [ $? -ne 0 ] 
then
    echo "BACKUP CLIENTE: La carpeta de destino no existe"
    exit 1
fi

echo "BACKUP CLIENTE: Instalando rsync..."
# Instalamos forzosamente rsync y cualquier salida la eliminamos
apt-get install rsync -qq --force-yes -y > /dev/null 2> /dev/null || echo "BACKUP CLIENTE: Error en la instalacion"

echo "BACKUP CLIENTE: Configurando demonio..."
comando="* */$hora * * * root rsync -avz $desde root@$servidor:$para"
# Buscamos si ya esta configurado el demonio buscando el comando en crontab
# Si no lo añadimos al archivo
grep -Fxq "$comando" /etc/crontab && echo "BACKUP CLIENTE: Ya esta configurado." || echo "$comando" >> /etc/crontab

echo "BACKUP CLIENTE: Fin de la configuracion"