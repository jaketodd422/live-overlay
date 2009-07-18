# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit git flag-o-matic toolchain-funcs eutils

DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text
utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
EGIT_REPO_URI="git://git.savannah.gnu.org/coreutils.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
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

src_configure() {
	use static && append-ldflags -static
	econf \
		--enable-install-program="arch" \
		--enable-no-install-program="groups,hostname,kill,su,uptime" \
		--enable-largefile \
		$(use_enable caps libcap) \
		$(use_enable nls) \
		$(use_enable acl) \
		$(use_enable xattr) \
		$(use_with gmp) \
		|| die "econf"
}

src_compile() {
	emake || die "emake"
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}"
	chmod a+rx "${WORKDIR}"

	# coreutils tests like to do `mount` and such with temp dirs
	# so make sure /etc/mtab is writable #265725
	# make sure /dev/loop* can be mounted #269758
	mkdir -p "${T}"/mount-wrappers
	mkwrap() {
		local w ww
		for w in "$@" ; do
			ww="${T}/mount-wrappers/${w}"
			cat <<-EOF > "${ww}"
				#!/bin/sh
				exec env SANDBOX_WRITE="\${SANDBOX_WRITE}:/etc/mtab:/dev/loop" $(type -P $w) "\$@"
			EOF
			chmod a+rx "${ww}"
		done
	}
	mkwrap mount umount

	addwrite /dev/full
	env PATH="${T}/mount-wrappers:${PATH}" \
	emake -k check || die "make check failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO

	insinto /etc
	newins src/dircolors.hin DIR_COLORS || die

	if [ ${USERLAND} == "GNU" ] ; then
		cd "${D}"/usr/bin
		dodir /bin
		local fhs="cat chgrp chmod chown cp date dd df echo false ln ls
		           mkdir mknod mv pwd rm rmdir stty sync true uname"
		mv ${fhs} ../../bin/ || die "could not move fhs bins"
		local com="basename chroot cut dir dirname du env expr head mkfifo
		           mktemp readlink seq sleep sort tail touch tr tty vdir wc yes"
		mv ${com} ../../bin/ || die "could not move common bins"
		local x
		for x in ${com} uname ; do
			dosym /bin/${x} /usr/bin/${x} || die
		done
	else
		rm -rf "${D}"/usr/share/man
	fi
}

pkg_postinst() {
	ewarn "Make sure you run 'hash -r' in your active shells"
	ewarn "This is a live build from the live-overlay, it is unsupported by
	Gentoo, use at your own risk!"

	if [ -e "${ROOT}/usr/bin/dircolors" ] && [ -e "${ROOT}/bin/dircolors" ] ; then
		if strings "${ROOT}/bin/dircolors" | grep -qs "GNU coreutils" ; then
			einfo "Deleting orphaned GNU /bin/dircolors for you"
			rm -f "${ROOT}/bin/dircolors"
		fi
	fi
}
