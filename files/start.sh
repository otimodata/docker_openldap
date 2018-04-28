#!/bin/sh
if [ ! -d /srv/openldap/config ]; then
	install -v -m750 -o openldap -g openldap -d /srv/openldap/config
	install -v -m750 -o openldap -g openldap -d /srv/openldap/data

	if [ -f /srv/openldap/config.ldif ]; then
		slapadd -n 0 -F /srv/openldap/config -l /srv/openldap/config.ldif
		if [ -f /srv/openldap/data.ldif ]; then
			slapadd -F /srv/openldap/config -l /srv/openldap/data.ldif
		fi
		chown -R openldap:openldap /srv/openldap/*
	fi
fi
if [ ! -d /run/openldap ]; then
	install -v -m755 -o openldap -g openldap -d /run/openldap
fi

LDAP_URIS="ldap:/// ldapi:///"
[ -d /srv/openldap/certs ] && LDAP_URIS="$LDAP_URIS ldaps:///"

/usr/sbin/slapd -d 64 -h "$LDAP_URIS" -u openldap -g openldap -F /srv/openldap/config
