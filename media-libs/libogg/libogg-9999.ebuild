# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit subversion

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg"
ESVN_REPO_URI="http://svn.xiph.org/trunk/ogg/"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="static pic"

DEPEND=""
RDEPEND=""

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	subversion_bootstrap
}

src_configure() {
	conf=""
	if use static && use !pic; then
		conf="--enable-static --disable-shared"
	else
		ewarn "static and pic cannot be enabled at the same time."
		die
	fi

	econf \
	$(use_with pic) \
	${conf}
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
	dodoc CHANGES AUTHORS

	find "${D}" -name '*.la' -delete
}
