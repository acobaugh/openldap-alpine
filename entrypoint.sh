#!/bin/sh

set -e

if [ ! -d /etc/openldap/slapd.d ]; then
	echo "Configuring OpenLDAP via slapd.d"
	mkdir /etc/openldap/slapd.d
	chmod 750 /etc/openldap/slapd.d
	echo "SLAPD_CONFIG_ROOTDN = $SLAPD_CONFIG_ROOTDN"
	if [ -z "$SLAPD_CONFIG_ROOTDN" ]; then
		echo -n >&2 "Error: SLAPD_CONFIG_ROOTDN not set. "
		echo >&2 "Did you forget to add -e SLAPD_CONFIG_ROOTDN=... ?"
		exit 1
	fi
	if [ -z "$SLAPD_CONFIG_ROOTPW" ]; then
		echo -n >&2 "Error: SLAPD_CONFIG_ROOTPW not set. "
		echo >&2 "Did you forget to add -e SLAPD_CONFIG_ROOTPW=... ?"
		exit 1
	fi

	config_rootpw_hash=`slappasswd -s "${SLAPD_CONFIG_ROOTPW}"`

	## TODO
	# /ldap/schemas
	# /ldap/config
	# /ldap/pki

	# schema
	cat <<-EOF >> /tmp/slapd.conf
	include /etc/openldap/schema/core.schema
	include /etc/openldap/schema/dyngroup.schema
	include /etc/openldap/schema/cosine.schema
	include /etc/openldap/schema/inetorgperson.schema
	include /etc/openldap/schema/openldap.schema
	include /etc/openldap/schema/corba.schema
	include /etc/openldap/schema/pmi.schema
	include /etc/openldap/schema/ppolicy.schema
	include /etc/openldap/schema/misc.schema
	include /etc/openldap/schema/nis.schema
	EOF
	
	if [ -d "/ldap/schemas" ]; then
		for f in /ldap/schema/*.schema ; do
			echo "Including custom schema $f"
			echo "include $f" >> /tmp/slapd.conf
		done
	fi

	cat <<-EOF >> /tmp/slapd.conf
	database config
	rootDN "$SLAPD_CONFIG_ROOTDN"
	rootpw $config_rootpw_hash
	EOF

	echo "Generating configuration"
	slaptest -f /tmp/slapd.conf -F /etc/openldap/slapd.d
fi

chown -R ldap:ldap /etc/openldap/slapd.d/

exec "$@"
