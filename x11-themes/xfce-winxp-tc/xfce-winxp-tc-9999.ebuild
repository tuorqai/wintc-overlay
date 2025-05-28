# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# This ebuild doesn't use packaging/buildall.sh.
# Sadly, those scripts are overly complicated and oriented for
# binary distros, thus unsuited for source-based distros like Gentoo.
# Instead, this ebuild calls CMake directly.

EAPI=8

inherit git-r3

DESCRIPTION="Windows XP Total Conversion for Xfce"
HOMEPAGE="https://github.com/rozniak/xfce-winxp-tc"

EGIT_REPO_URI="https://github.com/rozniak/xfce-winxp-tc.git"
EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64"
IUSE="lightdm plymouth webkit +shell +themes +fonts +sounds +wallpapers"

DEPEND="shell? (
		dev-libs/glib:2
		dev-libs/libzip
		dev-python/packaging
		dev-db/sqlite
		media-libs/libcanberra
		media-libs/libcanberra-gtk3
		net-misc/networkmanager
		sys-power/upower
		x11-libs/gdk-pixbuf:2
		x11-libs/gtk+:3
		xfce-base/garcon
		lightdm? ( x11-misc/lightdm )
		webkit? ( net-libs/webkit-gtk:4.1 )
	)"

RDEPEND="${DEPEND}
	shell? (
		x11-misc/xdg-utils
		plymouth? ( sys-boot/plymouth )
	)"

BDEPEND="shell? ( sys-devel/gettext )
	themes? (
		dev-lang/python
		dev-ruby/sass
		x11-apps/xcursorgen
	)
	virtual/pkgconfig"

# This needed for themes to compile.
RESTRICT="network-sandbox"

# This list is sorted according to dependencies.
wintc_shlibs="shared/comgtk
	shared/shcommon
	shared/shlang
	shared/comctl
	shared/exec
	shared/winbrand
	shared/registry
	shared/shellext
	shared/shell
	shared/shelldpa
	shared/sndapi
	shared/syscfg"

wintc_targets=""

src_prepare() {
	mkdir -p "${S}/shell/cpl/sysdm/res/raw"
	cp "${FILESDIR}/gentoo-logo.png" "${S}/shell/cpl/sysdm/res/raw/gentoo.png"
	default
}

src_configure() {
	if use shell ; then
		wintc_targets="base/bldtag
			${wintc_shlibs}
			base/regsvc
			shell/cpl/desk
			shell/cpl/printers
			shell/cpl/sysdm
			shell/desktop
			shell/run
			shell/shext/zip
			shell/taskband
			shell/winver
			windows/notepad
			windows/taskmgr"

		if use lightdm ; then
			wintc_targets="${wintc_targets}
				shared/msgina
				base/logonui"
		fi

		use plymouth && wintc_targets="${wintc_targets} base/bootvid"
		use webkit && wintc_targets="${wintc_targets} shell/explorer"
	fi

	if use themes ; then
		wintc_targets="${wintc_targets}
			cursors/no-shadow/standard
			cursors/with-shadow/standard
			icons/luna
			themes/native
			themes/professional
			themes/luna/blue
			themes/luna/homestead
			themes/luna/metallic
			themes/zune"
	fi

	use fonts && wintc_targets="${wintc_targets} fonts"
	use sounds && wintc_targets="${wintc_targets} sounds"
	use wallpapers && wintc_targets="${wintc_targets} wallpapers"

	for target in ${wintc_targets}; do
		einfo "[wintc] Configuring target: ${target}"

		mkdir -p "${S}/build/${target}"
		cd "${S}/build/${target}"

		cmake -DBUILD_SHARED_LIBS=ON \
			-DCMAKE_BUILD_TYPE="Release" \
			-DCMAKE_INSTALL_PREFIX="/usr" \
			-DWINTC_SKU="xpclient-pro" \
			-DWINTC_PKGMGR="raw" \
			-DWINTC_PKGMGR_EXT="std" \
			-DWINTC_USE_LOCAL_LIBS="1" \
			-DWINTC_LOCAL_LIBS_ROOT="${S}/build" \
			"${S}/${target}"

		# Hack: we have to build shared libraries in configure stage
		# due to CMake's weird behavior.
		# The thing is, if .so files are not there during the
		# configuration stage, then CMake will replace full paths
		# to .so files with generic ones, e.g. just 'libwintc-shcommon'
		# instead of its full path. We don't want this.
		#
		# Fixme: find a way to tell CMake to stop doing what it
		# shouldn't.
		case "${target}" in
			shared*)
				einfo "[wintc] Pre-building shared library: ${target}"
				emake
			;;
		esac
	done
}

src_compile() {
	for target in ${wintc_targets}; do
		case "${target}" in
			shared*)
				continue
			;;
		esac

		einfo "[wintc] Compiling target: ${target}"

		cd "${S}/build/${target}"
		emake
	done
}

src_install() {
	for target in ${wintc_targets}; do
		einfo "[wintc] Installing target: ${target}"

		cd "${S}/build/${target}"
		emake DESTDIR="${D}" install
	done
}
