#!/bin/bash
GIT_URL=git://github.com/zcash/zcash.git
CONFDIR=/root/.zcash
ZCASH_CONF=${CONFDIR}/zcash.conf
ZKSNARK_DIR="/vagrant/zkSNARK"

# if buildversion is set, build this version
# otherwise build master
if [ "$1" != "" ]; then
    ZCASH_VERSION=${1}
else
    ZCASH_VERSION=master
fi

# update the package list
apt-get update
apt-get -qqy install build-essential automake ncurses-dev libcurl4-openssl-dev \
    libssl-dev libgtest-dev make autoconf automake libtool git apt-utils pkg-config \
    libc6-dev libcurl3-dev libudev-dev m4 g++-multilib unzip git python zlib1g-dev \
    wget bsdmainutils

echo "*****************************************"
echo "Building zcash version ${ZCASH_VERSION}"
echo "*****************************************"

# downloads the zkSNARKs and puts them to the right place
mkdir -p /root/.zcash-params/

# proving.key
if [ ! -f "${ZKSNARK_DIR}/sprout-proving.key" ]; then
    curl -o /root/.zcash-params/sprout-proving.key https://z.cash/downloads/sprout-proving.key
fi

# sprout-verifying.key
if [ ! -f "${ZKSNARK_DIR}/sprout-verifying.key" ]; then
    curl -o /root/.zcash-params/sprout-verifying.key https://z.cash/downloads/sprout-verifying.key
fi

# swaphack
if free | awk '/^Swap:/ {exit !$2}'; then
	echo "Already have swap"
else
	echo "No swap"
	# needed because ant servers are ants
	rm -f /var/swap.img
	dd if=/dev/zero of=/var/swap.img bs=1024k count=3096
	chmod 0600 /var/swap.img
	mkswap /var/swap.img
	swapon /var/swap.img
	echo '/var/swap.img none swap sw 0 0' | tee -a /etc/fstab
	echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
	echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf		
fi

# clone the sources and install
mkdir -p /opt/code/; cd /opt/code; git clone ${GIT_URL} zcash && cd zcash && \
git checkout ${ZCASH_VERSION}
./zcutil/fetch-params.sh && ./zcutil/build.sh -j4 && cd /opt/code/zcash/src
/usr/bin/install -c zcash-tx zcashd zcash-cli zcash-gtest -t /usr/local/bin/

# generate a dummy config to enable easy testnet mining    
PASS=$(date | md5sum | cut -c1-24); mkdir -p ${CONFDIR}; \
    printf '%s\n%s\n%s\n%s\n%s\n' "rpcuser=zcashrpc" "rpcpassword=${PASS}" >> ${ZCASH_CONF} 