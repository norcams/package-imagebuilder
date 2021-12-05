NAME=imagebuilder
VERSION=1.12
PACKAGE_VERSION=1
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
	test -f /etc/centos-release && yum -y install centos-release-scl
	yum install -y gcc rpm-build yum rh-ruby23 rh-ruby23-ruby-devel
	source /opt/rh/rh-ruby23/enable; gem install -N fpm --version 1.11.0
	yum install -y epel-release
	yum install -y python36 python36-devel git python36-pip git
	pip3.6 install virtualenv

.PHONY: build
build:
	mkdir -p vendor/
	mkdir -p /opt/imagebuilder
	cd vendor && git clone https://github.com/norcams/imagebuilder
	cd vendor/imagebuilder && git submodule update --init
	rsync -avh vendor/imagebuilder/ /opt/imagebuilder/
	python3.6 -m venv /opt/imagebuilder/
	cd /opt/imagebuilder/ && bin/pip3.6 install -r requirements.txt
	cd /opt/imagebuilder/ && bin/python setup.py install
	echo "/opt/imagebuilder" > /opt/imagebuilder/lib/python3.6/site-packages/imagebuilder.egg-link
	mkdir -p /installdir/opt
	cp -R /opt/imagebuilder /installdir/opt/

.PHONY: rpm
rpm:
	source /opt/rh/rh-ruby23/enable; /opt/rh/rh-ruby23/root/usr/local/bin/fpm -s dir -t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		--iteration "$(PACKAGE_VERSION).el$(RELVERSION)" \
		--description "$(shell cat $(DESCRIPTION))" \
		--url "$(shelpl cat $(URL))" \
		--maintainer "$(MAINTAINER)" \
		-C /installdir/ \
		.

