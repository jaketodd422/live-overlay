# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools cvs eutils

DESCRIPTION="free lossless audio encoder and codec"
HOMEPAGE="http://flac.sourceforge.net"
ECVS_SERVER="flac.cvs.sourceforge.net:/cvsroot/flac"
ECVS_MODULE="flac"
ECVS_AUTH="pserver"
ECVS_USER="anonymous"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="3dnow altivec +cxx debug doc +ogg sse"

RDEPEND="ogg? ( >=media-libs/libogg-1.1.3 )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	!elibc_uclibc? ( sys-devel/gettext )
	dev-util/pkgconfig"

src_unpack() {
	cvs_src_unpack
	cd "${PN}"
	#eautoreconf
	./autogen.sh
}

src_configure() {
	cd "${WORKDIR}/${PN}"
	econf $(use_enable ogg) \
		$(use_enable sse) \
		$(use_enable 3dnow) \
		$(use_enable altivec) \
		$(use_enable debug) \
		$(use_enable cxx cpplibs) \
		--disable-doxygen-docs \
		--disable-dependency-tracking \
		--disable-xmms-plugin
}

src_compile() {
	cd "${WORKDIR}/${PN}"
	emake || die "emake failed"
}

src_install() {
	cd "${WORKDIR}/${PN}"
	emake DESTDIR="${D}" install || die "emake install failed."

	rm -rf "${D}"/usr/share/doc/${P}
	dodoc AUTHORS README
	use doc && dohtml -r doc/html/*
}
