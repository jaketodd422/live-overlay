# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit games svn

DESCRIPTION="Enchanced engine for the iD Software's Quake1"
HOMEPAGE="http://icculus.org/twiligt/darkplaces"
ESVN_REPO_URI="svn://svn.icculus.org/twilight/trunk/darkplaces"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="alsa cdinstall cdsound debug dedicated demo lights opengl oss sdl textures"

DEPEND=""
RDEPEND="${DEPEND}"

