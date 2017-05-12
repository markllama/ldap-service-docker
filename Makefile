build:
	docker build -t markllama/ldap .

shell:
	docker run -it --rm --name test-ldap markllama/ldap /bin/sh

test:
	docker run -d --name test-ldap \
	  --env ADMIN_PASSWORD=password \
	  --env DOMAIN=lamourine.org \
	  markllama/ldap 
