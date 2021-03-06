# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit toolchain-funcs eutils elisp-common perl-module bash-completion git

DESCRIPTION="GIT - the stupid content tracker, the revision control system heavily used by the Linux kernel team"
HOMEPAGE="http://www.git-scm.com/"
SRC_URI="mirror://kernel/pub/software/scm/git/${PN}-manpages-1.6.6.2.tar.bz2"
EGIT_BRANCH="master"
EGIT_REPO_URI="git://git.kernel.org/pub/scm/git/git.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="curl cgi doc emacs gtk iconv mozsha1 perl ppcsha1 tk threads webdav xinetd cvs subversion"

CDEPEND="
	!app-misc/git
	dev-libs/openssl
	sys-libs/zlib
	app-arch/cpio
	perl? ( dev-lang/perl )
	tk?   ( dev-lang/tk )
	curl? (
		net-misc/curl
		webdav? ( dev-libs/expat )
	)
	emacs?  ( virtual/emacs )"

RDEPEND="${CDEPEND}
	perl? ( dev-perl/Error
			dev-perl/Net-SMTP-SSL
			dev-perl/Authen-SASL
			cgi? ( virtual/perl-CGI )
			cvs? ( >=dev-util/cvsps-2.1
			dev-perl/DBI
			dev-perl/DBD-SQLite )
			subversion? ( dev-util/subversion[-dso]
						dev-perl/libwww-perl
						dev-perl/TermReadKey )
			)
	gtk?  ( >=dev-python/pygtk-2.8
			dev-python/gtksourceview-python )"

DEPEND="${CDEPEND}"

DEPEND="${DEPEND}
	doc? ( app-text/asciidoc
		   app-text/xmlto
		   app-text/docbook2X
	)"

SITEFILE=50${PN}-gentoo.el

pkg_setup() {
	if ! use perl ; then
		use cgi && ewarn "gitweb needs USE=perl, ignoring USE=cgi"
		use cvs && ewarn "CVS integration needs USE=perl, ignoring USE=cvs"
		use subversion && ewarn "git-svn needs USE=perl, it won't work"
	fi
	if use webdav && ! use curl ; then
		ewarn "USE=webdav needs USE=curl. Ignoring"
	fi
	if use subversion && has_version dev-util/subversion && built_with_use --missing false dev-util/subversion dso ; then
		ewarn "Per Gentoo bugs #223747, #238586, when subversion is built"
		ewarn "with USE=dso, there may be weird crashes in git-svn. You"
		ewarn "have been warned."
	fi
}

exportmakeopts() {
	local myopts

	if use mozsha1 ; then
		myopts="${myopts} MOZILLA_SHA1=YesPlease"
	elif use ppcsha1 ; then
		myopts="${myopts} PPC_SHA1=YesPlease"
	fi

	if use curl ; then
		use webdav || myopts="${myopts} NO_EXPAT=YesPlease"
	else
		myopts="${myopts} NO_CURL=YesPlease"
	fi

	use iconv || myopts="${myopts} NO_ICONV=YesPlease"
	use tk || myopts="${myopts} NO_TCLTK=YesPlease"
	use perl || myopts="${myopts} NO_PERL=YesPlease"
	use threads && myopts="${myopts} THREADED_DELTA_SEARCH=YesPlease"
	use subversion || myopts="${myopts} NO_SVN_TESTS=YesPlease"

	export MY_MAKEOPTS="${myopts}"
}

src_unpack() {
	git_src_unpack

	cd "${S}"
	unpack ${PN}-manpages-1.6.6.2.tar.bz2

	use doc && \
		cd "${S}"/Documentation && \
		unpack ${PN}-htmldocs-1.6.6.2.tar.bz2
	cd "${S}"
}

src_prepare() {
	sed -i \
		-e 's:^\(CFLAGS =\).*$:\1 $(OPTCFLAGS) -Wall:' \
		-e 's:^\(LDFLAGS =\).*$:\1 $(OPTLDFLAGS):' \
		-e 's:^\(CC = \).*$:\1$(OPTCC):' \
		-e 's:^\(AR = \).*$:\1$(OPTAR):' \
		Makefile || die "sed failed"

	sed -i 's/DOCBOOK2X_TEXI=docbook2x-texi/DOCBOOK2X_TEXI=docbook2texi.pl/' \
		Documentation/Makefile || die "sed failed"
}

git_emake() {
	emake ${MY_MAKEOPTS} \
		DESTDIR="${D}" \
		OPTCFLAGS="${CFLAGS}" \
		OPTLDFLAGS="${LDFLAGS}" \
		OPTCC="$(tc-getCC)" \
		OPTAR="$(tc-getAR)" \
		prefix=/usr \
		htmldir=/usr/share/doc/${PF}/html \
		"$@"
}

src_configure() {
	exportmakeopts
}

src_compile() {
	git_emake || die "emake failed"

	if use emacs ; then
		elisp-compile contrib/emacs/git{,-blame}.el \
			|| die "emacs modules failed"
	fi

	if use perl && use cgi ; then
		git_emake \
			gitweb/gitweb.cgi \
			|| die "emake gitweb/gitweb.cgi failed"
	fi

	if use doc; then
		cd Documentation
		git_emake man info html \
			|| die "emake man html info failed"
	fi
}

src_install() {
	git_emake \
		install || \
		die "make install failed"

	doman man?/*.[157] Documentation/*.[157]

	dodoc README Documentation/{SubmittingPatches,CodingGuidelines}
	use doc && dodir /usr/share/doc/${PF}/html
	for d in / /howto/ /technical/ ; do
		docinto ${d}
		dodoc Documentation${d}*.txt
		use doc && dohtml -p ${d} Documentation${d}*.html
	done
	docinto /

	dobashcompletion contrib/completion/git-completion.bash ${PN}

	if use emacs ; then
		elisp-install ${PN} contrib/emacs/git.{el,elc} || die
		elisp-install ${PN} contrib/emacs/git-blame.{el,elc} || die
		#elisp-install ${PN}/compat contrib/emacs/vc-git.{el,elc} || die
		# don't add automatically to the load-path, so the sitefile
		# can do a conditional loading
		touch "${D}${SITELISP}/${PN}/compat/.nosearch"
		elisp-site-file-install "${FILESDIR}"/${SITEFILE} || die
	fi

	if use gtk ; then
		dobin "${S}"/contrib/gitview/gitview
		dodoc "${S}"/contrib/gitview/gitview.txt
	fi

	dobin contrib/fast-import/git-p4
	dodoc contrib/fast-import/git-p4.txt
	newbin contrib/fast-import/import-tars.perl import-tars

	dodir /usr/share/${PN}/contrib
	for i in continuous fast-import hg-to-git \
		hooks remotes2config.sh stats \
		workdir convert-objects blameview ; do
		cp -rf \
			"${S}"/contrib/${i} \
			"${D}"/usr/share/${PN}/contrib \
			|| die "Failed contrib ${i}"
	done

	if use perl && use cgi ; then
		dodir /usr/share/${PN}/gitweb
		insinto /usr/share/${PN}/gitweb
		doins "${S}"/gitweb/gitweb.cgi
		doins "${S}"/gitweb/gitweb.css
		doins "${S}"/gitweb/git-{favicon,logo}.png

		# Make sure it can run
		fperms 0755 /usr/share/${PN}/gitweb/gitweb.cgi

		# INSTALL discusses configuration issues, not just installation
		docinto /
		newdoc  "${S}"/gitweb/INSTALL INSTALL.gitweb
		newdoc  "${S}"/gitweb/README README.gitweb

		find "${D}"/usr/lib64/perl5/ \
			-name .packlist \
			-exec rm \{\} \;
	fi
	if ! use subversion ; then
		rm -f "${D}"/usr/libexec/git-core/git-svn \
			"${D}"/usr/share/man/man1/git-svn.1*
	fi

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}"/git-daemon.xinetd git-daemon
	fi

	newinitd "${FILESDIR}"/git-daemon.initd git-daemon
	newconfd "${FILESDIR}"/git-daemon.confd git-daemon

	fixlocalpod
}

showpkgdeps() {
	local pkg=$1
	shift
	elog "  $(printf "%-17s:" ${pkg}) ${@}"
}

pkg_postinst() {
	use emacs && elisp-site-regen
	if use subversion && has_version dev-util/subversion && ! built_with_use --missing false dev-util/subversion perl ; then
		ewarn "You must build dev-util/subversion with USE=perl"
		ewarn "to get the full functionality of git-svn!"
	fi
	elog "These additional scripts need some dependencies:"
	echo
	showpkgdeps git-quiltimport "dev-util/quilt"
	showpkgdeps git-instaweb \
		"|| ( www-servers/lighttpd www-servers/apache )"
	echo
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
