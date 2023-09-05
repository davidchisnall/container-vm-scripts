#!/bin/sh

set -e

# FIXME: These are stupid names that will conflict with other things.  They are
# fine for now because I am not using this VM for anything else but they will
# cause pain when other people try to use this script.
JAILNAME=podman-vm-jail
PORTSNAME=podmanvmports
OVERLAYNAME=podmanvmpatches
SCRIPTPATH=$(realpath $(dirname $0))
echo Script source: ${SCRIPTPATH}

if [ ! -d freebsd-src ] ; then
	echo Cloning FreeBSD source
	git clone https://github.com/freebsd/freebsd-src
	cd freebsd-src
	echo Applying 9pfs patches
	git remote add dfr https://github.com/dfr/freebsd-src
	git fetch dfr 9pfs
	git cherry-pick dfr/9pfs
	cd ..
fi

# Create the jail and ports trees if they don't exist
echo Creating jail
poudriere jail -i -j ${JAILNAME} || poudriere jail -c -j ${JAILNAME} -b -m src=$(pwd)/freebsd-src -K GENERIC -J $(sysctl -n hw.ncpu)
echo Creating ports tree
poudriere ports -c -p ${PORTSNAME} -m git+https -U https://github.com/freebsd/freebsd-ports || true
echo Creating ports tree overlay
poudriere ports -c -M  ${SCRIPTPATH}/ports -m null -p ${OVERLAYNAME} || true

# Install our make.conf in the right place
cp ${SCRIPTPATH}/make.conf  /usr/local/etc/poudriere.d/${JAILNAME}-${PORTSNAME}-make.conf
# Build the required packages.
time poudriere bulk -j ${JAILNAME} -O ${OVERLAYNAME} -p ${PORTSNAME} -f pkg.lst 
# Create the image with our overlay and the required packages
time poudriere image -t zfs+gpt -j ${JAILNAME} -s 2G -c overlay -f pkg.lst -p ${PORTSNAME} -n podmanvm -h podmanvm

# For some reason, the qcow2 version doesn't boot.  Figure out why later.
#qemu-img convert -f raw -O qcow2 /usr/local/poudriere/data/images/podmanvm.img podmanvm.qcow2
