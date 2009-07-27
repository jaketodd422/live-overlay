# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit cvs

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net"
ECVS_SERVER="lame.cvs.sourceforge.net:/cvsroot/lame"
ECVS_MODULE="lame"
ECVS_AUTH="pserver"
ECVS_USER="anonymous"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="mmx debug sndfile"

DEPEND="${RDEPEND}
		dev-util/pkgconfig
		mmx? ( dev-lang/nasm )"
RDEPEND="sys-libs/ncurses
		sndfile? ( media-libs/libsndfile )"

src_unpack() {
	cvs_src_unpack
}

src_configure() {

	if use sndfile; then
		lameconf="--with-fileio=sndfile"
	fi

	econf \
		--prefix=/usr \
		--disable-frontend \
		--enable-brhist \
		--enable-all-float \
		$(use_enable debug debug norm)
		$(use_enable mmx nasm) \
		${lameconf}
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
