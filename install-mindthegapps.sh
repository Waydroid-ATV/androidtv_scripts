#!/bin/bash -eu
RUNPWD="${PWD}"
TMPDIR=/tmp/mindthegapps-converter

GAPPS_PREBUILT=(
  'https://github.com/Waydroid-ATV/mindthegapps_tv/releases/download/MindTheGapps-13.0.0-x86_64-ATV-20241215_054204/MindTheGapps-13.0.0-x86_64-ATV-full-20241215_054204.zip'
  '868e82038c7071f102f5d8c31eb272bd0d571f6eebccb0e64122389b3d34894f'
)

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  echo 'Usage: ./install-mindthegapps.sh [optional: destination]'
  exit 1
fi

if [[ "${EUID}" != '0' ]]; then
  echo -e '\e[1;31mPlease run this script as root.\e[0m'
  exit 1
fi

if [ ! -d "${1:-/var/lib/waydroid/overlay}" ]; then
  echo -e "\e[1;31mError: destination path ${1:-/var/lib/waydroid/overlay} does not exist!\e[0m"
  exit 1
fi

DESTDIR="$(readlink -f "${1:-/var/lib/waydroid/overlay}")"

mkdir -p "${DESTDIR}" "${TMPDIR}/installer"
cd "${TMPDIR}"

trap "rm -rf '${TMPDIR}'" EXIT

echo '[+] Downloading MindTheGapps installer...'
curl -#L "${GAPPS_PREBUILT[0]}" -o mindthegapps.zip
sha256sum -c - <<< "${GAPPS_PREBUILT[1]} mindthegapps.zip"

echo '[+] Decompressing MindTheGapps installer...'
unzip -q mindthegapps.zip -d installer

echo '[+] Copying files...'

mkdir -p "${DESTDIR}/system"
cp -r installer/system/system/* "${DESTDIR}/system" && rm -r installer/system/system
cp -r installer/system/* "${DESTDIR}/system"

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

