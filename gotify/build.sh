#!/bin/sh
set -o errexit

export GO_VERSION=${GO_VERSION:-1.16}
export GO_TARBALL_URL="https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"
export GO_TARBALL_HASH="${GO_TARBALL_HASH:-013a489ebb3e24ef3d915abe5b94c3286c070dfe0818d5bca8108f1d6e8440d2}"
export GO_TARBALL_DEST=/tmp/go.tgz

export DEBIAN_FRONTEND=noninteractive
apt install -q -y --no-install-recommends \
	ca-certificates software-properties-common gnupg2 \
	build-essential clang llvm make pkg-config debhelper \
	curl git rsync

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update -q
sudo apt install docker-ce -q -y

# TODO: just use the upstream docker build to ensure server and plugin binary compatibility

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

curl -sL -o "${GO_TARBALL_DEST}" "${GO_TARBALL_URL}"
sha256sum -c - <<EOF
${GO_TARBALL_HASH} /tmp/go.tgz
EOF
tar -C /usr/local -zxf /tmp/go.tgz
rm -f /tmp/go.tgz

time dpkg-buildpackage -us -uc -b
