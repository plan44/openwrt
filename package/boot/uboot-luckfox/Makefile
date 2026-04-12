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
PKG_SOURCE_DATE:=2026-04-14
PKG_SOURCE_VERSION:=a1a3a1f25bae1101ccfa65dc489ad8d2e942c8a5
PKG_SOURCE:=uboot-luckfox-$(PKG_SOURCE_DATE)-$(PKG_SOURCE_VERSION).tar.zst
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

define U-Boot/rv1103-nand
  BUILD_SUBTARGET:=cortexa7
  NAME:=Luckfox Pico RV1103 SPI NAND
  UBOOT_CONFIG:=luckfox_rv1106_spi_nand_tb
  DEPENDS:=+PACKAGE_u-boot-$(1):trusted-firmware-a-rv1103-nand
  BUILD_DEVICES:=luckfox_pico-mini-nand
endef

UBOOT_TARGETS := rv1106-sd rv1103-nand

# Vendor U-Boot 2017.09 uses _defconfig (no _config compat rule)
define Build/Configure
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		$(UBOOT_CONFIG)_defconfig
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
ifeq ($(BUILD_VARIANT),rv1103-nand)
	# Stage u-boot.img (FIT format with external data) directly.
	# The rkbin NAND SPL (rv1106_spl_spi_nand_tb_v1.00.bin) is a U-Boot SPL
	# with CONFIG_SPL_KERNEL_BOOT=y; it boots the kernel directly from the
	# "boot" NAND partition (1MB). The "uboot" partition FIT is staged here
	# for recovery/download mode; normal TB boot does not use this partition.
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/u-boot.img \
		$(STAGING_DIR_IMAGE)/rv1103-nand-uboot.img
else
	# Stage u-boot.img (FIT format, d00dfeed magic) directly.
	# The rkbin SD SPL (rv1106_spl_v1.02.bin) is a U-Boot SPL that expects
	# FDT_MAGIC in the "uboot" partition. The loaderimage (LOADER magic) is
	# unrecognized by the SPL. u-boot.img contains firmware@1 at load 0x200000.
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/u-boot.img \
		$(STAGING_DIR_IMAGE)/rv1106-sd-uboot.img
endif
endef

define Build/Clean
	rm -rf $(PKG_BUILD_DIR)
	rm -f $(DL_DIR)/$(PKG_SOURCE)
	rm -f $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-uboot.img
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
