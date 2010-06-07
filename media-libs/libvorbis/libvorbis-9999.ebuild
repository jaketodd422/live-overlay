# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools subversion

DESCRIPTION="The Ogg Vorbis sound file format library with aoTuV patch"
HOMEPAGE="http://xiph.org/vorbis"
ESVN_REPO_URI="http://svn.xiph.org/trunk/vorbis/"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc examples pic static test"

DEPEND="dev-util/pkgconfig"
RDEPEND="media-libs/libogg"

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
	$(use_enable doc docs) \
	$(use_enable examples) \
	$(use_enable test oggtest) \
	$(use_with pic) \
	${conf}
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
}
