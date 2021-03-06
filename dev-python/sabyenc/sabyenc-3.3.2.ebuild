# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 vcs-snapshot

DESCRIPTION="Module providing raw yEnc encoding/decoding for SABnzbd"
HOMEPAGE="https://github.com/sabnzbd/sabyenc/"
SRC_URI="https://github.com/sabnzbd/${PN}/tarball/v${PV} -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="
	test? (	dev-python/pytest[${PYTHON_USEDEP}] )"

DOCS=( CHANGES.md README.md doc/yenc-draft.1.3.txt )

python_test() {
	# https://github.com/sabnzbd/sabyenc/pull/7
	cat <<-EOF > pytest.ini
		[pytest]
		norecursedirs = yencfiles
	EOF
	pytest -v || die "Test failed."
}
