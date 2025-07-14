#!/bin/bash

# go to https://github.com/rockchip-linux/rkdeveloptool, follow instructions to build,
# UPDATE this variable to where the binary is located
CMD="sudo /home/ubuntu/rkdeveloptool/rkdeveloptool"

# UPDATE this to match prefix of output files from build system
prefix="p44-lc-xx-1.8.2.16-r20127-db1c01d738-rockchip-cortexa7-luckfox_pico-max-squashfs-"

# download.bin can be found in compiled build system at build_dir/target-arm_cortex-a7+neon-vfpv4_musl_eabi/u-boot-rv1106-sfc/u-boot-2024-03-22-6cc11e30/download.bin
# also included in this repo in `onion/` directory
${CMD} db download.bin

## script assumes following partition layout:
# partitions:   [  env  ][idblock][ uboot ][      boot      ][            rootfs (ubi,etc)           ]...
# offset(kb):   0      256K     512K     1024K            6144K
# sectors:      0x0    0x200    0x400    0x800            0x3000
#
# rkdeveloptool uses 512-byte sectors
#
# to setup this partition layout on device, enter bootloader prompt and run:
#   #setenv mtdparts 'spi-nand0:0x40000(env),0x40000(idblock),0x80000(uboot),0x500000(boot),0x5F00000(ubi),0x2400000(factory)'
#   setenv mtdparts 'spi-nand0:0x40000(env),0x40000(idblock),0x80000(uboot),0x500000(boot),0x5F00000(rootfs),0x2400000(factory)'
#   saveenv

# ENV at offset 0
#${CMD} wl 0x00000000 ${prefix}env.img
# IDBLOCK at offset 256K
#${CMD} wl 0x00000200 ${prefix}idblock.img
# U-Boot at offset 512K
#${CMD} wl 0x00000400 ${prefix}uboot.img
# Kernel at offset 1MB
${CMD} wl 0x00000800 ${prefix}boot.img
# RootFS at offset 6MB
${CMD} wl 0x000003000 ${prefix}rootfs.img
