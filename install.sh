#!/bin/sh

echo "========================================"
echo "       QTUN AUTO INSTALLER TEST"
echo "========================================"
echo

# ==============================
# DETECT OPENWRT
# ==============================

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

# ==============================
# DETECT OPKG ARCHITECTURE
# ==============================

echo "[+] Detecting package architecture..."

ARCH="$(opkg print-architecture 2>/dev/null | awk 'NR==2 {print $2}')"

if [ -z "$ARCH" ]; then
    echo "[WARN] opkg architecture tidak ditemukan."
    ARCH="unknown"
fi

echo "[OK] Architecture : $ARCH"

echo

# ==============================
# DETECT MACHINE
# ==============================

echo "[+] Detecting machine..."

MACHINE="$(uname -m)"

echo "[OK] Machine       : $MACHINE"

echo

# ==============================
# DETECT TARGET
# ==============================

echo "[+] Detecting OpenWrt target..."

TARGET="$(ubus call system board 2>/dev/null | sed -n 's/.*"target": *"\([^"]*\)".*/\1/p')"

if [ -z "$TARGET" ]; then
    TARGET="unknown"
fi

echo "[OK] Target        : $TARGET"

echo

# ==============================
# SUMMARY
# ==============================

echo "========================================"
echo "        DETECTION COMPLETED"
echo "========================================"
echo
echo "OpenWrt      : $DISTRIB_RELEASE"
echo "Revision     : $DISTRIB_REVISION"
echo "Architecture : $ARCH"
echo "Machine      : $MACHINE"
echo "Target       : $TARGET"
echo
echo "========================================"
echo " Installation NOT performed."
echo " This is TEST MODE."
echo "========================================"
