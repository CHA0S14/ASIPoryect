#!/bin/bash
#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "CNIS: Error en el paso de parametros a la configuracion del servidor nfs"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $1 existe
if [ ! -f $1 ]
then
    echo "CNIS: El fichero $1 no esta disponible. Abortando ejecución."
    exit 1
fi


#Recopilamos la información del fichero de perfil del servicio
oldIFS=$IFS
IFS=$'\n'
linea=0
for command in $(cat $1); do
	if [ $linea = 0 ]; then
		#Nomnre del dominio nis
		DOMINIO=$command
    elif [ $linea = 1 ]; then
        #Servidor nis a conectar
		SERVIDOR=$command
	else
		echo "CNIS: Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let linea+=1
done
IFS=$oldIFS

ping -c 1 $SERVIDOR &> /dev/null
if [ $? -ne 0 ]
then
	echo "CNIS: La ip no es valida"
	exit 1
fi

#Actualizamos los paquetes
echo "CNIS: Actualizando paquetes"
apt-get -y update &> /dev/null && echo "CNIS: Paquetes actualizados" || echo "CNIS: Error al actualizar paquetes"
export DEBIAN_FRONTEND=noninteractive
#Instalamos NIS
echo "CNIS: Instalando NIS"
apt-get -y install nis --no-install-recommends &> /dev/null && echo "CNIS: NIS instalado" || echo "CNIS: Error al instalar NIS"
echo "CNIS: Configurando cliente NIS"
#Añadimos el dominio al archivo
echo $DOMINIO > /etc/defaultdomain
#Añadimos el dominio y el servidor al fichero
echo "domain $DOMINIO server $SERVIDOR" >> /etc/yp.conf
echo "ypserver $SERVIDOR" >> /etc/yp.conf
#Cambiamos ciertos valores del fichero de configuracion de nis por los corresponsientes con sed
echo "`sed s/"NISCLIENT=false"/"NISCLIENT=true"/g /etc/default/nis`" > /etc/default/nis
echo "`sed s/"group:[[:blank:]]*compat"/"group: \tfiles nis"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
echo "`sed s/"passwd:[[:blank:]]*compat"/"passwd: \tfiles nis"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
echo "`sed s/"shadow:[[:blank:]]*compat"/"shadow: \tfiles nis"/g /etc/nsswitch.conf`" > /etc/nsswitch.conf
#Reiniciamos el servicio
echo "CNIS: Finalizado la configuracion de NIS"
/etc/init.d/nis restart && echo "CNIS: Reiniciado el servicio NIS, configuracion correcta" || echo "CNIS: Error al reiniciar el servicio"
