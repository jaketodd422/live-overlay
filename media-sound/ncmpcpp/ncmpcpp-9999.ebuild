# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit git

DESCRIPTION="An ncurses mpd client, ncmpc clone with some new features, written in C++"
HOMEPAGE="http://unkart.ovh.org/ncmpcpp"
EGIT_REPO_URI="git://repo.or.cz/ncmpcpp.git"
EGIT_BOOTSTRAP="autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="clock curl iconv output taglib +threads unicode visualizer"

DEPEND="sys-libs/ncurses[unicode?]
	curl? ( net-misc/curl )
	iconv? ( virtual/libiconv )
	taglib? ( media-libs/taglib )
	visualizer? ( sci-libs/fftw )"
RDEPEND="${DEPEND}"

src_unpack() {
	git_src_unpack
}

src_configure() {
	econf $(use_enable output outputs) \
		$(use_enable clock) \
		$(use_enable unicode) \
		$(use_enable visualizer ) \
		$(use_with curl) \
		$(use_with iconv) \
		$(use_with threads) \
		$(use_with taglib) 
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" install || die "emake failed"
}
