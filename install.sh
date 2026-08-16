#!/bin/sh

VERSION="1.0.6"
REPO="charudkelser/luci-app-qtun"
BASE_URL="https://github.com/$REPO/releases/download/v$VERSION"

echo "========================================"
echo "      QTUN AUTO INSTALLER TEST 2"
echo "========================================"
echo

# ==============================
# DETECT OPENWRT
# ==============================

if [ ! -f /etc/openwrt_release ]; then
    echo "[ERROR] OpenWrt tidak terdeteksi!"
    exit 1
fi

. /etc/openwrt_release

echo "[OK] OpenWrt : $DISTRIB_RELEASE"
echo "[OK] Revision : $DISTRIB_REVISION"

# ==============================
# DETECT MACHINE
# ==============================

MACHINE="$(uname -m)"

echo "[OK] Machine : $MACHINE"

# ==============================
# DETECT OPKG ARCHITECTURE
# ==============================

BEST_ARCH=""
BEST_PRIORITY=""

while read -r TYPE ARCH PRIORITY
do
    [ "$TYPE" = "arch" ] || continue
    [ "$ARCH" = "all" ] && continue

    if [ -z "$BEST_PRIORITY" ] || [ "$PRIORITY" -gt "$BEST_PRIORITY" ]; then
        BEST_ARCH="$ARCH"
        BEST_PRIORITY="$PRIORITY"
    fi
done <<EOF
$(opkg print-architecture 2>/dev/null)
EOF

if [ -z "$BEST_ARCH" ]; then
    echo "[ERROR] Architecture tidak ditemukan!"
    exit 1
fi

echo "[OK] Selected Arch : $BEST_ARCH"
echo "[OK] Priority      : $BEST_PRIORITY"

echo
echo "========================================"
echo "      PACKAGE DETECTION"
echo "========================================"
echo

# ==============================
# SPECIFIC PACKAGE
# ==============================

SPECIFIC_PACKAGE="luci-app-qtun_${VERSION}_${BEST_ARCH}.ipk"
SPECIFIC_URL="$BASE_URL/$SPECIFIC_PACKAGE"

echo "[+] Checking specific package..."
echo "    $SPECIFIC_PACKAGE"

if wget --no-check-certificate --spider -q "$SPECIFIC_URL" 2>/dev/null; then

    echo "[OK] Specific package FOUND!"
    SELECTED_PACKAGE="$SPECIFIC_PACKAGE"
    SELECTED_URL="$SPECIFIC_URL"
    PACKAGE_TYPE="ARCHITECTURE-SPECIFIC"

else

    echo "[INFO] Specific package NOT FOUND."

    # ==============================
    # UNIVERSAL FALLBACK
    # ==============================

    UNIVERSAL_PACKAGE="luci-app-qtun_${VERSION}_all.ipk"
    UNIVERSAL_URL="$BASE_URL/$UNIVERSAL_PACKAGE"

    echo
    echo "[+] Checking universal package..."
    echo "    $UNIVERSAL_PACKAGE"

    if wget --no-check-certificate --spider -q "$UNIVERSAL_URL" 2>/dev/null; then

        echo "[OK] Universal package FOUND!"

        SELECTED_PACKAGE="$UNIVERSAL_PACKAGE"
        SELECTED_URL="$UNIVERSAL_URL"
        PACKAGE_TYPE="UNIVERSAL"

    else

        echo "[ERROR] No compatible package found!"
        echo
        echo "Architecture : $BEST_ARCH"
        echo "Version      : $VERSION"
        exit 1
    fi
fi

echo
echo "========================================"
echo "      PACKAGE SELECTION RESULT"
echo "========================================"
echo

echo "Architecture : $BEST_ARCH"
echo "Package      : $SELECTED_PACKAGE"
echo "Type         : $PACKAGE_TYPE"
echo "URL          : $SELECTED_URL"

echo
echo "========================================"
echo "      TEST 2 COMPLETED"
echo "========================================"
echo
echo "Package ditemukan."
echo "Tidak ada download."
echo "Tidak ada proses install."
echo "Tidak ada perubahan sistem."
echo
