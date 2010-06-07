# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit git eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="Complete solution to record, convert and stream audio and video. Multithreaded."
HOMEPAGE="http://gitorious.org/ffmpeg/ffmpeg-mt"
EGIT_REPO_URI="git://gitorious.org/~astrange/ffmpeg/ffmpeg-mt.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="3dnow 3dnowext alsa altivec amr custom-cflags cpudetection debug dirac doc ieee1394 +encode faac faad gsm ipv6 jack mmx mmxext +vorbis test +theora threads +x264 +xvid network +zlib sdl X mp3 oss pic schroedinger hardcoded-tables bindist v4l v4l2 speex sse ssse3 static video_cards_nvidia vdpau vhook jpeg2k"

RDEPEND="sdl? ( >=media-libs/libsdl-1.2.10 )
	alsa? ( media-libs/alsa-lib )
	encode? (
		faac? ( media-libs/faac )
		mp3? ( media-sound/lame )
		vorbis? ( media-libs/libvorbis media-libs/libogg )
		theora? ( >=media-libs/libtheora-1.1.1[encode] media-libs/libogg )
		x264? ( >=media-libs/x264-0.0.20100118 )
		xvid? ( >=media-libs/xvid-1.1.0 ) )
	faad? ( >=media-libs/faad2-2.6.1 )
	zlib? ( sys-libs/zlib )
	ieee1394? ( media-libs/libdc1394
				sys-libs/libraw1394 )
	dirac? ( media-video/dirac )
	gsm? ( >=media-sound/gsm-1.0.12-r1 )
	jpeg2k? ( >=media-libs/openjpeg-1.3-r2 )
	amr? ( media-libs/opencore-amr )
	schroedinger? ( media-libs/schroedinger )
	speex? ( >=media-libs/speex-1.2_beta3 )
	jack? ( media-sound/jack-audio-connection-kit )
	X? ( x11-libs/libX11 x11-libs/libXext )
	video_cards_nvidia? (
		vdpau? ( x11-libs/libvdpau )
	)"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	dirac? ( dev-util/pkgconfig )
	schroedinger? ( dev-util/pkgconfig )
	mmx? ( dev-lang/yasm )
	doc? ( app-text/texi2html )
	test? ( net-misc/wget )
	v4l? ( sys-kernel/linux-headers )
	v4l2? ( sys-kernel/linux-headers )"

src_unpack() {
	git_src_unpack

	# There is probably a better way to do this. figure that out
	cd "${S}"
	git clone git://git.mplayerhq.hu/libswscale
}

src_configure() {
	local myconf="${EXTRA_FFMPEG_CONF}"

	# enabled by default
	use debug || myconf += " --disable-debug"
	use zlib || myconf += " --disable-zlib"
	use sdl || myconf += " --disable-ffplay"
	use network || myconf += " --disable-network"
	use static && myconf += " --enable-static --disable-shared" || myconf += " --enable-shared"
	use sse || myconf += " --disable-sse"

	use custom-cflags && myconf += " --disable-optimizations"
	use cpudetection && myconf += " --enable-runtime-cpudetect"

	# enabled by default
	if use encode
	then
		use mp3 && myconf += " --enable-libmp3lame"
		use vorbis && myconf += " --enable-libvorbis"
		use theora && myconf += " --enable-libtheora"
		use x264 && myconf += " --enable-libx264"
		use xvid && myconf += " --enable-libxvid"
		use faac && myconf += " --enable-libfaac --enable-nonfree"
	else
		myconf += " --disable-encoders"
	fi

	# libavdevice options
	use ieee1394 && myconf += " --enable-libdc1394"
	# Indevs
	for i in v4l v4l2 alsa oss jack ; do
		use $i || myconf += " --disable-indev=$i"
	done
	# Outdevs
	for i in alsa oss ; do
		use $i || myconf += " --disable-outdev=$i"
	done
	use X && myconf += " --enable-x11grab"

	# Threads; we only support pthread for now but ffmpeg supports more
	use threads && myconf += " --enable-pthreads"

	# Decoders
	use amr && myconf += " --enable-libopencore-amrwb
		--enable-libopencore-amrnb"
	for i in gsm faad dirac schroedinger speex; do
		use $i && myconf += " --enable-lib$i"
	done
	use jpeg2k && myconf += " --enable-libopenjpeg"

	use video_cards_nvidia || myconf += " --disable-vdpau"
	use vdpau || myconf += " --disable-vdpau"
	myconf += " --disable-vaapi"

	# CPU features
	for i in mmx ssse3 altivec ; do
		use $i ||  myconf += " --disable-$i"
	done
	use mmxext || myconf += " --disable-mmx2"
	use 3dnow || myconf += " --disable-amd3dnow"
	use 3dnowext || myconf += " --disable-amd3dnowext"
	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC.
	if gcc-specs-pie ; then
		myconf += " --disable-mmx --disable-mmx2"
	fi

	# Option to force building pic
	use pic && myconf += " --enable-pic"

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag march) $(get-flag mcpu) $(get-flag mtune) ; do
		[ "${i}" = "native" ] && i="host" # bug #273421
		[[ ${i} = *-sse3 ]] && i="${i%-sse3}" # bug 283968
		myconf += " --cpu=$i"
		break
	done

	# Mandatory configuration
	myconf += " --enable-gpl --enable-version3 --enable-postproc \
			--enable-avfilter --enable-avfilter-lavf \
			--disable-stripping"

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf += " --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}-"
		case ${CHOST} in
			*freebsd*)
				myconf += " --target-os=freebsd"
				;;
			mingw32*)
				myconf += " --target-os=mingw32"
				;;
			*linux*)
				myconf += " --target-os=linux"
				;;
		esac
	fi

	# Misc stuff
	use hardcoded-tables && myconf += " --enable-hardcoded-tables"
	use doc || myconf += " --disable-doc"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if (use debug); then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	cd "${S}"
	./configure \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--shlibdir=/usr/$(get_libdir) \
		--mandir=/usr/share/man \
		--cc="$(tc-getCC)" \
		${myconf} || die "configure failed"
}

src_compile() {
	emake version.h || die #252269
	emake || die "make failed"
}

src_install() {
	#on my system portage stalls when installing without -j1.
	#make -j2 install install-man works fine when not invoked by portage
	emake -j1 DESTDIR="${D}" install install-man || die "Install Failed"

	dodoc Changelog README INSTALL
	dodoc doc/*
}
