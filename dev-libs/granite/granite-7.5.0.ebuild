# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BUILD_DIR="${WORKDIR}/${P}-build"

inherit meson vala xdg

DESCRIPTION="Elementary OS library that extends GTK+"
HOMEPAGE="https://github.com/elementary/granite"
SRC_URI="https://github.com/elementary/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3+"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm ~x86"

BDEPEND="
	$(vala_depend)
	virtual/pkgconfig
"
DEPEND="
	gui-libs/gtk:4[introspection]
	dev-lang/sassc
	dev-libs/libgee:0.8[introspection]
"
RDEPEND="${DEPEND}"

src_prepare() {
	default
	vala_setup
}

src_configure() {
	meson_src_configure
}
