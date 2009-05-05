# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openal/openal-1.6.372.ebuild,v 1.9  2009/02/04 21:38:21 armin76 Exp $ 

EGIT_REPO_URI="http://lastlog.de/git/openal-soft-pulseaudio"

inherit eutils cmake-utils git

MY_P=${PN}-soft-${PV}

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://lastlog.de/wiki/index.php/Pulseaudio"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ~ppc64 sparc x86 ~x86-fbsd"
IUSE="alsa oss debug"

DEPEND="alsa? ( media-libs/alsa-lib )"

S=${WORKDIR}/${MY_P}

DOCS="alsoftrc.sample"

src_unpack() {
	git_src_unpack
} 

src_compile() {
	local mycmakeargs=""
	use alsa || mycmakeargs="${mycmakeargs} -DALSA=OFF"
	use oss || mycmakeargs="${mycmakeargs} -DOSS=OFF"
	use debug && mycmakeargs="${mycmakeargs} -DCMAKE_BUILD_TYPE=Debug"
	cmake-utils_src_compile
}

pkg_postinst() {
	einfo "If you have performance problems using this library, then"
	einfo "try add these lines to your ~/.alsoftrc config file:"
	einfo "[alsa]"
	einfo "mmap = off"
}
