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
ADMIN_DN=cn=${ADMIN_USERNAME},${SUFFIX}

PW_HASH=$(slappasswd -s ${ADMIN_PASSWORD})

#function set_suffix() {
#    # $1 = SUFFIX
#    
#}

#function set_admin_name() {
#
#}

#function set_admin_password() {
#
#}

#function add_db_root_element() {
#
#}


#/usr/sbin/slapd -F /etc/openldap/slapd.d -u ldap -g ldap -h "ldap:/// ldaps:/// ldapi:///"
#set_suffix ${SUFFIX}
#set_admin_name ${ADMIN_USERNAME}
#set_admin_password ${ADMIN_PASSWORD}
#add_db_root_element ${ADMIN_DN} ${ADMIN_PASSWORD} ${SUFFIX}

# stop daemon

# exec daemon
exit

"""
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=example,dc=com

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=example,dc=com

slappasswd
New password: 
Re-enter new password: 
{SSHA}nottherealhashstringthiswontworkuseyourown

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}nottherealhashstringthiswontworkuseyourown

ldapadd -x -w secret -D cn=Manager,dc=example,dc=com  -H ldapi:/// <<EOF
dn: dc=example,dc=com
objectClass: domain
dc: example
description: The Example Company of America
"""
