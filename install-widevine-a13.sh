#!/bin/bash -eu
RUNPWD="${PWD}"
TMPDIR=/tmp/widevine-installer
DESTDIR="$(readlink -f "${1:-/var/lib/waydroid/overlay}")"

WIDEVINE_PREBUILT=(
  'https://github.com/Waydroid-ATV/vendor_google_proprietary_widevine-prebuilt/archive/08d60acb521734bfaed4eddb8ccc66c7ac6b6e1d.tar.gz'
  '7ab48f84b8eb45b0c79485f8a99ae9c0106b77d3ee64b0b42eca658578c18ec6'
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
cp -r prebuilts/* "${DESTDIR}/vendor"

echo '[+] Fixing runtime dependency...'
ln -s libprotobuf-cpp-lite-3.9.1.so "${DESTDIR}/vendor/lib/libprotobuf-cpp-lite.so"
ln -s libprotobuf-cpp-lite-3.9.1.so "${DESTDIR}/vendor/lib64/libprotobuf-cpp-lite.so"

echo -e '\e[1;34mAll done!\e[0m'
