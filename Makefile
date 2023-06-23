NAME=imagebuilder
VERSION=1.36
PACKAGE_VERSION=1
DESCRIPTION=package.description
URL=package.url
MAINTAINER="http://norcams.org"

# Set dist tag and make sure we're building on el8
EL_RELEASE=$(shell sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | cut -d. -f1)
ifeq ($(EL_RELEASE),8)
    DIST=el$(EL_RELEASE)
else
    $(error ERROR: Only for el8)
endif

.PHONY: default
default: deps build rpm
package: rpm

.PHONY: check
check:
	@echo "We're on $(DIST), all good"

.PHONY: clean
clean:
	rm -fr /installdir
	rm -fr /opt/imagebuilder
	rm -f $(NAME)-$(VERSION)-*.rpm
	rm -Rf vendor/

.PHONY: deps
deps:
	yum install -y gcc rpm-build ruby ruby-devel git
	gem install -N fpm --version 1.11.0
	yum install -y epel-release
	yum install -y python36 python36-devel python3-pip python3-virtualenv

.PHONY: build
build:
	mkdir -p vendor/
	mkdir -p /opt/imagebuilder
	cd vendor && git clone https://github.com/norcams/imagebuilder
	cd vendor/imagebuilder && git submodule update --init
	rsync -avh vendor/imagebuilder/ /opt/imagebuilder/
	python3.6 -m venv /opt/imagebuilder/
	cd /opt/imagebuilder/ && bin/python -m pip install --upgrade pip
	cd /opt/imagebuilder/ && bin/python -m pip install -r requirements.txt
	cd /opt/imagebuilder/ && bin/python setup.py install
	echo "/opt/imagebuilder" > /opt/imagebuilder/lib/python3.6/site-packages/imagebuilder.egg-link
	mkdir -p /installdir/opt
	cp -R /opt/imagebuilder /installdir/opt/

.PHONY: rpm
rpm:
	/usr/local/bin/fpm -s dir -t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		--iteration "$(PACKAGE_VERSION).$(DIST)" \
		--description "$(shell cat $(DESCRIPTION))" \
		--url "$(shelpl cat $(URL))" \
		--maintainer "$(MAINTAINER)" \
		-C /installdir/ \
		.

