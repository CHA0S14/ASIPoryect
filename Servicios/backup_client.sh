#!/bin/bash

echo "BACKUP CLIENTE: Configurando....."
# Editamos con sed la linea para sacar los parametros necesarios
desde =`sed '1q;d' $1`
servidor = `sed '2q;d' $1`
para = `sed '3q;d' $1`
hora = `sed '4q;d' $1`

echo "BACKUP CLIENTE: Instalando rsync....."
# Instalamos forzosamente rsync y cualquier salida la eliminamos
apt-get install rsync -qq --force-yes -y> /dev/null

echo "BACKUP CLIENTE: Configurando demonio....."
comando = "* */$hora * * * root rsync -avz $desde root@$servidor:$para"
# Buscamos si ya esta configurado el demonio buscando el comando en crontab
# Si no lo añadimos al archivo
grep -Fxq "$comando" /etc/crontab && echo "BACKUP CLIENTE: Ya esta configurado....." || echo "$comando" >> /etc/crontab