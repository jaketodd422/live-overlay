# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils flag-o-matic git libtool

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://gtk.org"
EGIT_REPO_URI="git://git.gnome.org/glib"
EGIT_BRANCH="master"
EGIT_BOOTSTRAP="autogen.sh"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="debug doc fam xattr"

RDEPEND="virtual/libc
	virtual/libiconv
	xattr? ( sys-apps/attr )
	fam? ( virtual/fam )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16
	>=sys-devel/gettext-0.11
	doc? (
		>=dev-libs/libxslt-1.0
		>=dev-util/gtk-doc-1.11
		~app-text/docbook-xml-dtd-4.1.2 )"

src_prepare() {
	if use ia64 ; then
		# Only apply for < 4.1
		local major=$(gcc-major-version)
		local minor=$(gcc-minor-version)
		if (( major < 4 || ( major == 4 && minor == 0 ) )); then
			epatch "${FILESDIR}/glib-2.10.3-ia64-atomic-ops.patch"
		fi
	fi

	[[ ${CHOST} == *-freebsd* ]] && elibtoolize
}

src_unpack() {
	git_src_unpack
}

src_configure() {
	cd "${WORKDIR}/${P}"

	local myconf

	epunt_cxx

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	use debug && myconf="--enable-debug"

	# Always build static libs, see #153807
	# Always use internal libpcre, bug #254659
	econf ${myconf}                 \
		  $(use_enable xattr)       \
		  $(use_enable doc man)     \
		  $(use_enable doc gtk-doc) \
		  $(use_enable fam)         \
		  $(use_enable selinux)     \
		  --enable-static           \
		  --enable-regex            \
		  --with-pcre=internal      \
		  --with-threads=posix
}

src_compile() {
	cd "${WORKDIR}/${P}"

	emake || die "emake failed"
}

src_install() {
	cd "${WORKDIR}/${P}"
	emake DESTDIR="${D}" install || die "Installation failed"

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${D}/usr/lib/charset.alias"

	dodoc AUTHORS ChangeLog* NEWS* README || die "dodoc failed"
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export XDG_CONFIG_DIRS=/etc/xdg
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
	emake check || die "tests failed"
}
