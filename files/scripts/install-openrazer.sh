#!/usr/bin/env bash
set -oue pipefail

SIGNING_TMP_DIR="/tmp/husky-mok-sign"
cleanup_signing_tmp() {
    rm -rf "${SIGNING_TMP_DIR}" /tmp/kmod.sig /tmp/kmod.p7s /tmp/kmod.data
}
trap cleanup_signing_tmp EXIT

mkdir -p /var/tmp "${SIGNING_TMP_DIR}"
chmod 1777 /var/tmp
chmod 700 "${SIGNING_TMP_DIR}"

KERNEL_VERSION="$(rpm -q "kernel" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
PUBLIC_KEY_DER_PATH="${PUBLIC_KEY_DER_PATH:-/etc/pki/akmods/certs/husky-mok.der}"
PRIVATE_KEY_PATH="/tmp/certs/private_key.priv"

if [[ ! -s "${PUBLIC_KEY_DER_PATH}" ]]; then
    echo "ERROR: Missing public MOK certificate at ${PUBLIC_KEY_DER_PATH}"
    exit 1
fi

if [[ ! -s "${PRIVATE_KEY_PATH}" ]]; then
    echo "ERROR: Missing private MOK key at ${PRIVATE_KEY_PATH} (check MOK_PRIVATE_KEY secret in GitHub Actions)"
    exit 1
fi

echo "=== Installing OpenRazer (akmod + userspace) for kernel ${KERNEL_VERSION} ==="

curl -fLsS --retry 5 -o /etc/yum.repos.d/terra.repo \
    "https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo"

dnf install -y --setopt=install_weak_deps=False \
    "kernel-devel-${KERNEL_VERSION}" \
    akmods \
    gcc \
    make \
    elfutils-libelf-devel \
    perl-interpreter

cp /usr/sbin/akmodsbuild /usr/sbin/akmodsbuild.backup
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild

dnf install -y --setopt=install_weak_deps=False \
    akmod-openrazer \
    openrazer-meta

echo "=== Building OpenRazer kernel modules ==="
akmods --force --kernels "${KERNEL_VERSION}" --kmod openrazer

mv /usr/sbin/akmodsbuild.backup /usr/sbin/akmodsbuild

echo "=== Signing OpenRazer kernel modules for Secure Boot ==="
PUBLIC_KEY_CRT_PATH="${SIGNING_TMP_DIR}/public_key.crt"
SIGNING_KEY="${SIGNING_TMP_DIR}/signing_key.pem"

openssl x509 -inform DER -in "${PUBLIC_KEY_DER_PATH}" -out "${PUBLIC_KEY_CRT_PATH}"
cat "${PRIVATE_KEY_PATH}" <(echo) "${PUBLIC_KEY_CRT_PATH}" > "${SIGNING_KEY}"
chmod 600 "${SIGNING_KEY}"

for module in /usr/lib/modules/"${KERNEL_VERSION}"/extra/openrazer/*.ko*; do
    module_basename="${module%.*}"
    module_suffix="${module##*.}"
    if [[ "${module_suffix}" == "xz" ]]; then
        xz --decompress "${module}"
        openssl cms -sign -signer "${SIGNING_KEY}" -binary -in "${module_basename}" \
            -outform DER -out "${module_basename}.cms" -nocerts -noattr -nosmimecap
        /usr/src/kernels/"${KERNEL_VERSION}"/scripts/sign-file \
            -s "${module_basename}.cms" sha256 "${PUBLIC_KEY_CRT_PATH}" "${module_basename}"
        /usr/src/kernels/"${KERNEL_VERSION}"/scripts/extract-module-sig.pl -s "${module_basename}" > /tmp/kmod.sig
        openssl pkcs7 -inform der -in /tmp/kmod.sig -out /tmp/kmod.p7s
        /usr/src/kernels/"${KERNEL_VERSION}"/scripts/extract-module-sig.pl -0 "${module_basename}" > /tmp/kmod.data
        openssl cms -verify -binary -inform PEM \
            -in /tmp/kmod.p7s \
            -content /tmp/kmod.data \
            -certfile "${PUBLIC_KEY_CRT_PATH}" \
            -out /dev/null \
            -nointern -noverify
        rm -f "${module_basename}.cms" /tmp/kmod.sig /tmp/kmod.p7s /tmp/kmod.data
        xz -C crc32 -f "${module_basename}"
        echo "Signature Verified for ${module}"
    else
        echo "ERROR: Unexpected module compression format: ${module}"
        exit 1
    fi
done

cleanup_signing_tmp
depmod -a "${KERNEL_VERSION}"

for mod in razerkbd razermouse razerkraken razeraccessory; do
    mod_path="/usr/lib/modules/${KERNEL_VERSION}/extra/openrazer/${mod}.ko.xz"
    signer="$(modinfo -F signer "${mod_path}" || true)"
    if [[ "${signer}" != *"Husky Linux MOK"* ]]; then
        echo "ERROR: Module ${mod_path} missing expected Husky Linux MOK signature (got: '${signer}')"
        exit 1
    fi
    echo "[OK] ${mod}.ko.xz signed by: ${signer}"
done

echo "=== OpenRazer kernel modules built, signed, and verified ==="

dnf remove -y akmod-openrazer akmods kernel-devel kernel-headers
rm -f /etc/yum.repos.d/terra.repo

echo "=== Ensuring first-boot wizard (initial-setup) triggers for user creation ==="
touch /.unconfigured

