#!/bin/sh

run() {
	OPENCONNECT_PARAMS=""
	if [ -n "$OPENCONNECT_AUTHGROUP" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --authgroup=\"$OPENCONNECT_AUTHGROUP\""
	fi
	if [ -n "$OPENCONNECT_USER" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --user=$OPENCONNECT_USER"
	fi
	if [ -n "$OPENCONNECT_PROTOCOL" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --protocol=$OPENCONNECT_PROTOCOL"
	fi
	if [ -n "$OPENCONNECT_OS" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --os=$OPENCONNECT_OS"
	fi
	if [ -n "$OPENCONNECT_FINGERPRINT" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --servercert $OPENCONNECT_FINGERPRINT"
	else
		REMOTE_HOST=$(echo $OPENCONNECT_URL | sed -r 's/https:\/\///g' | sed '/:[0-9]*$/ ! s/$/:443/')

		# sha1
		#OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --servercert $(echo | openssl s_client -connect $REMOTE_HOST 2>&1 | openssl x509 -noout -text -fingerprint -sha1 | grep SHA1\ Fingerprint= | sed -r 's/(SHA1\ Fingerprint=|:)//g')"

		# pin-sha256
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --servercert pin-sha256:$(echo "" | openssl s_client -connect $REMOTE_HOST -prexit 2>/dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64)"
	fi
	if [ -n "$OPENCONNECT_OPTIONS" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS $OPENCONNECT_OPTIONS"
	fi
	if [ -n "$OPENCONNECT_OCPROXY_OPTIONS" ]; then
		OPENCONNECT_PARAMS="$OPENCONNECT_PARAMS --script-tun --script=\"ocproxy $OPENCONNECT_OCPROXY_OPTIONS\""
	fi

	if [ -n "$OPENCONNECT_PASSWORD" ]; then
		echo ${OPENCONNECT_PASSWORD} | eval openconnect ${OPENCONNECT_PARAMS} ${OPENCONNECT_URL}
	else
		echo "openconnect --no-passwd $OPENCONNECT_PARAMS $OPENCONNECT_URL"
		eval openconnect --no-passwd ${OPENCONNECT_PARAMS} ${OPENCONNECT_URL}
	fi
}

until(run); do
	echo "openconnect finalizado. Reiniciando proceso en 60 segundos…" >&2
  	sleep 60
done
