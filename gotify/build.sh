#!/bin/sh
set -o errexit

DISTRO_NAME="$(lsb_release -is | tr '[[:upper:]]' '[[:lower:]]')"
DISTRO_CODENAME="$(lsb_release -cs)"

GO_VERSION=${GO_VERSION:-1.16}
GO_TARBALL_URL="https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"
GO_TARBALL_HASH="${GO_TARBALL_HASH:-013a489ebb3e24ef3d915abe5b94c3286c070dfe0818d5bca8108f1d6e8440d2}"
GO_TARBALL_DEST=/tmp/go.tgz

export DEBIAN_FRONTEND=noninteractive
apt update -q
apt install -q -y --no-install-recommends \
    ca-certificates software-properties-common gnupg2 \
    build-essential clang llvm make pkg-config debhelper \
    curl git jq

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/${DISTRO_NAME} ${DISTRO_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
apt update -q
apt install -q -y docker-ce

# TODO: just use the upstream docker build to ensure server and plugin binary compatibility

curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt update -q
apt install -q -y nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt update -q
apt install -q -y yarn

curl -sL -o "${GO_TARBALL_DEST}" "${GO_TARBALL_URL}"
sha256sum -c - <<EOF
${GO_TARBALL_HASH} /tmp/go.tgz
EOF
tar -C /usr/local -zxf /tmp/go.tgz
rm -f /tmp/go.tgz

time dpkg-buildpackage -us -uc -b
