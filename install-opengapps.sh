#!/bin/bash -eu
RUNPWD="${PWD}"
TMPDIR=/tmp/opengapps-converter/

if [ -z "${1:-}" ]; then
  echo 'Usage: ./install-opengapps.sh [OpenGApps flashable ZIP] [optional: destination]'
  exit 1
fi

if [[ "${EUID}" != '0' ]]; then
  echo -e '\e[1;31mPlease run this script as root.\e[0m'
  exit 1
fi

if [ ! -f "${1}" ]; then
  echo -e "\e[1;31mError: file ${1} does not exist!\e[0m"
  exit 1
fi

if [ ! -d "${2:-/var/lib/waydroid/overlay}" ]; then
  echo -e "\e[1;31mError: destination path ${2:-/var/lib/waydroid/overlay} does not exist!\e[0m"
  exit 1
fi

ZIPFILE="$(readlink -f "${1}")"
DESTDIR="$(readlink -f "${2:-/var/lib/waydroid/overlay}")"

# blacklist for skip convert
BLACKLIST=(
  packageinstallergoogle-all
)

mkdir -p "${DESTDIR}" "${TMPDIR}/installer"
cd "${TMPDIR}"

trap "rm -rf '${TMPDIR}'" EXIT

echo '[+] Decompressing OpenGApps installer...'
unzip -q "${ZIPFILE}" -d installer

for c in Core GApps; do
  for archive in installer/$c/*.tar.lz; do
    pkgName="$(basename -s .tar.lz "${archive}")"
    archiveContent="$(tar -tf "${archive}")"

    if [[ "${BLACKLIST[*]}" =~ "${pkgName}" ]]; then
      echo -e "\e[1;33m[+] Skip converting ${pkgName}\e[0m"
      continue
    fi

    echo "[+] Converting ${pkgName}..."
    tar -x --strip-components=2 -f "${archive}" -C "${DESTDIR}/system"
  done
done

# whiteout TVLauncherNoGMS
echo '[+] Disabling LineageOS built-in launcher...'
mkdir -p "${DESTDIR}/system/product/priv-app/"
mknod "${DESTDIR}/system/product/priv-app/TVLauncherNoGMS" c 0 0

echo -e '\e[1;34m'
cat <<EOT
All done!

[IMPORTANT]: In order to log in with your Google account, you must complete Google Play certification for your installation.

             See https://docs.waydro.id/faq/google-play-certification for detailed instructions.
EOT
echo -e '\e[0m'
