# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit mercurial

DESCRIPTION="A port of various original Plan 9 tools for Unix"
HOMEPAGE="http://tools.suckless.org/9base"
EHG_REPO_URI="http://hg.suckless.org/9base"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	mercurial_src_unpack
}

src_prepare() {
	cd "${WORKDIR}/9base"

	sed -i \
		-e 's/\/usr\/local\/plan9/\/usr\/plan9/g' \
		config.mk || die "sed failed"
}

src_compile() {
	cd "${WORKDIR}/9base"

	emake || die "emake failed"
}

src_install() {
	cd "${WORKDIR}/9base"

	emake DESTDIR="${D}" install || die "emake install failed"
}
