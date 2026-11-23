#!/usr/bin/env bash
set -oue pipefail

mkdir -p /var/tmp
chmod 1777 /var/tmp

KERNEL_VERSION="$(rpm -q "kernel" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

echo "=== Installing OpenRazer (akmod + userspace) for kernel ${KERNEL_VERSION} ==="

curl -fLsS --retry 5 -o /etc/yum.repos.d/terra.repo \
    "https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo"

dnf install -y --setopt=install_weak_deps=False \
    "kernel-devel-${KERNEL_VERSION}" \
    akmods \
    gcc \
    make \
    elfutils-libelf-devel

cp /usr/sbin/akmodsbuild /usr/sbin/akmodsbuild.backup
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild

dnf install -y --setopt=install_weak_deps=False \
    akmod-openrazer \
    openrazer-meta

echo "=== Building OpenRazer kernel modules ==="
akmods --force --kernels "${KERNEL_VERSION}" --kmod openrazer

mv /usr/sbin/akmodsbuild.backup /usr/sbin/akmodsbuild

depmod -a "${KERNEL_VERSION}"

for mod in razerkbd razermouse razerkraken razeraccessory; do
    modinfo "/usr/lib/modules/${KERNEL_VERSION}/extra/openrazer/${mod}.ko.xz" > /dev/null || {
        echo "ERROR: Missing compiled OpenRazer module: ${mod}"
        find /var/cache/akmods/openrazer/ -name '*.log' -print -exec cat {} \; || true
        exit 1
    }
done

echo "=== OpenRazer kernel modules verified successfully ==="

dnf remove -y akmod-openrazer akmods kernel-devel kernel-headers
rm -f /etc/yum.repos.d/terra.repo
