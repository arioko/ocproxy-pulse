#!/bin/sh
if test "$#" -ne 2; then
	echo "No se han indicado los parámetros necesarios"
	echo "Uso: p12_to_pem.sh [path_to_p12] [password]"
else
	openssl pkcs12 -clcerts -nokeys -in $1 -passin pass:$2 -out cert/cer.pem
	openssl pkcs12 -nocerts -in $1 -passin pass:$2 -passout pass:$2 | openssl rsa -out cert/key.pem -passin pass:$2
fi
