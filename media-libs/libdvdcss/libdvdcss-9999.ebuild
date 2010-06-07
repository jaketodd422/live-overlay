# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit subversion

DESCRIPTION="A portable library for DVD decryption"
HOMEPAGE="http://www.videolan.org/developers/libdvdcss.html"
ESVN_REPO_URI="svn://svn.videolan.org/libdvdcss/trunk"
ESVN_BOOTSTRAP="bootstrap"
ESVN_PROJECT="libdvdcss"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="static doc pic"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	conf=""
	if use static; then
		conf="--enable-static --disable-shared"
	fi
}

src_configure() {
	cd ${ESVN_PROJECT}/trunk
	subversion_bootstrap

	econf \
	$(use_enable doc) \
	$(use_with pic) \
	${conf}
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
