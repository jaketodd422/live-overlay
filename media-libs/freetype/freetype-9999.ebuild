# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit flag-o-matic git libtool

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://freetype.org"
EGIT_REPO_URI="git://git.sv.nongnu.org/freetype/freetype2.git"
EGIT_BOOTSTRAP="autogen.sh"

LICENSE="FTL GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="X debug doc fontforge"

DEPEND="X?	( x11-libs/libX11
			  x11-libs/libXau
			  x11-libs/libXdmcp )"
RDEPEND="${DEPEND}
		!<media-libs/fontconfig-2.3.2-r2"

src_unpack() {
	git_src_unpack
}

src_configure() {
	enable_option() {
		sed -i -e "/#define $1/a #define $1" \
			include/freetype/config/ftoption.h \
			|| die "unable to enable option $1"
	}

	disable_option() {
		sed -i -e "/#define $1/ { s:^:/*:; s:$:*/: }" \
			include/freetype/config/ftoption.h \
			|| die "unable to disable option $1"
	}

	if use debug; then
		enable_option FT_DEBUG_LEVEL_ERROR
		enable_option FT_DEBUG_MEMORY
	fi

	if ! use X; then
		sed -i -e "/EXES\ +=\ ftview/ s:^:#:" Makefile
	fi

	enable_option FT_CONFIG_OPTION_SUBPIXEL_RENDERING
	enable_option TT_CONFIG_OPTION_BYTECODE_INTERPRETER
	enable_option FT_CONFIG_OPTION_INCREMENTAL
	disable_option FT_CONFIG_OPTION_OLD_INTERNALS

	elibtoolize
	epunt_cxx

	type -P gmake &> /dev/null && export GNUMAKE=gmake

	econf
}

src_compile() {
	append-flags -fno-strict-aliasing

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	use doc && dohtml -r docs/*

	if use utils; then
		rm "${WORKDIR}"/ft2demos-${PV}/bin/README
		for ft2demo in ../ft2demos-${PV}/bin/*; do
			./builds/unix/libtool --mode=install $(type -P install) -m 755 "$ft2demo" \
				"${D}"/usr/bin
		done
	fi
	# Probably fontforge needs less but this way makes things simplier...
	if use fontforge; then
		einfo "Installing internal headers required for fontforge"
		find src/truetype include/freetype/internal -name '*.h' | \
		while read header; do
			mkdir -p "${D}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
			cp ${header} "${D}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
		done
	fi
}

pkg_postinst() {
	einfo "I've removed the utils USE flag. Have a nice day"
}
