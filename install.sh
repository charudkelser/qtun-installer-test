#!/bin/sh

echo "========================================"
echo "      QTUN AUTO INSTALLER TEST 1.1"
echo "========================================"
echo

echo "[+] Detecting OpenWrt..."

if [ -f /etc/openwrt_release ]; then
    . /etc/openwrt_release

    echo "[OK] OpenWrt      : $DISTRIB_RELEASE"
    echo "[OK] Version       : $DISTRIB_REVISION"
else
    echo "[ERROR] OpenWrt tidak terdeteksi!"
    exit 1
fi

echo
echo "[+] Machine..."

MACHINE="$(uname -m)"

echo "[OK] Machine       : $MACHINE"

echo
echo "========================================"
echo "      OPKG ARCHITECTURES"
echo "========================================"
echo

if command -v opkg >/dev/null 2>&1; then

    opkg print-architecture 2>/dev/null

else

    echo "[ERROR] opkg tidak ditemukan!"
    exit 1

fi

echo
echo "========================================"
echo "      ARCHITECTURE SUMMARY"
echo "========================================"
echo

echo "Semua architecture yang terdaftar:"
echo

opkg print-architecture 2>/dev/null |
while read -r TYPE ARCH PRIORITY
do
    if [ "$TYPE" = "arch" ]; then
        echo "  ARCH     : $ARCH"
        echo "  PRIORITY : $PRIORITY"
        echo
    fi
done

echo "========================================"
echo "      TEST 1.1 COMPLETED"
echo "========================================"
echo
echo "Tidak ada proses install."
echo "Tidak ada perubahan konfigurasi."
echo
