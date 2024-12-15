#!/bin/bash -eu
RUNPWD="${PWD}"
TMPDIR=/tmp/libndk-installer
DESTDIR="$(readlink -f "${1:-/var/lib/waydroid/overlay}")"

NDK_PREBUILT=(
  'https://github.com/supremegamers/vendor_google_proprietary_ndk_translation-prebuilt/archive/a090003c60df53a9eadb2df09bd4fd2fa86ea629.tar.gz'
  '0e486faea09e322c12eb36d7cb4d5318c1b3791030c3be4f7d80af29dff62763'
)

# thanks to casualsnek/waydroid_script for props and filelist!
PROP="[properties]\n\
ro.product.cpu.abilist = x86_64,x86,armeabi-v7a,armeabi,arm64-v8a\n\
ro.product.cpu.abilist32 = x86,armeabi-v7a,armeabi\n\
ro.product.cpu.abilist64 = x86_64,arm64-v8a\n\
ro.dalvik.vm.native.bridge = libndk_translation.so\n\
ro.enable.native.bridge.exec = 1\n\
ro.vendor.enable.native.bridge.exec = 1\n\
ro.vendor.enable.native.bridge.exec64 = 1\n\
ro.ndk_translation.version = 0.2.3\n\
ro.dalvik.vm.isa.arm = x86\n\
ro.dalvik.vm.isa.arm64 = x86_64"

FILES=(
  bin/arm
  bin/arm64
  bin/ndk_translation_program_runner_binfmt_misc
  bin/ndk_translation_program_runner_binfmt_misc_arm64
  etc/binfmt_misc
  etc/ld.config.arm.txt
  etc/ld.config.arm64.txt
  etc/init/ndk_translation.rc
  lib/arm
  lib64/arm64
  lib/libndk*
  lib64/libndk*
)

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  echo 'Usage: ./install-libndk-a13.sh [optional: destination]'
  exit 1
fi

if [[ "${EUID}" != '0' ]]; then
  echo -e '\e[1;31mPlease run this script as root.\e[0m'
  exit 1
fi

mkdir -p "${TMPDIR}"
cd "${TMPDIR}"

trap "rm -rf '${TMPDIR}'" EXIT

echo '[+] Downloading libndk library...'
curl -#L "${NDK_PREBUILT[0]}" -o libndk.tar.gz
sha256sum -c - <<< "${NDK_PREBUILT[1]} libndk.tar.gz"

echo '[+] Decompressing libndk library...'
tar -x --strip-components=1 -f libndk.tar.gz

echo '[+] Copying files...'
mkdir -p "${DESTDIR}/system"

for file in "${FILES[@]}"; do
  cp -r prebuilts/${file} "${DESTDIR}/system"
done

echo '[+] Updating props...'
if grep -q '\[properties\]' /var/lib/waydroid/waydroid.cfg; then
  sed -i "s#\[properties\]#${PROP}#" /var/lib/waydroid/waydroid.cfg
else
  echo -e "${PROP}\n" >> /var/lib/waydroid/waydroid.cfg
fi

echo -e '\e[1;34mAll done!\e[0m'
