# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils flag-o-matic subversion

DESCRIPTION="The Theora video compression codec"
HOMEPAGE="http://theora.org"
ESVN_REPO_URI="http://svn.xiph.org/trunk/theora/"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="encode doc"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig"
RDEPEND="media-libs/libogg
	encode? ( media-libs/libvorbis )"

src_unpack() {
	subversion_src_unpack
}

src_configure() {
	cd "${WORKDIR}/${P}"
	
	use x86 && filter-flags -fforce-addr -frename-registers
	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"
	
	econf \
		--prefix=/usr
		--disable-spec \
		$(use_enable encode) \
		--disable-oggtest \
		--disable-vorbistest \
		--disable-sdltest \
		--disable-examples \
		--disable-valgrind-testing
}

src_compile() {
	cd "${WORKDIR}/${P}"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" docdir=/usr/share/doc/${PF} \
		install || die "emake install failed"

	dodoc AUTHORS CHANGES README
	prepalldocs
}
