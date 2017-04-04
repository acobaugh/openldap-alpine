FROM alpine:3.5

MAINTAINER Andy Cobaugh <andrew.cobaugh@gmail.com>

COPY entrypoint.sh /entrypoint.sh
RUN apk --update --no-cache --virtual=build-dependencies add curl ca-certificates tar && \
	apk add --no-cache openldap && \
	apk del build-dependencies && \
	chmod 755 /entrypoint.sh

EXPOSE 389

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/slapd", "-h", "ldap:///", "-u", "ldap", "-g", "ldap", "-d", "0", "-F", "/etc/openldap/slapd.d" ]
 
