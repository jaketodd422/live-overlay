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
IUSE="asm doc encode examples pic static test"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig"
RDEPEND="media-libs/libogg
	encode? ( media-libs/libvorbis )"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	subversion_bootstrap
}

src_configure() {
	use x86 && filter-flags -fforce-addr -frename-registers
	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"

	conf=""
	if use static && use !pic; then
		conf="--enable-static --disable-shared"
	else
		ewarn "static and pic cannot be enabled at the same time."
		die
	fi

	econf \
	$(use_enable encode) \
	$(use_with pic) \
	$(use_enable asm) \
	$(use_enable test oggtest vorbistest sdltest valgrind-testing) \
	$(use_enable examples) \
	${conf}
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
