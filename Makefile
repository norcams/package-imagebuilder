NAME=imagebuilder
VERSION=1.0
PACKAGE_VERSION=5
DESCRIPTION=package.description
URL=package.url
MAINTAINER="http://norcams.org"
RELVERSION=7

.PHONY: default
default: deps build rpm
package: rpm

.PHONY: clean
clean:
	rm -fr /installdir
	rm -fr /opt/imagebuilder
	rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	yum install -y gcc ruby-devel rpm-build
	gem install -N fpm
	yum install -y epel-release
	yum install -y python34 python34-devel git python34-pip git
	pip3 install virtualenv

.PHONY: build
build:
	mkdir vendor/
	mkdir -p /opt/imagebuilder
	cd vendor && git clone https://github.com/norcams/imagebuilder
	cd vendor/imagebuilder && git submodule update --init
	rsync -avh vendor/imagebuilder/ /opt/imagebuilder/
	virtualenv /opt/imagebuilder/
	cd /opt/imagebuilder/ && bin/pip3 install -r requirements.txt
	cd /opt/imagebuilder/ && bin/python setup.py install
	echo "/opt/imagebuilder" > /opt/imagebuilder/lib/python3.4/site-packages/imagebuilder.egg-link
	mkdir -p /installdir/opt
	cp -R /opt/imagebuilder /installdir/opt/

.PHONY: rpm
rpm:
	/usr/local/bin/fpm -s dir -t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		--iteration "$(PACKAGE_VERSION).el$(RELVERSION)" \
		--description "$(shell cat $(DESCRIPTION))" \
		--url "$(shelpl cat $(URL))" \
		--maintainer "$(MAINTAINER)" \
		-C /installdir/ \
		.

