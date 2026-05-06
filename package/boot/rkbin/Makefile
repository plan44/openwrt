# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rkbin
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rockchip-linux/rkbin.git
PKG_SOURCE_DATE:=2025-06-13
PKG_SOURCE_VERSION:=74213af1e952c4683d2e35952507133b61394862
PKG_MIRROR_HASH:=6031a672c66272b3003a2795336f4905058972527e01b881c77b316f5df0132c

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/trusted-firmware-a.mk
include $(INCLUDE_DIR)/package.mk

define Trusted-Firmware-A/Default
  NAME:=Rockchip $(1) SoCs
  BUILD_TARGET:=rockchip
endef

define Trusted-Firmware-A/rk3308
  BUILD_SUBTARGET:=armv8
  ATF:=rk33/rk3308_bl31_v2.26.elf
  TPL:=rk33/rk3308_ddr_589MHz_uart2_m1_v2.07.bin
endef

define Trusted-Firmware-A/rk3308-rock-pi-s
  NAME:=Radxa ROCK Pi S
  BUILD_SUBTARGET:=armv8
  ATF:=rk33/rk3308_bl31_v2.26.elf
  TPL:=rk33/rk3308_ddr_589MHz_uart0_m0_v2.07.bin
endef

define Trusted-Firmware-A/rk3566
  BUILD_SUBTARGET:=armv8
  ATF:=rk35/rk3568_bl31_v1.44.elf
  TPL:=rk35/rk3566_ddr_1056MHz_v1.21.bin
endef

define Trusted-Firmware-A/rk3568
  BUILD_SUBTARGET:=armv8
  ATF:=rk35/rk3568_bl31_v1.44.elf
  TPL:=rk35/rk3568_ddr_1560MHz_v1.21.bin
endef

define Trusted-Firmware-A/rk3568-e25
  NAME:=Radxa E25 board
  BUILD_SUBTARGET:=armv8
  ATF:=rk35/rk3568_bl31_v1.44.elf
  TPL:=rk35/rk3568_ddr_1560MHz_uart2_m0_115200_v1.21.bin
endef

define Trusted-Firmware-A/rk3588
  BUILD_SUBTARGET:=armv8
  ATF:=rk35/rk3588_bl31_v1.45.elf
  TPL:=rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.16.bin
endef

define Trusted-Firmware-A/rv1106
  BUILD_SUBTARGET:=cortexa7
  ATF:=rv11/rv1106_spl_v1.02.bin
  TPL:=rv11/rv1106_ddr_924MHz_v1.15.bin
endef

define Trusted-Firmware-A/rv1103-nand
  BUILD_SUBTARGET:=cortexa7
  ATF:=rv11/rv1106_spl_spi_nand_tb_v1.00.bin
  TPL:=rv11/rv1106_ddr_924MHz_tb_v1.15.bin
endef

define Trusted-Firmware-A/rv1106-nand
  BUILD_SUBTARGET:=cortexa7
  ATF:=rv11/rv1106_spl_spi_nand_tb_v1.00.bin
  TPL:=rv11/rv1106_ddr_924MHz_tb_v1.15.bin
endef

define Trusted-Firmware-A/rv1106-emmc
  BUILD_SUBTARGET:=cortexa7
  ATF:=rv11/rv1106_spl_emmc_tb_v1.00.bin
  TPL:=rv11/rv1106_ddr_924MHz_tb_v1.15.bin
endef

TFA_TARGETS:= \
	rk3308 \
	rk3308-rock-pi-s \
	rk3566 \
	rk3568 \
	rk3568-e25 \
	rk3588 \
	rv1106 \
	rv1103-nand \
	rv1106-nand \
	rv1106-emmc

ifeq ($(BUILD_VARIANT),rk3308-rock-pi-s)
  TPL_FILE:=rk3308_ddr_589MHz_uart0_m0_v2.07.bin
  define Download/rk3308-tpl-rock-pi-s
    FILE:=$(TPL_FILE)
    URL:=https://github.com/radxa/rkbin/raw/5696fab20dcac57c1458f72dc7604ba60e553adf/bin/rk33/
    HASH:=8a1a42df23cccb86a2dabc14a5c0e9227d64a51b9b83e9968ef5af3b30787f7d
  endef

  define Build/Prepare
	$(eval $(call Download,rk3308-tpl-rock-pi-s))
	$(call Build/Prepare/Default)

	$(CP) $(DL_DIR)/$(TPL_FILE) $(PKG_BUILD_DIR)/bin/rk33/
  endef
endif

ifeq ($(BUILD_VARIANT),rk3568-e25)
  TPL_FILE:=rk3568_ddr_1560MHz_uart2_m0_115200_v1.21.bin
  define Download/rk3568-tpl-e25
    FILE:=$(TPL_FILE)
    URL:=https://github.com/radxa/rkbin/raw/5696fab20dcac57c1458f72dc7604ba60e553adf/bin/rk35/
    HASH:=1815f9649dc5661a3ef184b052da39286e51453a66f6ff53cc3e345d65dfabd4
  endef

  define Build/Prepare
	$(eval $(call Download,rk3568-tpl-e25))
	$(call Build/Prepare/Default)

	$(CP) $(DL_DIR)/$(TPL_FILE) $(PKG_BUILD_DIR)/bin/rk35/
  endef
endif

define Build/Compile
endef

define Package/trusted-firmware-a/install
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)

	$(CP) $(PKG_BUILD_DIR)/bin/$(ATF) $(STAGING_DIR_IMAGE)/
	$(CP) $(PKG_BUILD_DIR)/bin/$(TPL) $(STAGING_DIR_IMAGE)/
endef

define Package/trusted-firmware-a-rv1106/install
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	# Stage raw binaries
	$(CP) $(PKG_BUILD_DIR)/bin/rv11/rv1106_spl_v1.02.bin $(STAGING_DIR_IMAGE)/
	$(CP) $(PKG_BUILD_DIR)/bin/rv11/rv1106_ddr_924MHz_v1.15.bin $(STAGING_DIR_IMAGE)/
	# Generate idblock.img using boot_merger with vendor INI
	chmod +x $(PKG_BUILD_DIR)/tools/boot_merger
	cd $(PKG_BUILD_DIR) && ./tools/boot_merger RKBOOT/RV1106MINIALL.ini
	$(CP) $(PKG_BUILD_DIR)/rv1106_idblock_v*.img $(STAGING_DIR_IMAGE)/rv1106-sd-idblock.img
	# Stage loaderimage for uboot-luckfox package
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/loaderimage $(STAGING_DIR_IMAGE)/loaderimage
endef

define Package/trusted-firmware-a-rv1103-nand/install
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	# Generate NAND idblock.img using TB (Thunderboot) binaries:
	#   rv1106_ddr_924MHz_tb_v1.15.bin   - DDR init (TB variant)
	#   rv1106_hpmcu_tb_v1.01.bin        - HPMCU (loaded at 0x40000)
	#   rv1106_spl_spi_nand_tb_v1.00.bin - SPL for SPI NAND
	# Use the W25N01XX-specific INI: the Luckfox Pico Mini B has a Winbond W25N01GV (ef:ae:21)
	# and rv1106_usbplug_w25n01xx_v1.09.bin correctly programs this NAND family.
	# The generic usbplug writes incorrectly to W25N01GV, leaving the uboot
	# partition corrupt on-flash; the TB SPL then falls back to USB boot.
	# The idblock is identical between INIs (same FlashBoot SPL binary).
	chmod +x $(PKG_BUILD_DIR)/tools/boot_merger
	cd $(PKG_BUILD_DIR) && ./tools/boot_merger RKBOOT/RV1106MINIALL_SPI_NAND_W25N01XX_TB.ini
	# INI specifies IDB_PATH=rv1106_idblock_v1.15.100.img
	$(CP) $(PKG_BUILD_DIR)/rv1106_idblock_v1.15.100.img $(STAGING_DIR_IMAGE)/rv1103-nand-idblock.img
	# USB download loader for rkdeveloptool db (maskrom/USB download mode)
	# W25N01XX variant uses rv1106_usbplug_w25n01xx_v1.09.bin for correct NAND writes
	$(CP) $(PKG_BUILD_DIR)/rv1106_download_v1.15.108.bin $(STAGING_DIR_IMAGE)/rv1103-nand-loader.bin
endef

define Package/trusted-firmware-a-rv1106-nand/install
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	# Generate NAND idblock.img for RV1106 SPI NAND (Pro, Max, Pro Max) using TB binaries:
	#   rv1106_ddr_924MHz_tb_v1.15.bin   - DDR init (TB variant)
	#   rv1106_hpmcu_tb_v1.01.bin        - HPMCU (loaded at 0x40000)
	#   rv1106_spl_spi_nand_tb_v1.00.bin - SPL for SPI NAND
	chmod +x $(PKG_BUILD_DIR)/tools/boot_merger
	cd $(PKG_BUILD_DIR) && ./tools/boot_merger RKBOOT/RV1106MINIALL_SPI_NAND_TB.ini
	# INI specifies IDB_PATH=rv1106_idblock_v1.15.100.img
	$(CP) $(PKG_BUILD_DIR)/rv1106_idblock_v1.15.100.img $(STAGING_DIR_IMAGE)/rv1106-nand-idblock.img
	# USB download loader for rkdeveloptool db (maskrom/USB download mode)
	$(CP) $(PKG_BUILD_DIR)/rv1106_download_v1.15.108.bin $(STAGING_DIR_IMAGE)/rv1106-nand-loader.bin
endef

define Package/trusted-firmware-a-rv1106-emmc/install
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	# Generate eMMC idblock.img for RV1106 eMMC (Ultra, Pi, 86Panel, Zero) using TB binaries:
	#   rv1106_ddr_924MHz_tb_v1.15.bin  - DDR init (TB variant)
	#   rv1106_hpmcu_tb_v1.01.bin       - HPMCU (loaded at 0x40000)
	#   rv1106_spl_emmc_tb_v1.00.bin    - SPL for eMMC
	chmod +x $(PKG_BUILD_DIR)/tools/boot_merger
	cd $(PKG_BUILD_DIR) && ./tools/boot_merger RKBOOT/RV1106MINIALL_EMMC_TB.ini
	# INI specifies IDB_PATH=rv1106_idblock_v1.15.100.img
	$(CP) $(PKG_BUILD_DIR)/rv1106_idblock_v1.15.100.img $(STAGING_DIR_IMAGE)/rv1106-emmc-idblock.img
	# USB download loader for rkdeveloptool db (maskrom/USB download mode)
	$(CP) $(PKG_BUILD_DIR)/rv1106_download_v1.15.108.bin $(STAGING_DIR_IMAGE)/rv1106-emmc-loader.bin
endef

$(eval $(call BuildPackage/Trusted-Firmware-A))
