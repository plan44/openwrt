#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ROCKCHIP_MENU:=Rockchip support

define KernelPackage/rk_dvbm-rockchip
  TITLE:=Rockchip RGA 2D support
  SUBMENU:=$(ROCKCHIP_MENU)
  DEPENDS:=@TARGET_rockchip
  KCONFIG:= \
  	CONFIG_ROCKCHIP_DVBM_PROC_FS=y \
	CONFIG_ROCKCHIP_DVBM
  FILES:= $(LINUX_DIR)/drivers/video/rockchip/dvbm/rk_dvbm.ko
  AUTOLOAD:=$(call AutoProbe,rk_dvbm)
endef

define KernelPackage/rk_dvbm-rockchip/description
 rk dvbm support for Rockchip.
endef

$(eval $(call KernelPackage,rk_dvbm-rockchip))

define KernelPackage/rga3-rockchip
  TITLE:=Rockchip RGA 2D support
  SUBMENU:=$(ROCKCHIP_MENU)
  DEPENDS:=@TARGET_rockchip
  KCONFIG:= \
	CONFIG_ROCKCHIP_RGA_ASYNC=y \
  	CONFIG_ROCKCHIP_RGA_PROC_FS=y \
	CONFIG_ROCKCHIP_RGA_DEBUGGER=n \
  	CONFIG_ROCKCHIP_RGA_DEBUG_FS=n \
	CONFIG_ROCKCHIP_MULTI_RGA
  FILES:= $(LINUX_DIR)/drivers/video/rockchip/rga3/rga3.ko
  AUTOLOAD:=$(call AutoProbe,rga3)
endef

define KernelPackage/rga3-rockchip/description
 rga3 support for Rockchip.
endef

$(eval $(call KernelPackage,rga3-rockchip))

define KernelPackage/rve-rockchip
  TITLE:=Rockchip RVE support
  SUBMENU:=$(ROCKCHIP_MENU)
  DEPENDS:=@TARGET_rockchip
  KCONFIG:= \
	CONFIG_ROCKCHIP_RVE_DEBUGGER=n \
  CONFIG_ROCKCHIP_RVE_PROC_FS=y \
	CONFIG_ROCKCHIP_RVE
  FILES:= $(LINUX_DIR)/drivers/video/rockchip/rve/rve.ko
  AUTOLOAD:=$(call AutoProbe,rve)
endef

define KernelPackage/rga3-rockchip/description
 rga3 support for Rockchip.
endef

$(eval $(call KernelPackage,rga3-rockchip))

define KernelPackage/rknpu-rockchip
  TITLE:=Rockchip NPU support
  SUBMENU:=$(ROCKCHIP_MENU)
  DEPENDS:=@TARGET_rockchip
  KCONFIG:= \
	CONFIG_ROCKCHIP_RKNPU_DEBUG_FS=y \
	CONFIG_ROCKCHIP_RKNPU_PROC_FS=y \
	CONFIG_ROCKCHIP_RKNPU_DRM_GEM=n \
	CONFIG_ROCKCHIP_RKNPU_DMA_HEAP=y \
	CONFIG_ROCKCHIP_RKNPU_FENCE=n \
	CONFIG_ROCKCHIP_RKNPU_SRAM=n \
	CONFIG_ROCKCHIP_RKNPU
  FILES:= $(LINUX_DIR)/drivers/rknpu/rknpu.ko
  AUTOLOAD:=$(call AutoProbe,rknpu)
endef

define KernelPackage/rknpu-rockchip/description
 NPU support for Rockchip.
endef

$(eval $(call KernelPackage,rknpu-rockchip))

define KernelPackage/rkisp-rockchip
  TITLE:=Rockchip ISP support
  SUBMENU:=$(ROCKCHIP_MENU)
  DEPENDS:=@TARGET_rockchip +kmod-rk_dvbm-rockchip
  KCONFIG:= \
  	CONFIG_VIDEO_ROCKCHIP_ISP_VERSION_V1X=y \
  	CONFIG_VIDEO_ROCKCHIP_ISP_VERSION_V20=y \
  	CONFIG_VIDEO_ROCKCHIP_ISP_VERSION_V21=y \
	CONFIG_VIDEO_ROCKCHIP_ISP_VERSION_V30=y \
	CONFIG_VIDEO_ROCKCHIP_ISP_VERSION_V32=y \
	CONFIG_VIDEO_ROCKCHIP_ISP
  FILES:= $(LINUX_DIR)/drivers/media/platform/rockchip/isp/video_rkisp.ko
  AUTOLOAD:=$(call AutoLoad,61, video_rkisp)
  $(call AddDepends/camera)
endef

define KernelPackage/rkisp-rockchip/description
 ISP support for Rockchip .
endef

$(eval $(call KernelPackage,rkisp-rockchip))

define KernelPackage/rkcif-rockchip
  TITLE:=Rockchip Camera support
  SUBMENU:=$(ROCKCHIP_MENU)
  DEPENDS:=@TARGET_rockchip
  KCONFIG:= \
	CONFIG_ROCKCHIP_CIF_WORKMODE_PINGPONG=y \
	CONFIG_ROCKCHIP_CIF_WORKMODE_ONEFRAME=n \
	CONFIG_ROCKCHIP_CIF_USE_DUMMY_BUF=y \
	CONFIG_ROCKCHIP_CIF_USE_NONE_DUMMY_BUF=n \
	CONFIG_ROCKCHIP_CIF_USE_MONITOR=n \
	CONFIG_VIDEO_ROCKCHIP_CIF
  FILES:= $(LINUX_DIR)/drivers/media/platform/rockchip/cif/video_rkcif.ko
  AUTOLOAD:=$(call AutoLoad,60, video_rkcif)
  $(call AddDepends/camera)
endef

define KernelPackage/rkcif-rockchip/description
 Camera support for Rockchip.
endef

$(eval $(call KernelPackage,rkcif-rockchip))

