#/bin/sh

IFACE=tap1

case "$1" in
	start)

ip tuntap add dev $IFACE mode tap user osric
ip link set $IFACE up
brctl addif br0 $IFACE

qemu-system-x86_64 \
	--enable-kvm \
	-hda /dev/mapper/ptah-mafdet_main \
	-m 2G \
	-rtc base=localtime,clock=host \
	-smp threads=4 \
	-usbdevice tablet \
	-cpu host \
	-vga none \
	-display none \
	-serial tcp:127.0.0.1:5910,server,nowait \
	-monitor tcp:127.0.0.1:5911,server,nowait \
	-netdev type=tap,ifname=$IFACE,script=no,downscript=no,id=net0 \
	-device virtio-net,netdev=net0,mac=08:00:27:6d:69:5c \
	-daemonize

	;;
	stop)
		echo "q" | nc localhost 5911
		brctl delif br0 $IFACE
		ip link set $IFACE down
		ip tuntap del dev $IFACE mode tap
	;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1;
esac
