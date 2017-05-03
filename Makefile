build:
	docker build -t markllama/ldap .

shell:
	docker run -it --rm --name test-ldap markllama/ldap /bin/sh
