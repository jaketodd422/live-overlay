# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit subversion

DESCRIPTION="tools for using the Ogg Vorbis sound file format"
HOMEPAGE="http://vorbis.com"
ESVN_REPO_URI="http://svn.xiph.org/trunk/vorbis-tools"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="flac nls ogg123 speex threads"

DEPEND="${RDEPEND}
		nls? ( sys-devel/gettext )
		dev-util/pkgconfig"
RDEPEND=">=media-libs/libvorbis-1.1
		flac? ( media-libs/flac )
		ogg123? ( media-libs/libao net-misc/curl )
		speex? ( media-libs/speex )"

src_unpack() {
	subversion_src_unpack
}

src_configure() {
	econf \
		$(use_with flac) \
		$(use_enable nls) \
		$(use_enable ogg123) \
		$(use_with speex) \
		$(use_enable threads) \
	|| die "econf failed"

}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake docdir="/usr/share/doc/${PF}" DESTDIR="${D}" install \
	|| die "emake install failed"

	dodoc AUTHORS CHANGES README
}
