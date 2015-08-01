
qemu-system-x86_64 \
	--enable-kvm \
	-drive file=/dev/mapper/ptah-ptah--win7,if=virtio \
	-m 2.1G \
	-rtc base=localtime,clock=host \
	-smp threads=4 \
	-usbdevice tablet \
	-cpu host \
	-vga qxl \
	-monitor tcp:127.0.0.1:5901,server,nowait \
	-netdev type=tap,ifname=tap0,script=no,downscript=no,id=net0 \
	-device virtio-net,netdev=net0 \
	-spice port=5900,addr=127.0.0.1,disable-ticketing \
	-daemonize  \

