# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop cmake-utils

DESCRIPTION="A PSP emulator written in C++."
HOMEPAGE="https://www.ppsspp.org/"
SRC_URI="
	https://github.com/hrydgard/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	!system-ffmpeg? ( https://github.com/hrydgard/ppsspp-ffmpeg/archive/a2e98d7ba4c7c5cac08608732c3058cb46e3e0ef.tar.gz -> ${P}-ffmpeg.tar.gz )
	https://github.com/hrydgard/ppsspp-lang/archive/f32328a88cbf368af90eb79bc7ad5420795d6585.tar.gz -> ${P}-assets_lang.tar.gz
	https://github.com/hrydgard/pspautotests/archive/e18cface3db64ccb96738dc128fe769b28fff65c.tar.gz -> ${P}-pspautotests.tar.gz
	https://github.com/hrydgard/minidx9/archive/7751cf73f5c06f1be21f5f31c3e2d9a7bacd3a93.tar.gz -> ${P}-dx9sdk.tar.gz
	https://github.com/hrydgard/glslang/archive/b16f7e6819267e57c3c244808d1981f0ce34acbc.tar.gz -> ${P}-ext_glslang.tar.gz
	https://github.com/Kingcom/armips/archive/770365d44df35d6e675c58bb2a774ca412278ef5.tar.gz -> ${P}-ext_armips.tar.gz
	https://github.com/Kingcom/tinyformat/archive/b7f5a22753c81d834ab5133d655f1fd525280765.tar.gz -> ${P}-ext_armips_ext_tinyformat.tar.gz
	https://github.com/KhronosGroup/SPIRV-Cross/archive/6381b2ff9c0d975af8fd2974c97aa12a69ab6cc6.tar.gz -> ${P}-ext_SPIRV-Cross.tar.gz
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+qt5 sdl headless libav +system-ffmpeg"
REQUIRED_USE="
	!headless? ( || ( qt5 sdl ) )
	?? ( qt5 sdl )
"

RDEPEND="sys-libs/zlib
	system-ffmpeg? (
		!libav? ( media-video/ffmpeg:= )
		libav? ( media-video/libav:= )
	)
	sdl? ( media-libs/libsdl2 )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
	)"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-assets-lookup.patch
	"${FILESDIR}"/${PN}-1.4-O2.patch
)

src_unpack() {
	unpack "${P}.tar.gz"
	cd "${S}" || die
	local i list=( assets_lang pspautotests dx9sdk ext_glslang ext_armips ext_SPIRV-Cross ext_armips_ext_tinyformat )
	if ! use system-ffmpeg; then
		list+=( ffmpeg )
	fi
	for i in "${list[@]}"; do
		tar xf "${DISTDIR}/${P}-${i}.tar.gz" --strip-components 1 -C "${i//_//}" || die "Failed to unpack ${P}-${i}.tar.gz"
	done
}

src_prepare() {
	if ! use system-ffmpeg; then
		sed -i -e "s#-O3#-O2#g;" "${S}"/ffmpeg/linux_*.sh || die
	fi
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DUSING_QT_UI=$(usex qt5)
		-DUSE_SYSTEM_FFMPEG=$(usex system-ffmpeg)
		-DHEADLESS=$(usex headless)
		)
	cmake-utils_src_configure
}

src_install() {
	use headless && dobin "${BUILD_DIR}/PPSSPPHeadless"
	insinto /usr/share/"${PN}"
	doins -r "${BUILD_DIR}/assets"
	if use qt5 || use sdl ; then
		dobin "${BUILD_DIR}/PPSSPP$(usex qt5 Qt SDL)"
		local i
		for i in 16 24 32 48 64 96 128 256 512 ; do
			doicon -s ${i} "icons/hicolor/${i}x${i}/apps/${PN}.png"
		done
		make_desktop_entry "PPSSPP$(usex qt5 Qt SDL)" "PPSSPP ($(usex qt5 Qt SDL))" "${PN}" "Game"
	fi
}

pkg_postinst() {
	if use system-ffmpeg; then
		ewarn "system-ffmpeg USE flag is enabled, some bugs might arise due to it."
		ewarn "See https://github.com/hrydgard/ppsspp/issues/9026 for more informations."
	fi
}
