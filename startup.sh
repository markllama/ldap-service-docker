#!/bin/sh
#
# Initialize an LDAP database using LDIF slapd-config(5) format
#
#
ORG_NAME=${ORG_NAME:-"Example Corporation"}
DOMAIN=${DOMAIN:-example.com}
ADMIN_USERNAME=${ADMIN:-Manager}
if [ -z "${ADMIN_PASSWORD}" ] ; then
    echo "Missing required env ADMIN_PASSWORD"
    exit 2
fi
DESCRIPTION=${DESCRIPTION:-"A sample database"}

# Convert inputs to LDAP DN form
SUFFIX=$(echo $DOMAIN | sed -e 's/^/dc=/' -e 's/\./,dc=/g')
ROOT_DC=$(echo $DOMAIN | cut -d. -f1)
ADMIN_DN=cn=${ADMIN_USERNAME},${SUFFIX}
ADMIN_HASH=$(slappasswd -s ${ADMIN_PASSWORD})

function init_database() {
    # BASEDN=$1
    # ORG_NAME=$2
    # ADMIN_DN=$3
    # ADMIN_PW=$4
    jinja2-2.7 /init_base.ldif.j2 <<EOF > /init_base.ldif
basedn: '$1'
orgname: '$2'
rootdn: '$3'
rootpw: '$4'
EOF
    ldapmodify -Q -Y EXTERNAL -H ldapi:/// < /init_base.ldif

}

function add_db_root_element() {
    # ADMIN_PASSWORD=$1
    # ADMIN_DN=$2
    # SUFFIX=$3
    # ROOT_DC=$4
    # DESCRIPTION=$5
    ldapadd -x -w $1 -D $2  -H ldapi:/// <<EOF
dn: $3
objectClass: domain
dc: $4
description: $5
EOF

    jinja2-2.7 /init_ou.ldif.j2 <<EOF > /init_ou.ldif
basedn: '$3'
orgname: '$2'
rootdn: '$3'
rootpw: '$1'
EOF
    ldapadd -x -w $1 -D $2  -H ldapi:/// < /init_ou.ldif
}


/usr/sbin/slapd -F /etc/openldap/slapd.d -u ldap -g ldap -h "ldapi:///"
#set_suffix ${SUFFIX}
#set_admin_name ${ADMIN_DN}
#set_admin_password ${ADMIN_PASSWORD}
#set_admin_password ${ADMIN_HASH}
init_database "${SUFFIX}" "${ORG_NAME}" "${ADMIN_DN}" "${ADMIN_HASH}"
add_db_root_element ${ADMIN_PASSWORD} ${ADMIN_DN} ${SUFFIX} ${ROOT_DC} "${DESCRIPTION}"

# stop daemon
kill $(grep -n slapd /proc/[0-9]*/comm | cut -d/ -f3)

# exec daemon
exec /usr/sbin/slapd -F /etc/openldap/slapd.d -u ldap -g ldap -h "ldap:/// ldaps:/// ldapi:///" -d 256
