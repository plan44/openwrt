# SPDX-License-Identifier: GPL-2.0-only
ARCH:=arm
SUBTARGET:=cortexa7
CPU_TYPE:=cortex-a7
CPU_SUBTYPE:=neon-vfpv4
BOARDNAME:=RV1103B Omega4 (32 bit)
FEATURES:=audio usb usbgadget gpio fpu squashfs nand ubifs dt-overlay
KERNELNAME:=zImage
DEFAULT_PACKAGES += nand-utils

define Target/Description
  Build firmware for RV1103B Omega4 using the external migration kernel.
endef
