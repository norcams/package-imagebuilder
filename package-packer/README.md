# package-packer
Makefile to build an rpm version of the packer application with fpm. `packer`
is used by `imagebuilder` during the image building process.

To build an RPM package of a new version of *packer* it should be sufficient to
adjust the *VERSION* variable. Also adjust the PACKAGE_VERSION accordingly.
