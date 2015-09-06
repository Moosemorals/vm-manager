
qemu-system-x86_64 \
	--enable-kvm \
	-hda /dev/mapper/ptah-seshat_main \
	-cdrom /home/osric/ISO/mini.iso \
	-m 2G \
	-rtc base=localtime,clock=host \
	-smp threads=4 \
	-usbdevice tablet \
	-cpu qemu32 \
	-vga qxl \
	-display sdl \
	-serial tcp:127.0.0.1:5900,server,nowait \
	-monitor tcp:127.0.0.1:5901,server,nowait \
	-netdev type=tap,ifname=tap0,script=no,downscript=no,id=net0 \
	-device rtl8139,netdev=net0,mac=08:00:27:1d:47:b6 \
	-daemonize
