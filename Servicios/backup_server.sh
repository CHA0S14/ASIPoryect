#! /bin/bash

# Archivo del backup del servidor
# Recogemos la informacion necesaria para el perfil del servicio

#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "BACKUP: Error en el paso de parametros a la configuracion del montaje"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $2 existe
if [ ! -f $1 ]
then
    echo "BACKUP: El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi

echo '###### BACKUP ######'
oldIFS = $IFS
IFS = $'\n'
linea= 0
for comand in $(cat $); do
	if [ $point = 0]; then
		DIR = $comand
	fi
	let linea+=1
done
echo 'BACKUP: Creando directorio de backup en $DIR'
echo '#### FIN BACKUP ####'
IFS = $oldIFS
# Se crea directorio para backup
mkdir -p $DIR