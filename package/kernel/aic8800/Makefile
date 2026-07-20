#
# Copyright (C) 2026 OpenWrt.org
#
include $(TOPDIR)/rules.mk

PKG_NAME:=aic8800
PKG_VERSION:=6.4.3.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Robert Grizzell <robert@grizzell.me>

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

AIC_FW_PATH:=/lib/firmware/aic8800dc_fw

define KernelPackage/aic8800-bsp
  SUBMENU:=Wireless Drivers
  TITLE:=AIC8800DC SDIO platform/BSP module
  DEPENDS:=@TARGET_rockchip_cortexa7 +aic8800-firmware
  FILES:=$(PKG_BUILD_DIR)/aic8800_bsp/aic8800_bsp.ko
  AUTOLOAD:=$(call AutoProbe,aic8800_bsp)
endef

define KernelPackage/aic8800-bsp/description
  SDIO platform/BSP module for the AICSemi AIC8800DC combo chip.
  Handles firmware download and exports the symbols used by the WiFi
  and Bluetooth modules.
endef

define KernelPackage/aic8800-wifi
  SUBMENU:=Wireless Drivers
  TITLE:=AIC8800DC fullmac WiFi driver
  DEPENDS:=+kmod-aic8800-bsp +@DRIVER_11AC_SUPPORT +@DRIVER_11AX_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/aic8800_fdrv/aic8800_fdrv.ko
  AUTOLOAD:=$(call AutoProbe,aic8800_fdrv)
endef

define KernelPackage/aic8800-bt
  SUBMENU:=Wireless Drivers
  TITLE:=AIC8800DC Bluetooth rfkill / low-power module
  DEPENDS:=+kmod-aic8800-bsp
  FILES:=$(PKG_BUILD_DIR)/aic8800_btlpm/aic8800_btlpm.ko
  AUTOLOAD:=$(call AutoProbe,aic8800_btlpm)
endef

define Package/aic8800-firmware
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=AIC8800DC firmware blobs
endef

define Package/aic8800-bt-attach
  SECTION:=net
  CATEGORY:=Network
  TITLE:=AIC8800DC Bluetooth HCI UART attach
  DEPENDS:=+kmod-aic8800-bt +bluez-utils
endef

define Package/aic8800-bt-attach/description
  procd init script that attaches the AIC8800DC Bluetooth UART (uart1 /
  /dev/ttyS1) to the kernel HCI H4 line discipline via hciattach, bringing
  up hci0. The BSP powers BT on and loads its firmware over SDIO, so this
  only binds the line discipline.
endef

KMAKE:= \
	$(KERNEL_MAKE) $(PKG_JOBS) \
	CONFIG_PLATFORM_ROCKCHIP=y \
	CONFIG_PLATFORM_UBUNTU=n \
	CONFIG_AIC_FW_PATH=$(AIC_FW_PATH)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/. $(PKG_BUILD_DIR)/
endef

define Build/Compile
	+$(KMAKE) M="$(PKG_BUILD_DIR)/aic8800_bsp" modules
	+$(KMAKE) M="$(PKG_BUILD_DIR)/aic8800_fdrv" \
		KBUILD_EXTRA_SYMBOLS="$(PKG_BUILD_DIR)/aic8800_bsp/Module.symvers" \
		modules
	+$(KMAKE) M="$(PKG_BUILD_DIR)/aic8800_btlpm" \
		KBUILD_EXTRA_SYMBOLS="$(PKG_BUILD_DIR)/aic8800_bsp/Module.symvers" \
		modules
endef

define Package/aic8800-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/aic8800dc_fw
	$(INSTALL_DATA) ./firmware/* $(1)/lib/firmware/aic8800dc_fw/
endef

define Package/aic8800-bt-attach/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/aic8800-bt.init $(1)/etc/init.d/aic8800-bt
endef

$(eval $(call KernelPackage,aic8800-bsp))
$(eval $(call KernelPackage,aic8800-wifi))
$(eval $(call KernelPackage,aic8800-bt))
$(eval $(call BuildPackage,aic8800-firmware))
$(eval $(call BuildPackage,aic8800-bt-attach))
