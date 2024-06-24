# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

NODEJS_MOD_PREFIX="webui"
inherit go-module nodejs nodejs-mod tmpfiles systemd

DESCRIPTION="A web UI and orchestrator for restic backup"
HOMEPAGE="https://github.com/garethgeorge/backrest"

SRC_URI="https://github.com/garethgeorge/backrest/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://raw.githubusercontent.com/inode64/inode64-overlay/main/dist/${P}-vendor.tar.xz
	https://www.inode64.com/dist/${P}-node_modules.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-backup/restic"

src_configure() {
	export CGO_ENABLED=1
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CPPFLAGS="${CPPFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	default
}

src_compile() {
	nodejs-mod_src_compile
	pushd webui >/dev/null || die
	enpm_clean
	# Fix go test
	gzip -k dist/index.html || die
	popd >/dev/null || die
	ego build -trimpath -ldflags "-s -w" -o backrest ./cmd/backrest || die
}

src_test() {
	BACKREST_RESTIC_COMMAND=/usr/bin/restic ego test ./... || die "test failed"
}

src_install() {
	dobin backrest

	dodoc *.md

	dotmpfiles "${FILESDIR}/${PN}.tmpfiles.conf"

	newinitd "${FILESDIR}/${PN}.initd" ${PN}

	systemd_dounit "${FILESDIR}/${PN}.service"
}

pkg_postinst() {
	tmpfiles_process backrest.tmpfiles.conf
}
