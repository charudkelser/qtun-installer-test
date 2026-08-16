#!/bin/sh

VERSION="1.0.6"
REPO="charudkelser/luci-app-qtun"
BASE_URL="https://github.com/$REPO/releases/download/v$VERSION"

FILE="/tmp/qtun-test-package.ipk"

echo "========================================"
echo "      QTUN AUTO INSTALLER TEST 3"
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

# ==============================
# PACKAGE DETECTION
# ==============================

echo
echo "========================================"
echo "      PACKAGE DETECTION"
echo "========================================"
echo

SPECIFIC_PACKAGE="luci-app-qtun_${VERSION}_${BEST_ARCH}.ipk"
SPECIFIC_URL="$BASE_URL/$SPECIFIC_PACKAGE"

echo "[+] Checking specific package..."
echo "    $SPECIFIC_PACKAGE"

if wget --no-check-certificate --spider -q "$SPECIFIC_URL" 2>/dev/null; then

    SELECTED_PACKAGE="$SPECIFIC_PACKAGE"
    SELECTED_URL="$SPECIFIC_URL"
    PACKAGE_TYPE="ARCHITECTURE-SPECIFIC"

    echo "[OK] Specific package FOUND!"

else

    echo "[INFO] Specific package NOT FOUND."

    UNIVERSAL_PACKAGE="luci-app-qtun_${VERSION}_all.ipk"
    UNIVERSAL_URL="$BASE_URL/$UNIVERSAL_PACKAGE"

    echo
    echo "[+] Checking universal package..."
    echo "    $UNIVERSAL_PACKAGE"

    if wget --no-check-certificate --spider -q "$UNIVERSAL_URL" 2>/dev/null; then

        SELECTED_PACKAGE="$UNIVERSAL_PACKAGE"
        SELECTED_URL="$UNIVERSAL_URL"
        PACKAGE_TYPE="UNIVERSAL"

        echo "[OK] Universal package FOUND!"

    else

        echo "[ERROR] No compatible package found!"
        exit 1
    fi
fi

# ==============================
# DOWNLOAD
# ==============================

echo
echo "========================================"
echo "      PACKAGE DOWNLOAD"
echo "========================================"
echo

rm -f "$FILE"

echo "[+] Downloading..."
echo
echo "    $SELECTED_PACKAGE"
echo

wget --no-check-certificate \
    -O "$FILE" \
    "$SELECTED_URL"

if [ $? -ne 0 ]; then
    echo
    echo "[ERROR] Download gagal!"
    rm -f "$FILE"
    exit 1
fi

# ==============================
# VERIFY FILE
# ==============================

if [ ! -s "$FILE" ]; then
    echo "[ERROR] File hasil download kosong!"
    rm -f "$FILE"
    exit 1
fi

SIZE="$(wc -c < "$FILE" | tr -d ' ')"

echo
echo "========================================"
echo "      PACKAGE INFORMATION"
echo "========================================"
echo

echo "Architecture : $BEST_ARCH"
echo "Package      : $SELECTED_PACKAGE"
echo "Type         : $PACKAGE_TYPE"
echo "Size         : $SIZE bytes"

# ==============================
# SHA256
# ==============================

echo
echo "[+] Calculating SHA256..."

if command -v sha256sum >/dev/null 2>&1; then
