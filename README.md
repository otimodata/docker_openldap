# [![N|Solid](https://www.otimo.se/images/uploads/Otimo_Logo_100.png)](https://otimo.se) -- OpenLDAP

OpenLDAP with one backend, LMDB
Configured with data folder at
> /srv/openldap/data

and schema configuration at
> /srv/openldap/config

Use a separate volume to configure, setup and start the container.
The following example use a volume named openldap-data and copies files from current folder.
```
docker create -v openldap-data:/srv -p 389:389 --name openldap otimo/openldap
docker cp config.ldif openldap:/srv/openldap
docker cp data.ldif openldap:/srv/openldap
docker cp certs openldap:/srv/openldap/certs
docker run openldap
````
When the container starts the directory is created based on the supplied ldif files.
````
salt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4); \
  echo -n {SSHA}; ((echo -n "confpwd${salt}" | openssl dgst -sha1 -binary);echo -n $salt) | openssl enc -base64
salt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4); \
  echo -n {SSHA}; ((echo -n "datapwd${salt}" | openssl dgst -sha1 -binary);echo -n $salt) | openssl enc -base64
salt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4); \
  echo -n {SSHA}; ((echo -n "usr1pwd${salt}" | openssl dgst -sha1 -binary);echo -n $salt) | openssl enc -base64
salt=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 4); \
  echo -n {SSHA}; ((echo -n "usr2pwd${salt}" | openssl dgst -sha1 -binary);echo -n $salt) | openssl enc -base64
````
