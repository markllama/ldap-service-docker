FROM fedora:25

# Install 
RUN dnf -y install openldap-servers openldap-clients ; dnf -y clean all

# Set configuration
RUN cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

# Add minimum schemas
RUN su -s /bin/sh -c "/usr/sbin/slapadd -F /etc/openldap/slapd.d -n0 -l /etc/openldap/schema/cosine.ldif" ldap ; \
    su -s /bin/sh -c "/usr/sbin/slapadd -F /etc/openldap/slapd.d -n0 -l /etc/openldap/schema/inetorgperson.ldif" ldap

#
ADD startup.sh /startup.sh

# Make LDAP available
EXPOSE 398

#CMD /usr/sbin/slapd -u ldap -h "ldap:/// ldaps:/// ldapi:///"
CMD /usr/bin/sh startup.sh