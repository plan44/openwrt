# Useful commands for bootloader

## Set mtdparts in hex so that u-boot can read mtd partitions

Note: `# 256K = 0x40000, 512K = 0x80000, 4M = 0x400000, 5M = 0x500000, 95M = 0x5F00000, 36M = 0x2400000`

```
setenv mtdparts 'spi-nand0:0x40000(env),0x40000(idblock),0x80000(uboot),0x500000(boot),0x5F00000(rootfs),0x2400000(factory)'
saveenv
```

Then `mtd list` command can read the partitions:

```
  - 0x000000000000-0x000010000000 : "spi-nand0"
          - 0x000000000000-0x000000040000 : "env"
          - 0x000000040000-0x000000080000 : "idblock"
          - 0x000000080000-0x000000100000 : "uboot"
          - 0x000000100000-0x000000600000 : "boot"
          - 0x000000600000-0x000006500000 : "rootfs"
          - 0x000006500000-0x000008900000 : "factory"
```

## view chosen bootargs from fdt

```
mtd read spi-nand0 0x02000000 0x100000 0x400000
fdt addr 0x02000800
fdt print /chosen

```

## Boot into kernel **with** mtd partition support

```
mtd read boot 0x02000000; bootm 0x02000000
```

## Boot into kernel without mtd partition support:

```
mtd read spi-nand0 0x02000000 0x100000 0x400000
bootm 0x02000000
```