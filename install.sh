#!/bin/sh

echo "========================================"
echo "      QTUN AUTO INSTALLER TEST 1.2"
echo "========================================"
echo

# ==============================
# OPENWRT
# ==============================

if [ -f /etc/openwrt_release ]; then
    . /etc/openwrt_release
else
    echo "[ERROR] OpenWrt tidak terdeteksi!"
    exit 1
fi

echo "[OK] OpenWrt : $DISTRIB_RELEASE"
echo "[OK] Revision : $DISTRIB_REVISION"

# ==============================
# MACHINE
# ==============================

MACHINE="$(uname -m)"

echo "[OK] Machine : $MACHINE"

# ==============================
# TARGET
# ==============================

TARGET="$(ubus call system board 2>/dev/null |
    sed -n 's/.*"target": *"\([^"]*\)".*/\1/p')"

echo "[OK] Target  : $TARGET"

echo
echo "========================================"
echo "      ANALYZING OPKG ARCHITECTURE"
echo "========================================"
echo

BEST_ARCH=""
BEST_PRIORITY=0

opkg print-architecture 2>/dev/null |
while read -r TYPE ARCH PRIORITY
do
    [ "$TYPE" = "arch" ] || continue

    echo "[FOUND] $ARCH (priority $PRIORITY)"

done

echo
echo "========================================"
echo "      CANDIDATE ARCHITECTURES"
echo "========================================"
echo

# Cari architecture non-all dengan priority tertinggi.
# Hasil disimpan sementara agar bisa dipakai setelah loop.

TMP="/tmp/qtun_arch_test"

opkg print-architecture 2>/dev/null |
awk '$1 == "arch" && $2 != "all" {print $2, $3}' |
sort -k2,2nr > "$TMP"

if [ -s "$TMP" ]; then

    echo "[+] Priority order:"

    while read -r ARCH PRIORITY
    do
        echo "    $ARCH -> $PRIORITY"
    done < "$TMP"

    BEST_ARCH="$(head -n 1 "$TMP" | awk '{print $1}')"
    BEST_PRIORITY="$(head -n 1 "$TMP" | awk '{print $2}')"

else

    echo "[WARN] Tidak ada architecture non-all."
fi

rm -f "$TMP"

echo
echo "========================================"
echo "      DETECTION RESULT"
echo "========================================"
echo

echo "Machine        : $MACHINE"
echo "Target         : $TARGET"
echo "Selected Arch  : $BEST_ARCH"
echo "Priority       : $BEST_PRIORITY"

echo
echo "========================================"
echo "      TEST 1.2 COMPLETED"
echo "========================================"
echo
echo "Tidak ada proses install."
echo "Tidak ada perubahan konfigurasi."
