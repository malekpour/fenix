PKG_NAME="snaps"
PKG_VERSION="20240604"
PKG_SHA256="54122948be0ca189a3d6fb4ee04db8ccede2dbc825522860f05dc6ba41a1a401"
PKG_SOURCE_DIR="${PKG_NAME}-${PKG_VERSION}*"
PKG_SITE="$PACKAGES_URL/${PKG_NAME}"
PKG_URL="$PKG_SITE/${PKG_NAME}-$PKG_VERSION.tar.gz"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Snaps"
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

makeinstall_host() {
	ln -sf "$BUILD/$PKG_NAME-$PKG_VERSION" "$BUILD/$PKG_NAME"
}