
sudo qemu-system-x86_64 \
	--enable-kvm \
	-hda /dev/mapper/ptah-ptah--win7 \
	-m 2.1G \
	-rtc base=localtime,clock=host \
	-smp threads=4 \
	-usbdevice tablet \
	-cpu host \
	-vga qxl \
	-netdev bridge,id=hn0 -device e1000,netdev=hn0,id=nic1 \
	-spice port=5900,addr=127.0.0.1,disable-ticketing 


