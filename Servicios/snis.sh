#Comprobacion argumentos correctos
if [ $# -ne 1 ]
then
	echo "SNIS: Error en el paso de parametros a la configuracion del servidor nfs"
	exit 1
fi

#Comprobacion de que el fichero de configuracion de $1 existe
if [ ! -f $1 ]
then
    echo "SNIS: El fichero $1 no esta disponible. Abortando ejecución."
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
	else
		echo "SNIS: Error en el formato del fichero de perfil del servicio"
		exit 1
	fi
	let linea+=1
done

#Obtenemos el nombre de servidro
SERVIDOR=`hostname`
IFS=$oldIFS
#Actualizamos los paquetes
apt-get -y update &> /dev/null && echo "SNIS: Actualizamos los paquetes" || echo "SNIS: Error al actualizar paquetes"
export DEBIAN_FRONTEND=noninteractive
#Instalamos NIS
echo "SNIS: Instalando NIS"
apt-get -y install nis --no-install-recommends &> /dev/null || echo "SNIS: Error al instalar NIS"
#Comenzamos la configuracion del servidor NIS
echo "SNIS: Configurando servidor NIS"
#Configuramos el nombre de dominio por defecto
echo $DOMINIO > /etc/defaultdomain && echo "SNIS: Configurando nombre de dominio como \"$DOMINIO\""
#Aniadimos al final del archivo yp.conf una linea de configuracion
echo "domain $DOMINIO server $SERVIDOR" >> /etc/yp.conf
#Sustituimos con sed todas las ocurrencias de NISSERVER=false por true y NISCLIENT=true por false en el fichero
echo "`sed s/"NISSERVER=false"/"NISSERVER=true"/g /etc/default/nis`" > /etc/default/nis
echo "`sed s/"NISCLIENT=true"/"NISCLIENT=false"/g /etc/default/nis`" > /etc/default/nis
#Ejecutamos ypinit -m introduciendole con un pipe un EOF
EOF | /usr/lib/yp/ypinit -m &> /dev/null || echo "SNIS: No se ha podido ejecutar correctamente ypinit"
#Reiniciamos el servicio
echo "SNIS: Reiniciando el servicio"
/etc/init.d/nis restart &> /dev/null || echo "SNIS: No se ha podido reiniciar el servicio"
echo "SNIS: Configuración del servidor NIS completada"
