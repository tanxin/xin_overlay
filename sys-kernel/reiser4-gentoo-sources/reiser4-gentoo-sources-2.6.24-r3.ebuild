# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="4"
R4V=""
inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://gentoo-wiki.com/HOWTO_Reiser4_With_Gentoo-Sources"

DESCRIPTION="Full sources including the Gentoo patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree and the reiser4 patchset from namesys"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} http://chichkin_i.zelnet.ru/namesys/reiser4-for-${PV}${R4V}.patch.gz"
UNIPATCH_LIST="${DISTDIR}/reiser4-for-${PV}${R4V}.patch.gz"

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}
