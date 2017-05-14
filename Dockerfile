FROM fedora:25

# Identify the image contents and purpose
LABEL maintainer="Mark Lamourine <markllama@gmail.com>" \
      org.lamourine.version="0.9.1" \
      org.lamourine.release-date="2017-05-04"

# Install packages (and remove unneeded one after pulling the schema)
RUN dnf -y install openldap-servers openldap-clients python-jinja2-cli dhcp-server ; \
    mv /etc/openldap/schema/dhcp.schema /etc/openldap/schema/dhcp.schema.save ; \
    dnf -y remove dhcp-server ; \
    mv /etc/openldap/schema/dhcp.schema.save /etc/openldap/schema/dhcp.schema ; \
    dnf -y clean all

RUN mkdir /tmp/slapd.d ; \
    echo 'include /etc/openldap/schema/dhcp.schema'  > /tmp/slapd.conf ; \
    slapcat -f /tmp/slapd.conf -F /tmp/slapd.d -n0 \
      -l /etc/openldap/schema/dhcp.ldif \
      -H ldap:///cn={0}dhcp,cn=schema,cn=config ; \
    sed -i -e '/CRC32/d ; s/{0}dhcp/dhcp/ ; /structuralObjectClass/,$d' \
      /etc/openldap/schema/dhcp.ldif ; \
    rm -rf /tmp/slapd.d ; \
    rm /tmp/slapd.conf

# Set configuration
RUN cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

# modified from bind-dyndb-ldap /usr/share/doc/bind/dyndb-ldap/schema.ldif
ADD dns-schema.ldif /etc/openldap/schema/dns.ldif

# Add minimum schemas
RUN su -s /bin/sh -c "/usr/sbin/slapadd -F /etc/openldap/slapd.d -n0 -l /etc/openldap/schema/cosine.ldif" ldap ; \
    su -s /bin/sh -c "/usr/sbin/slapadd -F /etc/openldap/slapd.d -n0 -l /etc/openldap/schema/inetorgperson.ldif" ldap ; \
    su -s /bin/sh -c "/usr/sbin/slapadd -F /etc/openldap/slapd.d -n0 -l /etc/openldap/schema/dhcp.ldif" ldap ; \
    su -s /bin/sh -c "/usr/sbin/slapadd -F /etc/openldap/slapd.d -n0 -l /etc/openldap/schema/dns.ldif" ldap

#
ADD init_base.ldif.j2 /init_base.ldif.j2
ADD init_ou.ldif.j2 /init_ou.ldif.j2

ADD startup.sh /startup.sh

# Make LDAP available
EXPOSE 398

CMD /usr/bin/sh startup.sh
