#!/bin/bash -eu
RUNPWD="${PWD}"
TMPDIR=/tmp/widevine-installer
DESTDIR="$(readlink -f "${1:-/var/lib/waydroid/overlay}")"

WIDEVINE_PREBUILT=(
  'https://github.com/supremegamers/vendor_google_proprietary_widevine-prebuilt/archive/a8524d608431573ef1c9313822d271f78728f9a6.tar.gz'
  'a8954ce99e74f48fcd10bc41544c70e5116ca6a6d0dfed6da5426814ca51f7ae'
)

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  echo 'Usage: ./install-widevine-a13.sh [optional: destination]'
  exit 1
fi

if [[ "${EUID}" != '0' ]]; then
  echo -e '\e[1;31mPlease run this script as root.\e[0m'
  exit 1
fi

mkdir -p "${TMPDIR}"
cd "${TMPDIR}"

trap "rm -rf '${TMPDIR}'" EXIT

echo '[+] Downloading Widevine L3 library...'
curl -#L "${WIDEVINE_PREBUILT[0]}" -o widevine.tar.gz
sha256sum -c - <<< "${WIDEVINE_PREBUILT[1]} widevine.tar.gz"

echo '[+] Decompressing Widevine L3 library...'
tar -x --strip-components=1 -f widevine.tar.gz

echo '[+] Copying files...'
mkdir -p "${DESTDIR}/vendor"
rm -f prebuilts/{lib,lib64}/libprotobuf-cpp-{full,lite}-3.9.1.so
cp -r prebuilts/* "${DESTDIR}/vendor"

echo -e '\e[1;34mAll done!\e[0m'
