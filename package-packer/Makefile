NAME=packer
VERSION=1.6.6
PACKAGE_VERSION=1
DESCRIPTION="Packer image builder"
URL=https://packer.io
MAINTAINER="http://norcams.org"
RELVERSION=7
UPSTREAM=https://releases.hashicorp.com/packer/${VERSION}/packer_${VERSION}_linux_amd64.zip
INSTALLDIR=/opt/${NAME}-install
BINDIR=/usr/sbin

.PHONY: default
default: deps build rpm
package: rpm

.PHONY: clean
clean:
	rm -fr ${INSTALLDIR}
	rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	yum install -y gcc ruby-devel rpm-build rubygems unzip
	gem install -N fpm --version 1.11.0
	pip3.6 install virtualenv

.PHONY: build
build:
	mkdir -p vendor/
	mkdir -p ${INSTALLDIR}/${BINDIR}
	cd vendor && curl ${UPSTREAM} -o ${NAME}-${VERSION}.zip
	cd vendor && unzip ${NAME}-${VERSION}.zip
	cp vendor/packer ${INSTALLDIR}/${BINDIR}

.PHONY: rpm
rpm:
	/usr/local/bin/fpm -s dir -t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		--iteration "$(PACKAGE_VERSION).el$(RELVERSION)" \
		--description "$(shell cat $(DESCRIPTION))" \
		--url "$(shelpl cat $(URL))" \
		--maintainer "$(MAINTAINER)" \
		-C ${INSTALLDIR} \
		.

