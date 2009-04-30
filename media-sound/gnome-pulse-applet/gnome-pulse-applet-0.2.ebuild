# ==========================================================================
# This ebuild come from steev repository. Zugaina.org only host a copy.
# For more info go to http://gentoo.zugaina.org/
# ************************ General Portage Overlay ************************
# ==========================================================================
# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils

EAPI=0

DESCRIPTION="simple applet for controlling PulseAudio streams"
HOMEPAGE="http://code.google.com/p/gnome-pulse-applet/"

SRC_URI="http://launchpad.net/notify-osd/trunk/${PV}/+download/${P}.tar.gz"
SRC_URI="http://gnome-pulse-applet.googlecode.com/files/gnome-pulse-applet-${PV}.tar.gz"
LICENSE="GPL-3"
SLOT="0"

KEYWORDS="~x86 ~amd64"
DEPEND="media-sound/pulseaudio
		dev-python/gnome-applets-python
"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "skipping compile"
}

src_install() {
	make install DESTDIR="${D}" || die "make
	install failed"
	dodoc COPYING README
}

