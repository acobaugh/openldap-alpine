FROM alpine:3.5

MAINTAINER Andy Cobaugh <andrew.cobaugh@gmail.com>

RUN apk --update --no-cache --virtual=build-dependencies add curl ca-certificates tar && \
	apk add --no-cache openldap openldap-clients openldap-back-monitor openssl && \
	apk del build-dependencies

EXPOSE 389

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/slapd", "-h", "ldap:///", "-u", "ldap", "-g", "ldap", "-F", "/etc/openldap/slapd.d", "-d", "0" ]
 
