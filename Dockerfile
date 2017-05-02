FROM fedora:25

RUN dnf -y install openldap-servers openldap-clients ; dnf -y clean all

#
RUN cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
#
#

# Make LDAP available
EXPOSE 398

CMD /bin/sh