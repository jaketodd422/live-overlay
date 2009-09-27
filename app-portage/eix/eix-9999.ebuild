# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit subversion

DESCRIPTION="Search and query ebuilds, portage incl. local settings, ext.
overlays, version changes, and more"
HOMEPAGE="http://projects.gentooexperimental.org/eix"
ESVN_REPO_URI="https://svn.gentooexperimental.org/eix/trunk"
ESVN_BOOTSTRAP="autogen.sh"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc nls separate sqlite"

DEPEND="${RDEPEND}
		app-arch/xz-utils
		doc? ( dev-python/docutils )
		nls? ( sys-devel/gettext )"
RDEPEND="sqlite? ( dev-db/sqlite )
		 nls? ( virtual/libintl )
		 app-arch/bzip2"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	subversion_bootstrap
}

src_configure() {
	if use seperate; then
		eixconf="--enable-seperate-binaries --enable-seperate-update
		--enable-seperate-tools"
	else
		eixconf="--disable-seperate-binaries --disable-seperate-update
		--disable-seperate-tools"
	fi

	econf --with-bzip2 \
	$(use_with doc rst) \
	$(use_enable nls) \
	#$(use_enable seperate seperate-binaries) \
	$(use_with sqlite) \
	${eixconf} \
	--disable-obsolete-symlinks \
	--disable-obsolete-reminder \
	--with-ebuild-sh="/usr/$(get_libdir)/portage/bin/ebuild.sh" \
	--with-portage-rootpath="${ROOTPATH}"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog doc/format.txt
	use doc && dodoc doc/format.html
}

pkg_postinst() {
	elog "Ask your overlay maintainers to provide metadata or consider to run"
	elog " egencache --repo=foo --update"
	elog "after updates (e.g. in /etc/eix-sync)."
	elog "This will speed up portage and update-eix (when the new default cache method"
	elog "\"...#metadata-flat\" is used and file dates are correct) for those overlays."
	elog "If metadata is provided but file dates are mangled during overlay updates,"
	elog "you may switch to cache method \"metadata-flat\" instead for that overlay:"
	elog "This is even faster, but works only if metadata is actually up-to-date."
	ewarn
	ewarn "Security Warning:"
	ewarn
	ewarn "Since >=eix-0.12.0, eix uses by default OVERLAY_CACHE_METHOD=\"parse|ebuild*\""
	ewarn "(since >=eix-0.16.1 with automagic \"#metadata-flat\")."
	ewarn "This is rather reliable, but ebuilds may be executed by user \"portage\". Set"
	ewarn "OVERLAY_CACHE_METHOD=parse in /etc/eixrc if you do not trust the ebuilds."
}
