# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils git

DESCRIPTION="An ncurses mpd client, ncmpc clone with some new features, written in C++"
HOMEPAGE="http://unkart.ovh.org/ncmpcpp"
EGIT_REPO_URI="git://repo.or.cz/ncmpcpp.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="clock curl iconv output taglib +threads unicode"

DEPEND="sys-libs/ncurses[unicode?]
	curl? ( net-misc/curl )
	iconv? ( virtual/libiconv )
	taglib? ( media-libs/taglib )"
RDEPEND="${DEPEND}"

src_unpack() {
	git_src_unpack
}

src_configure() {
	einfo "Running autogen.sh..."
	./autogen.sh

	local localconf

	if use clock; then
		localconf="--enable-clock"
	else
		localconf="--disable-clock"
	fi

	if use outputs; then
		localconf="--enable-outputs"
	else
		localconf="--disable-outputs"
	fi
	
	if use taglib; then
		localconf="--with-taglib"
	else
		localconf="--without-taglib"
	fi


	econf \
		$(use_enable curl) \
		$(use_enable threads) \
		${localconf}
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" install || die "emake failed"
}
