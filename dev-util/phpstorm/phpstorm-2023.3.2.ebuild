# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit desktop wrapper xdg-utils

MY_PV="233.13135.108"
MY_PN="PhpStorm"

DESCRIPTION="A complete toolset for web, mobile and enterprise development"
HOMEPAGE="https://www.jetbrains.com/phpstorm/"
SRC_URI="https://download.jetbrains.com/webide/${MY_PN}-${PV}.tar.gz"

LICENSE="|| ( IDEA IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL-1.1 CPL-0.5 CPL-1.0
	EPL-1.0 EPL-2.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC JDOM
	LGPL-2.1+ LGPL-3 MIT MPL-1.0 MPL-1.1 OFL public-domain PSF-2 UoI-NCSA ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE="30bits"

RDEPEND="
	app-arch/brotli
	app-arch/zstd[lz4]
	app-crypt/argon2
	dev-libs/glib
	dev-libs/json-c
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0/3
	dev-libs/wayland
	media-fonts/dejavu
	media-libs/alsa-lib
	media-libs/harfbuzz[cairo,glib,graphite]
	media-libs/libpng:0=
	net-dns/avahi
	net-print/cups
	sys-apps/dbus
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libnotify
	x11-libs/pango
"

S="${WORKDIR}/${MY_PN}-${MY_PV}"
QA_PREBUILT="opt/${P}/*"

src_prepare() {
	default

	local remove_me=(
		help/ReferenceCardForMac.pdf
		lib/async-profiler/aarch64
		lib/async-profiler/amd64/dbghelp.dll
		lib/async-profiler/amd64/jniSymbolsResolver.dll
		lib/async-profiler/amd64/libasyncProfiler.dll
		lib/async-profiler/amd64/symsrv.dll
		lib/async-profiler/libasyncProfiler.dylib
		plugins/cwm-plugin/quiche-native/darwin-aarch64
		plugins/cwm-plugin/quiche-native/darwin-x86-64
		plugins/cwm-plugin/quiche-native/linux-aarch64
		plugins/cwm-plugin/quiche-native/win32-x86-64
		plugins/gateway-plugin/lib/remote-dev-workers/{remote-dev-worker-darwin-amd64,remote-dev-worker-darwin-arm64,remote-dev-worker-linux-arm64,remote-dev-worker-windows-amd64.exe,remote-dev-worker-windows-arm64.exe}
		plugins/platform-ijent-impl/ijent-aarch64-unknown-linux-musl-release
		plugins/platform-ijent-impl/ijent-x86_64-unknown-linux-musl-release
		plugins/remote-dev-server/selfcontained
		plugins/webp/lib/libwebp/linux/libwebp_jni.so
	)

	rm -rv "${remove_me[@]}" || die

	if use 30bits; then
		echo "-Dsun.java2d.opengl=true" >> bin/phpstorm64.vmoptions || die
	fi

	sed -i \
		-e "\$a\\\\" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$a# Disable automatic updates as these are handled through Gentoo's" \
		-e "\$a# package manager. See bug #704494" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$aide.no.platform.update=Gentoo" bin/idea.properties
}

src_install() {
	local DIR="/opt/${P}"
	local exe

	insinto "${DIR}"
	doins -r *

	# Set permissions for executables and libraries
	find -type f -name "*.so*" | while read exe; do
		fperms +x "${DIR}/${exe}"
	done
	find -type f -executable | while read exe; do
		fperms +x "${DIR}/${exe}"
	done

	make_wrapper "${PN}" "${DIR}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "phpstorm" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-clion-inotify-watches.conf" || die

	# create configuration for revdep-rebuild
	echo "SEARCH_DIRS=\"${DIR}\"" > "${T}/80${PN}" || die
	insinto "/etc/revdep-rebuild"
	doins "${T}/80${PN}"
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
