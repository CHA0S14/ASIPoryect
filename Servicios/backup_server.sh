#! /bin/bash

# Archivo del backup del servidor
# Recogemos la informacion necesaria para el perfil del servicio

echo '###### BACKUP ######'

point = 0
for argument in $(cat $); do
	if [ $point = 0]; then
		DIR = $argument
	fi
	let point+=1
done
echo 'CONFIG: Creando directorio de backup en $DIR'
echo '#### FIN BACKUP ####'

# Se crea directorio para backup
mkdir -p $DIR