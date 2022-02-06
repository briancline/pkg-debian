#!/bin/sh
set -o errexit

GO_VERSION=${GO_VERSION:-1.16.6}
GO_TARBALL_URL="https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"
GO_TARBALL_HASH="${GO_TARBALL_HASH:-be333ef18b3016e9d7cb7b1ff1fdb0cac800ca0be4cf2290fe613b3d069dfe0d}"
GO_TARBALL_DEST=/tmp/go.tgz

export DEBIAN_FRONTEND=noninteractive
apt update -q
apt install -q -y --no-install-recommends \
    build-essential clang llvm ccache cmake autoconf bison debhelper \
    curl git

curl -sL -o "${GO_TARBALL_DEST}" "${GO_TARBALL_URL}"
sha256sum -c - <<EOF
${GO_TARBALL_HASH} /tmp/go.tgz
EOF
tar -C /usr/local -zxf /tmp/go.tgz
rm -f /tmp/go.tgz

time dpkg-buildpackage -us -uc -b
