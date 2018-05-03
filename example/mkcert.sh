#!/bin/bash

openssl genrsa -out certs/rootCA.key 4096
openssl req -x509 -new -nodes -key certs/rootCA.key -sha512 -days 11565 -out certs/rootCA.crt -config rootCA.cnf

openssl genrsa -out certs/ldap_server.key 2048
openssl req -new -key certs/ldap_server.key -out certs/ldap_server.csr -config ldap_server.cnf
openssl x509 -req -in certs/ldap_server.csr -CA certs/rootCA.crt -CAkey certs/rootCA.key -CAcreateserial -out certs/ldap_server.crt -days 11565 -sha256 -extfile ldap_server.cnf -extensions v3_ext

rm certs/rootCA.key
rm certs/rootCA.srl
rm certs/ldap_server.csr
