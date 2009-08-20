# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games

MY_SKINS="SKINSbmodels-48files-4-23-05.zip"
RYGEL_F="rygel-dp-texturepack-small.pk3"
QRP_F="qrp-maptextures-2007-10-06r2-7files.zip"

DESCRIPTION="Collection of graphical improvements for Quake 1"
HOMEPAGE="http://facelift.quakedev.com/"
SRC_URI="http://facelift.quakedev.com/download/${MY_SKINS}
	http://facelift.quakedev.com/download/${QRP_F}
	http://shub-hub.com/files/textures_retexture_project/${QRP_F}
	http://qrp.quakeonline.net/${QRP_F}
	http://shub-hub.com/files/textures_replacement/${RYGEL_F}"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="demo fuhquake tenebrae rygel"

RDEPEND="|| (
		games-fps/darkplaces
		games-fps/joequake
		tenebrae? ( games-fps/tenebrae )
		games-fps/ezquake-bin
		fuhquake? ( games-fps/fuhquake-bin ) )"
DEPEND="app-arch/unzip"

S=${WORKDIR}
dir=${GAMES_DATADIR}/quake1

unpack_qrp() {
	unpack ./qrp.zip

	# Renames *.link, e.g. from metal5_5.link to metal5_5.tga
	cd textures || die
	local flink fnew fcopy
	for flink in *.link ; do
		fcopy=$(cat "${flink}")
		fnew=${flink%.link}.tga
		cp -f "${fcopy}" "${fnew}" || die "cp ${fcopy}"
		rm -f "${flink}"
	done
	cd ..
}

src_unpack() {
	unpack ${MY_SKINS}

	# Move the skin textures to join the others
	mkdir -p textures
	mv -f *.tga textures

	ln -s "${DISTDIR}"/${RYGEL_F} ${RYGEL_F}.zip || die "ln rygel"
	unpack ${QRP_F}
	mv -f qrp*.pk3 qrp.zip || die

	if use rygel ; then
		# Rygel's textures take precedence over QRP textures
		unpack_qrp
		unpack ./${RYGEL_F}.zip
	else
		unpack ./${RYGEL_F}.zip
		unpack_qrp
	fi

	rm -f textures/Thumbs.db
}

src_install() {
	insinto "${dir}"/id1
	doins -r textures || die "doins textures"

	# Added by rygel. Ignoring gfx & maps & cubemaps.
	# cubemaps dir is added by darkplaces.
	doins -r env progs || die "doins rygel"

	if use demo ; then
		keepdir "${dir}/demo"
		# Set up symlink, for the demo levels to include the textures
		dosym "${dir}/id1/textures" "${dir}/demo/textures"
	fi

	# Support specific engines which need their own directory names
	if use tenebrae ; then
		keepdir "${dir}/tenebrae"
		dosym "${dir}/id1/textures" "${dir}/tenebrae/override"
	fi
	if use fuhquake ; then
		keepdir "${dir}/fuhquake"
		dosym "${dir}/id1/textures" "${dir}/fuhquake/textures"
	fi

	dodoc *.txt
	dohtml *.html

	prepgamesdirs
}
