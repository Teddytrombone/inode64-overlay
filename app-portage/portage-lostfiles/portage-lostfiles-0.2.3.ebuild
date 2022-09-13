# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

DISTUTILS_USE_SETUPTOOLS=rdepend

inherit distutils-r1

DESCRIPTION="A simple script to identify files not tracked by Portage package manager"
HOMEPAGE="https://github.com/gcarq/portage-lostfiles"
SRC_URI="https://github.com/gcarq/portage-lostfiles/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RDEPEND="dev-python/psutil[${PYTHON_USEDEP}]"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
