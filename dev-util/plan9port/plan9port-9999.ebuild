# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit mercurial

DESCRIPTION="Plan 9 from User Space"
HOMEPAGE="http://swtch.com/plan9port"
EHG_REPO_URI="http://code.swtch.com/plan9port"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="x11-base/xorg-server"
RDEPEND="${DEPEND}"

S="${WORKDIR}/plan9port"

src_unpack() {
	mercurial_src_unpack
}

src_prepare() {
	cd "${S}"
	rm -rf .hg
}

src_compile() {
	einfo "                                                             "
	einfo "Compiling Plan 9 from User Space can take a very long time   "
	einfo "depending on the speed of your computer. Please be patient!  "
	einfo "                                                             "
	./INSTALL -b
}

src_install() {
	cd "${S}"
	dodir /usr/lib/plan9
	mv "${S}" "${D}"/usr/lib/
	doenvd "${FILESDIR}/30plan9"
}

pkg_postinst() {
	einfo "                                                             "
	einfo "Recalibrating Plan 9 from User Space to its new environment. "
	einfo "This could take a while...                                   "
	einfo "                                                             "

	cd /usr/lib/plan9
	export PATH="$PATH:/usr/lib/plan9"
	./INSTALL -c &> /dev/null

	elog "                                                             "
	elog "Plan 9 from User Space has been successfully installed into  "
	elog "/usr/lib/plan9. Your PLAN9 and PATH environment variables    "
	elog "have also been appropriately set, please use env-update and  "
	elog "source /etc/profile to bring that into immediate effect.     "
	elog "                                                             "
	elog "Please note that \${PLAN9}/bin has been appended to the *end*"
	elog "or your PATH to prevent conflicts. To use the Plan9 versions "
	elog "of common UNIX tools, use the absolute path:                 "
	elog "/usr/lib/plan9/bin or the 9 command (eg: 9 troff)            "
	elog "                                                             "
	elog "Please report any bugs to bugs.gentoo.org, NOT Plan9Port.    "
	elog "                                                             "
}
