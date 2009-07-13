# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit git

DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text
utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
EGIT_REPO_URI="git://git.savannah.gnu.org/coreutils.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="acl caps gmp nls static xattr"

RDEPEND="caps? ( sys-libs/libcap )
	gmp? ( dev-libs/gmp )
	acl? ( sys-apps/acl )
	xattr? ( sys-apps/attr )
	nls? ( >=sys-devel/gettext-0.15 )
	!<sys-apps/util-linux-2.13
	!sys-apps/stat
	!net-mail/base64
	!sys-apps/mktemp
	!<app-forensics/tct-1.18-r1
	!<net-fs/netatalk-2.0.3-r4
	!<sci-chemistry/ccp4-6.1.1
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

src_unpack() {
	git_src_unpack
}

src_prepare() {
}
