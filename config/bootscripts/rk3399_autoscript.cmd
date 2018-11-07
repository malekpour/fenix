echo "Run Khadas boot script"

kbi boarddetect

if test ${board_type} = 0; then
	echo "Unsupported board detected! Stop here. Reboot...";
	sleep 5;
	reset;
fi

setenv emmc_root_part 7
setenv emmc_boot_part 7
setenv sd_root_part   2
setenv sd_boot_part   1

if test ${devnum} = 0; then
	echo "Uboot loaded from eMMC.";
	setenv boot_env_part ${emmc_boot_part};
	setenv mark_prefix "boot/"
else if test ${devnum} = 1; then
	echo "Uboot loaded from SD.";
	setenv boot_env_part ${sd_boot_part};
	setenv mark_prefix ""
fi;fi;

if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
	if test ${board_type} = 1; then
		setenv boot_dtb "rk3399-khadas-edge.dtb";
	else if test ${board_type} = 2; then
		setenv boot_dtb "rk3399-khadas-edgev.dtb";
	else if test ${board_type} = 3; then
		setenv boot_dtb "rk3399-khadas-captain.dtb";
	fi;fi;fi
else
	if test ${board_type} = 1; then
		setenv boot_dtb "rk3399-khadas-edge-linux.dtb";
	else if test ${board_type} = 2; then
		setenv boot_dtb "rk3399-khadas-edgev-linux.dtb";
	else if test ${board_type} = 3; then
		setenv boot_dtb "rk3399-khadas-captain-linux.dtb";
	fi;fi;fi
fi

if test ${devnum} = 0; then
	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		setenv dtb_prefix "/boot/dtb/rockchip/";
	else
		setenv dtb_prefix "/boot/dtb/";
	fi
else if test ${devnum} = 1; then
	if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
		setenv dtb_prefix "/dtb/rockchip/";
	else
		setenv dtb_prefix "/dtb/";
	fi
fi;fi;

echo DTB: ${dtb_prefix}${boot_dtb}

if test -e mmc ${devnum}:${boot_env_part} ${mark_prefix}.next; then
	setenv condev "earlyprintk console=ttyS2,1500000n8 console=tty0"
else
	setenv condev "earlyprintk console=ttyFIQ0,1500000n8 console=tty0"
fi

setenv boot_start booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}

# Import environment from env.txt
if load ${devtype} ${devnum}:${boot_env_part} ${ramdisk_addr_r} /boot/env.txt || load ${devtype} ${devnum}:${boot_env_part} ${ramdisk_addr_r} env.txt; then
	echo "Import env.txt";
	env import -t ${ramdisk_addr_r} ${filesize}
fi

setenv bootargs "${bootargs} ${condev} rw root=${rootdev} rootfstype=ext4 init=/sbin/init rootwait board_type=${board_type} board_type_name=${board_type_name}"

for distro_bootpart in ${devplist}; do
	echo "Scanning ${devtype} ${devnum}:${distro_bootpart}..."

	if load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} uInitrd; then
		if load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} zImage; then
			if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${dtb_prefix}${boot_dtb}; then
				run boot_start;
			fi;
		fi;
	fi;

done