#!/bin/bash -eu
RUNPWD="${PWD}"
TMPDIR=/tmp/libhoudini-installer
DESTDIR="$(readlink -f "${1:-/var/lib/waydroid/overlay}")"

PREBUILT='https://github.com/Waydroid-ATV/vendor_intel_proprietary_houdini/archive/refs/heads/chromeos_nissa.tar.gz'

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  echo 'Usage: ./install-libhoudini-a13.sh [optional: destination]'
  exit 1
fi

if [[ "${EUID}" != '0' ]]; then
  echo -e '\e[1;31mPlease run this script as root.\e[0m'
  exit 1
fi

mkdir -p "${TMPDIR}"
cd "${TMPDIR}"

trap "rm -rf '${TMPDIR}'" EXIT

echo '[+] Downloading libhoudini library...'
curl -#L "${PREBUILT}" -o libhoudini.tar.gz

echo '[+] Decompressing libhoudini library...'
tar -x --strip-components=1 -f libhoudini.tar.gz

echo '[+] Copying files...'
mkdir -p "${DESTDIR}/system"
cp -r prebuilts/* "${DESTDIR}/system"

echo -e '\e[1;34m'
cat <<EOT
Installation completed!

Append the following into /var/lib/waydroid/waydroid.cfg to
activite libhoudini (remove existing "[properties]" section if any):

[properties]
ro.product.cpu.abilist = x86_64,x86,armeabi-v7a,armeabi,arm64-v8a
ro.product.cpu.abilist32 = x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64 = x86_64,arm64-v8a
ro.dalvik.vm.isa.arm = x86
ro.dalvik.vm.isa.arm64 = x86_64
ro.enable.native.bridge.exec = 1
ro.enable.native.bridge.exec64 = 1
ro.dalvik.vm.native.bridge = libhoudini.so
EOT
echo -e '\e[0m'
