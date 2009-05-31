# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Techwolf. For new version look here : http://gentoo.techwolf.net/

EAPI="2"

inherit cmake-utils games subversion

DESCRIPTION="A 3D MMORPG virtual world entirely built and owned by its residents"
HOMEPAGE="http://secondlife.com/"

ESVN_REPO_URI="https://svn.secondlife.com/svn/linden/trunk"


LICENSE="GPL-2-with-Linden-Lab-FLOSS-exception"
SLOT="0"
# KEYWORDS=""
KEYWORDS="~amd64 ~x86"
IUSE="+vivox +openal +llmozlib +gstreamer dbus fmod"
RESTRICT="mirror"

# There are problems with curl if built with gnutls. http://jira.secondlife.com/browse/VWR-5601 
# There is DNS lookup problems with curl if built without c-ares.
RDEPEND="x11-libs/gtk+:2
	dev-libs/apr
	dev-libs/apr-util
	net-dns/c-ares
	net-misc/curl[-nss,-gnutls,ares]
	dev-libs/openssl
	media-libs/freetype
	media-libs/jpeg
	media-libs/libsdl
	media-libs/mesa
	media-libs/libogg
	media-libs/libvorbis
	vivox? ( amd64? ( app-emulation/emul-linux-x86-baselibs ) )
	fmod? ( =media-libs/fmod-3.75* )
	openal? ( >=media-libs/openal-1.5.304 
		media-libs/freealut )
	sys-libs/db
	dev-libs/dbus-glib
	dev-libs/expat
	sys-libs/zlib
	>=dev-libs/xmlrpc-epi-0.51-r1
	media-libs/openjpeg
	media-libs/libpng
	x11-libs/pango
	llmozlib? ( net-libs/llmozlib2 )
	gstreamer? ( media-libs/gst-plugins-base
		    media-plugins/gst-plugins-soup
		    media-plugins/gst-plugins-mad
		    media-plugins/gst-plugins-ffmpeg
		    alsa? ( media-plugins/gst-plugins-alsa )
		    oss? ( media-plugins/gst-plugins-oss )
		    esd? ( media-plugins/gst-plugins-esd )
		    pulse? ( media-plugins/gst-plugins-pulse ) )"

DEPEND="${RDEPEND}
	dev-libs/boost
	dev-util/pkgconfig
	sys-devel/flex
	sys-devel/bison
	dev-lang/python
	>=dev-util/cmake-2.4.8
	dev-perl/XML-XPath
	dev-libs/libndofdev"

# Prevent warning on a binary only file
QA_TEXTRELS="usr/share/games/secondlife-trunk/lib/libvivoxsdk.so"

pkg_setup() {
	use amd64 && use fmod && ewarn "fmod is only available on x86. Disabling fmod"
	
	# Unset all locale related variables, they can make the
	# patches and build fail.
#	eval unset ${!LC_*} LANG LANGUAGE
	#  set LINGUAS to en for the build tools, may fix an international build bug.
#	export LINGUAS=en
}

src_unpack() {
	# When using svc, S is the directory the checkout is copied into.
	# Set it so it matches src tarballs.
	S="${WORKDIR}/linden"
	subversion_src_unpack
	
	# source downloads URL variables and download suppemential packages.
	. "${S}"/doc/asset_urls.txt
	cd "${WORKDIR}"
	wget "${SLASSET_ART}" || die "Problem with fetching ${SLASSET_ART##*/}"
	unpack ./${SLASSET_ART##*/} || die "Problem with unpacking ${SLASSET_ART##*/}"
	wget "${SLASSET_LIBS_LINUXI386}" || die "Problem with fetching ${SLASSET_LIBS_LINUXI386##*/}"
	unpack ./${SLASSET_LIBS_LINUXI386##*/} || die "Problem with unpacking ${SLASSET_LIBS_LINUXI386##*/}"
	
	cd "${WORKDIR}"/linden
	filter-ldflags -Wl,--as-needed
	ln -s linden/indra_build ../${PN}_build
	# more artwork, can we get more packages to play with LL?
	use amd64 && SLASSET_ART_COMMON=$(xpath "${S}/install.xml" "//key[text()='artwork-common']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux64']/following-sibling::map[1]/uri/text()")
	[[ -z "${SLASSET_ART_COMMON}" ]] && SLASSET_ART_COMMON=$(xpath "${S}/install.xml" "//key[text()='artwork-common']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux']/following-sibling::map[1]/uri/text()")
	[[ -z "${SLASSET_ART_COMMON}" ]] && SLASSET_ART_COMMON=$(xpath "${S}/install.xml" "//key[text()='artwork-common']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux32']/following-sibling::map[1]/uri/text()")
	wget "${SLASSET_ART_COMMON}" || die "Problem with fetching ${SLASSET_ART_COMMON##*/}"
	unpack ./${SLASSET_ART_COMMON##*/} || die "Problem with unpacking ${SLASSET_ART_COMMON##*/}"

	if [[ ! -f "${WORKDIR}/linden/indra/llwindow/glh/glh_linear.h" ]] ; then
	  # need glh/glh_linear.h that is not aviable in portage.
	  # http://jira.secondlife.com/browse/VWR-9005
	  # Many thanks to Cron Stardust that posted this example to the SLDev list.
	  # url can be in linux64 or linux or linux32, its a changing target.
	  use amd64 && SLASSET_GLH=$(xpath "${S}/install.xml" "//key[text()='glh_linear']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux64']/following-sibling::map[1]/uri/text()")
	  [[ -z "${SLASSET_GLH}" ]] && SLASSET_GLH=$(xpath "${S}/install.xml" "//key[text()='glh_linear']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux']/following-sibling::map[1]/uri/text()")
	  [[ -z "${SLASSET_GLH}" ]] && SLASSET_GLH=$(xpath "${S}/install.xml" "//key[text()='glh_linear']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux32']/following-sibling::map[1]/uri/text()")
	  wget "${SLASSET_GLH}" || die "Problem with fetching ${SLASSET_GLH##*/}"
	  unpack ./${SLASSET_GLH##*/} || die "Problem with unpacking ${SLASSET_GLH##*/}"
	 else
	  einfo "glh_linear.h found, not downloading glh package."
	fi

	if [[ ! -d "${WORKDIR}/linden/indra/newview/res-sdl" ]] ; then
	  # need the SDL package due to Linden Labs put mouse cursers in it.
	  # http://jira.secondlife.com/browse/VWR-9475
	  # url can be in linux64 or linux or linux32, its a changing target.
	  use amd64 && SLASSET_SDL=$(xpath "${S}/install.xml" "//key[text()='SDL']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux64']/following-sibling::map[1]/uri/text()")
	  [[ -z "${SLASSET_SDL}" ]] && SLASSET_SDL=$(xpath "${S}/install.xml" "//key[text()='SDL']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux']/following-sibling::map[1]/uri/text()")
	  [[ -z "${SLASSET_SDL}" ]] && SLASSET_SDL=$(xpath "${S}/install.xml" "//key[text()='SDL']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux32']/following-sibling::map[1]/uri/text()")
	  wget "${SLASSET_SDL}" || die "Problem with fetching ${SLASSET_SDL##*/}"
	  unpack ./${SLASSET_SDL##*/} || die "Problem with unpacking ${SLASSET_SDL##*/}"
	 else
	  einfo "res-sdl directory found, not downloading SDL package."
	fi
	
	if use vivox ; then
	  # url can be in linux64 or linux or linux32, its a changing target.
	  use amd64 && SLASSET_VIVOX=$(xpath "${S}/install.xml" "//key[text()='vivox']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux64']/following-sibling::map[1]/uri/text()")
	  [[ -z "${SLASSET_VIVOX}" ]] && SLASSET_VIVOX=$(xpath "${S}/install.xml" "//key[text()='vivox']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux']/following-sibling::map[1]/uri/text()")
	  [[ -z "${SLASSET_VIVOX}" ]] && SLASSET_VIVOX=$(xpath "${S}/install.xml" "//key[text()='vivox']/following-sibling::map[1]/key[text()='packages']/following-sibling::map[1]/key[text()='linux32']/following-sibling::map[1]/uri/text()")
	  wget "${SLASSET_VIVOX}" || die "Problem with fetching ${SLASSET_VIVOX##*/}"
	  unpack ./${SLASSET_VIVOX##*/} || die "Problem with unpacking ${SLASSET_VIVOX##*/}"
	fi
}

src_prepare() {
	# Gentoo and build fix patches
	cd "${S}/indra"
	epatch "${FILESDIR}"/my_patch.patch
	epatch "${FILESDIR}"/secondlife-cmake-llmozilla.patch
	epatch "${FILESDIR}"/secondlife-llmozlib-svn.patch
	epatch "${FILESDIR}"/VWR-9499-fix_keeping_dbus_stuff_together.patch
	cd ../
	# epatch "${FILESDIR}"/cmakeInstall.patch
	# FIXED epatch "${FILESDIR}"/VWR-9557-EnableBuildWithNvidiaOrMesaHeaders_1_22_4.patch
	# whoops, turns out there is couple bugs in it.
	# epatch "${FILESDIR}"/VWR-9557-aux.patch
	# gcc 4.3 fixes
	# epatch "${FILESDIR}"/VWR-10001-message.patch
	# epatch "${FILESDIR}"/secondlife-llcrashloggerlinux.patch

	edos2unix "${WORKDIR}/linden/indra/newview/app_settings/cmd_line.xml"
	# disable crashlogger so we can get core dumps
	epatch "${FILESDIR}"/VWR-12678_add_crash_to_core_option.patch
}

# Linden Labs use ./develop.py to configure/build, but it is just a wrapper around cmake and does not take in
# account for gentoo querks/features of multi-libs of different versions installed at same time.
src_configure() {
	S="${WORKDIR}/linden/indra"
	mycmakeargs="-DSTANDALONE:BOOL=TRUE
		     -DCMAKE_BUILD_TYPE:STRING=RELEASE
		     -DINSTALL:BOOL=TRUE
		     -DAPP_SHARE_DIR:STRING=${GAMES_DATADIR}/${PN}
		     -DAPP_BINARY_DIR:STRING=${GAMES_DATADIR}/${PN}/bin
		     $(cmake-utils_use openal OPENAL)
		     $(cmake-utils_use gstreamer GSTREAMER)
		     $(cmake-utils_use llmozlib MOZLIB)
		     $(cmake-utils_use dbus DBUSGLIB)"
	if use fmod && ! use amd64 ; then
	  mycmakeargs="${mycmakeargs} -DFMOD:BOOL=TRUE"
	 else
	  mycmakeargs="${mycmakeargs} -DFMOD:BOOL=FALSE"
	fi
	# Linden Labs sse enabled processor build detection is broken, lets turn it on for
	# amd64 or (x86 and (sse or sse2))
	if { use amd64 || use see || use see2; }; then
	    append-flags "-DLL_VECTORIZE=1"
	fi
	# LL broke some code
	mycmakeargs="${mycmakeargs} -DGCC_DISABLE_FATAL_WARNINGS:BOOL=TRUE"
	cmake-utils_src_configure
}
src_compile() {
	# CMAKE_VERBOSE=on
	cmake-utils_src_compile
}

# Linden Labs uses viewer_manifest.py to install instead of cmake install
src_install() {
	cd "${WORKDIR}"/linden/indra/newview/
	# MY_ARCH="i686" only adds libs supplied by LL for NOT standalone builds.
	# The file list for standalone on i686 matches x86_64 but for one extra file that is of no harm on x86
	MY_ARCH="x86_64"
	# BUG:there is no secondlife-stripped or linux-crash-logger-stripped, move and create non-stripped ones for viewer_manifest.py and let portage do the stripping.
	mv "${WORKDIR}/${PN}_build/linux_crash_logger/linux-crash-logger" "${WORKDIR}/linden/indra/linux_crash_logger/linux-crash-logger-stripped" || die
	mv "${WORKDIR}/${PN}_build/newview/secondlife-bin" "${WORKDIR}/linden/indra/newview/secondlife-stripped" || die
	"${WORKDIR}"/linden/indra/newview/viewer_manifest.py  --actions="copy" --arch="${MY_ARCH}" --dest="${D}/${GAMES_DATADIR}/${PN}" || die
	
	# Set proper channel name and keep settings seperate from other installs.
#	echo '--channel "Second Life Trunk" --settings settings_trunk.xml' >> "${D}/${GAMES_DATADIR}/${PN}/gridargs.dat" || die
	
	# mozilla is not packed with secondlife, symbolic link it to the proper place.
	use llmozlib && ln -s "../../../../../usr/$(get_libdir)/llmozlib2/runtime_release" "${D}/${GAMES_DATADIR}/${PN}/app_settings/mozilla-runtime-linux-i686"
	
	# install crashlogger
# 	exeinto "${GAMES_DATADIR}/${PN}"
# 	newexe "${WORKDIR}/${PN}_build/linux_crash_logger/linux-crash-logger" linux-crash-logger.bin || die
	
	# vivox will work with a 64 bit build with 32 bit emul libs.
	if use vivox ; then
		exeinto "${GAMES_DATADIR}/${PN}/bin"
		doexe vivox-runtime/i686-linux/SLVoice || die
		exeinto "${GAMES_DATADIR}/${PN}/lib"
		doexe vivox-runtime/i686-linux/lib* || die
	fi
	
	# gentoo specific stuff
	games_make_wrapper "${PN}" ./secondlife "${GAMES_DATADIR}/${PN}" "/usr/$(get_libdir)/llmozlib2"
	newicon res/ll_icon.png "${PN}"_icon.png || die
	make_desktop_entry "${PN}" "Second Life Trunk" "${PN}"_icon.png
	prepgamesdirs
}

pkg_postinst() {
    games_pkg_postinst
    if use amd64 && use vivox ; then
      elog "The voice binary is 32 bit and may have problems in 64 bit"
      elog "systems with greater then 4G of RAM. See this thread for details"
      elog "http://www.nvnews.net/vbulletin/showthread.php?t=127984"
    fi
}

