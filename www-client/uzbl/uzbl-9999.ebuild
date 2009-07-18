# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils git

DESCRIPTION="A webkit based browser adhering to the UNIX philosophy"
HOMEPAGE="http://uzbl.org"
EGIT_BRANCH="experimental"
EGIT_REPO_URI="git://github.com/Dieterbe/uzbl.git"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86 ~amd64"

DEPEND=">=net-libs/webkit-gtk-1.1.4
		net-libs/libsoup
		x11-libs/gtk+
		dev-util/pkgconfig"
RDEPEND="${DEPEND}"

src_unpack() {
	git_src_unpack

	cd "${S}"
	epatch "${FILESDIR}/${PN}-Makefile-fix.patch"
}

src_compile() {
	emake || die "make failed!"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed!"
	dodoc README AUTHORS
}

pkg_postinst() {
	einfo "You need to make a configuration files in $HOME/.config/uzbl. An"
	einfo "example is in /usr/share/doc/${PN}/examples/config/${PN}."
}
