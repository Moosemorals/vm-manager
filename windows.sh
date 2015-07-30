
qemu-system-x86_64 \
	--enable-kvm \
	-hda /dev/mapper/ptah-ptah--win7 \
	-m 2.1G \
	-rtc base=localtime,clock=host \
	-smp threads=4 \
	-usbdevice tablet \
	-cpu host \
	-vga qxl \
	-net nic -net tap,ifname=tap0,script=no,downscript=no \
	-spice port=5900,addr=127.0.0.1,disable-ticketing \
	-daemonize  \

