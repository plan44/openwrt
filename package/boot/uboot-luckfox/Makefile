#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=2017.09
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rgrizzell/uboot-luckfox.git
PKG_SOURCE_DATE:=2026-03-26
PKG_SOURCE_VERSION:=08d5d37be95d0138f4796c7681f11d88b196c1cd
PKG_MIRROR_HASH:=skip

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=rockchip
  UENV:=default
  HIDDEN:=1
endef

define U-Boot/rv1106-sd
  BUILD_SUBTARGET:=cortexa7
  NAME:=Luckfox Pico RV1106 SD
  UBOOT_CONFIG:=luckfox_rv1106_uboot
  DEPENDS:=+PACKAGE_u-boot-$(1):trusted-firmware-a-rv1106
  BUILD_DEVICES:=luckfox_pico-mini
endef

UBOOT_TARGETS := rv1106-sd

# Vendor U-Boot 2017.09 uses _defconfig (no _config compat rule)
define Build/Configure
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		$(UBOOT_CONFIG)_defconfig
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(CP) $(PKG_BUILD_DIR)/u-boot.img $(STAGING_DIR_IMAGE)/rv1106-sd-uboot.img
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
