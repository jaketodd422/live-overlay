# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools subversion

DESCRIPTION="The Ogg Vorbis sound file format library with aoTuV patch"
HOMEPAGE="http://xiph.org/vorbis"
ESVN_REPO_URI="http://svn.xiph.org/trunk/vorbis/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="dev-util/pkgconfig"
RDEPEND="media-libs/libogg"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	AT_M4DIR="m4" eautoreconf
}
<<<<<<< HEAD

=======
>>>>>>> experimental
src_configure() {
	econf --disable-docs --disable-oggtest
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
}
