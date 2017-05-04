#!/bin/sh
#
# Initialize an LDAP database using LDIF slapd-config(5) format
#
#
DOMAIN=${DOMAIN:-example.com}
ADMIN_USERNAME=${ADMIN:-Manager}
if [ -z "${ADMIN_PASSWORD}" ] ; then
    echo "Missing required env ADMIN_PASSWORD"
    exit 2
fi

# Convert inputs to LDAP DN form
SUFFIX=$(echo $DOMAIN | sed -e 's/^/dc=/' -e 's/\./,dc=/g')
ROOT_DC=$(echo $DOMAIN | cut -d. -f1)
ADMIN_DN=cn=${ADMIN_USERNAME},${SUFFIX}
ADMIN_HASH=$(slappasswd -s ${ADMIN_PASSWORD})

function set_suffix() {
    # SUFFIX=$1

    ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $1
EOF

}

function set_admin_name() {
    # $ADMIN_DN=$1
    ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: $1
EOF

}

function set_admin_password() {
    # ADMIN_HASH=$1
    ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $1
EOF

}

function add_db_root_element() {
    # ADMIN_PASSWORD=$1
    # ADMIN_DN=$2
    # SUFFIX=$3
    # ROOT_DC=$4
    # DESCRIPTION=$4
    ldapadd -x -w $1 -D $2  -H ldapi:/// <<EOF
dn: $3
objectClass: domain
dc: $4
description: $5
EOF

}


/usr/sbin/slapd -F /etc/openldap/slapd.d -u ldap -g ldap -h "ldap:/// ldaps:/// ldapi:///"
set_suffix ${SUFFIX}
set_admin_name ${ADMIN_USERNAME}
set_admin_password ${ADMIN_PASSWORD}
add_db_root_element ${ADMIN_PASSWORD ${ADMIN_DN} ${SUFFIX} ${ROOT_DC} "${DESCRIPTION}"

# stop daemon

exit

# exec daemon
exec /usr/sbin/slapd -F /etc/openldap/slapd.d -u ldap -g ldap -h "ldap:/// ldaps:/// ldapi:///"

"""





