#! /bin/bash


# Recogemos la informacion necesaria para el perfil del servicio
DIR = $(cat $1)
echo 'CONFIG: Creando directorio de backup en $DIR'
mkdir -p $DIR