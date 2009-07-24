# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils subversion

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg"
ESVN_REPO_URI="http://svn.xiph.org/trunk/ogg/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	subversion_src_unpack
}

src_configure() {
	./autogen.sh --prefix=/usr
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
	dodoc CHANGES AUTHORS

	find "${D}" -name '*.la' -delete
}
