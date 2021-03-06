# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit flag-o-matic games subversion

MY_LIGHTS="fuhquake-lits.rar"

DESCRIPTION="Enchanced engine for the iD Software's Quake1"
HOMEPAGE="http://icculus.org/twiligt/darkplaces"
ESVN_REPO_URI="svn://svn.icculus.org/twilight/trunk/darkplaces"
SRC_URI="lights? ( http://www.fuhquake.net/files/extras/${MY_LIGHTS}
			http://www.kgbsyndicate.com/romi/id1.pk3 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="alsa cdinstall cdsound dedicated demo lights opengl oss sdl textures"

UIRDEPEND="media-libs/jpeg
	media-libs/libogg
	media-libs/libvorbis
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	sdl? ( media-libs/libsdl )
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXxf86dga
	x11-libs/libXxf86vm"
UIDEPEND="x11-proto/xextproto
	x11-proto/xf86dgaproto
	x11-proto/xf86vidmodeproto
	x11-proto/xproto"
RDEPEND="net-misc/curl
	cdinstall? ( games-fps/quake1-data )
	demo? ( games-fps/quake1-demodata )
	textures? ( >=games-fps/quake1-textures-20050820 )
	opengl? ( ${UIRDEPEND} )
	!opengl? ( sdl? ( ${UIRDEPEND} ) )
	!opengl? ( !sdl? ( !dedicated? ( ${UIRDEPEND} ) ) )"
DEPEND="lights? ( || (
			app-arch/unrar
			app-arch/rar ) )
	opengl? (
		${UIRDEPEND}
		${UIDEPEND} )
	!opengl? ( sdl? (
		${UIRDEPEND}
		${UIDEPEND} ) )
	!opengl? ( !sdl? ( !dedicated? (
		${UIRDEPEND}
		${UIDEPEND} ) ) )
	dev-util/pkgconfig
	app-arch/unzip"

S=${WORKDIR}/${PN}
dir=${GAMES_DATADIR}/quake1

opengl_client() { use opengl || ( ! use dedicated && ! use sdl ) }

src_unpack() {
	if use lights ; then
		unpack "${MY_LIGHTS}"
		unzip -qo "${DISTDIR}"/id1.pk3 || die "unzip id1.pk3 failed"
		mv *.lit maps/ || die
		mv ReadMe.txt rtlights.txt
	fi
	subversion_src_unpack
}

src_prepare() {
	rm "${WORKDIR}"/README-SDL.txt
	cd "${S}"
	rm mingw_note.txt

	# Only additional CFLAGS optimization is the -march flag
	local march=$(get-flag -march)
	sed -i \
		-e '/^CC=/d' \
		-e "s:-lasound:$(pkg-config --libs alsa):" \
		-e "s:CPUOPTIMIZATIONS=:CPUOPTIMIZATIONS=${march}:" \
		-e "s:strip:echo:" \
		makefile.inc || die "sed makefile.inc failed"

	if ! use cdsound ; then
		# Turn the CD accesses off
		sed -i \
			-e "s:/dev/cdrom:/dev/null:" \
			cd_linux.c || die "sed cd_linux.c failed"
		sed -i \
			-e 's:COM_CheckParm("-nocdaudio"):1:' \
			cd_shared.c || die "sed cd_shared.c failed"
	fi
}

src_compile() {
	local opts="DP_FS_BASEDIR=\"${dir}\""

	# Preferred sound is alsa
	local sound_api="NULL"
	use oss && sound_api="OSS"
	use alsa && sound_api="ALSA"
	opts="${opts} DP_SOUND_API=${sound_api}"

	local type="release"
	
	sed -i \
		-e 's/OPTIM_RELEASE=-O2 -fno-strict-aliasing \
		$(CPUOPTIMIZATIONS)/OPTIM_RELEASE=${CFLAGS}/g' \
		-e 's/LDFLAGS_RELEASE=$(OPTIM_RELEASE) -DSVNREVISION=`test -d .svn && \
		svnversion || echo -` -DBUILDTYPE=release/LDFLAGS_RELEASE= ${LDFLAGS}/g' \
		-e 's/-I\/usr\/X11R6\/include/-I\/usr\/include\/X11/g' \
		makefile.inc

	# Only compile a maximum of 1 client
	if use sdl ; then
		emake ${opts} "sdl-${type}" || die "emake sdl-${type} failed"
	elif opengl_client ; then
		emake ${opts} "cl-${type}" || die "emake cl-${type} failed"
	fi

	if use dedicated ; then
		emake ${opts} "sv-${type}" || die "emake sv-${type} failed"
	fi
}

src_install() {
	if opengl_client || use sdl ; then
		local type=glx

		use sdl && type=sdl

		# darkplaces executable is needed, even just for demo
		newgamesbin "${PN}-${type}" ${PN} || die "newgamesbin client failed"
		newicon darkplaces72x72.png ${PN}.png || die "newicon failed"

		if use demo ; then
			# Install command-line for demo, even if not desktop entry
			games_make_wrapper ${PN}-demo "${PN} -game demo"
		fi

		if use demo && ! use cdinstall ; then
			make_desktop_entry ${PN}-demo "Dark Places (Demo)"
		else
			# Full version takes precedence over demo
			make_desktop_entry ${PN} "Dark Places"
		fi
	fi

	if use dedicated ; then
		newgamesbin ${PN}-dedicated ${PN}-ded || die "newgamesbin ded failed"
	fi

	dodoc *.txt ChangeLog todo "${WORKDIR}"/*.txt

	if use lights ; then
		insinto "${dir}"/id1
		doins -r "${WORKDIR}"/{cubemaps,maps} || die "doins cubemaps maps failed"
		if use demo ; then
			# Set up symlinks, for the demo levels to include the lights
			local d
			for d in cubemaps maps ; do
				dosym "${dir}/id1/${d}" "${dir}/demo/${d}"
			done
		fi
	fi
	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	if ! use cdinstall && ! use demo ; then
		elog "Place pak0.pak and pak1.pak in ${dir}/id1"
	fi

	if use sdl ; then
		ewarn "Select opengl with alsa, instead of sdl USE flag, for better audio latency."
	fi
}
