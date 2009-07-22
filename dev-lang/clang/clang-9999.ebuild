EAPI="2"

inherit eutils subversion

DESCRIPTION="Clang C/C++ compiler"
HOMEPAGE="http://clang.llvm.org"
IUSE="alltargets debug doc profile"
KEYWORDS="~x86 ~amd64"
LICENSE="UoI-NCSA"
SLOT="0"

ESVN_REPO_URI="svn://llvm.org/svn/llvm-project/llvm/trunk"

DEPEND="dev-lang/perl
		dev-util/subversion
		>=sys-devel/gcc-3.4.6-r2 
		>=sys-devel/make-3.81
		>=sys-devel/flex-2.5.35
		>=sys-devel/bison-2.4.1"
RDEPEND="dev-lang/perl"

S="${WORKDIR}/llvm"

src_unpack() {
	subversion_fetch || die "An error occured during subversion_fetch"
	subversion_bootstrap || die "An error occured during subversion_bootstrap"

	cd "${S}/tools"
		
	einfo "Checkout Clang source"
	svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
}

src_configure() {
	local CONF_FLAGS

	if use debug; then
		CONF_FLAGS="${CONF_FLAGS} --enable-debug-runtime --disable-optimized"
		einfo "Note: Compiling LLVM in debug mode will create huge and slow binaries"
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-optimized --disable-assertions \
--disable-extensive-checks --disable-debug-runtime"
	fi

	if use alltargets; then
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=all"
	else
		CONF_FLAGS="${CONF_FLAGS} --enable-targets=host-only"
	fi

	if use profile; then
		CONF_FLAGS="${CONF_FLAGS} --enable-profiling"
	else
		CONF_FLAGS="${CONF_FLAGS} --disable-profiling"
	fi
	
	# This is so llvm doesn't build the gcc frontend
	CONF_FLAGS="${CONF_FLAGS} --with-llvmgccdir=/dev/null"

	econf ${CONF_FLAGS} || die "econf failed"
}

src_compile() {
	cd "${S}"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	
	if use doc; then
		dodoc "${D}/docs"
	else
		rm -rf "${D}/docs"
	fi

	cd "${S}/tools/clang"
	emake DESTDIR="${D}" install || die "emake install failed"
}
