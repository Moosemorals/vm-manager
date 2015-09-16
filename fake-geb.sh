#/bin/sh

## Configuration

NAME=fake-geb
ID=2

## Configuration ends


IFACE=tap${ID}
SERIAL=$(expr $ID \* 2)
MONITOR=$(expr $SERIAL + 5901)
SERIAL=$(expr $SERIAL + 5900)

case "$1" in
	start)

		ip tuntap add dev $IFACE mode tap user osric
		ip link set $IFACE up
		brctl addif br0 $IFACE

		qemu-system-x86_64 \
			--enable-kvm \
			-hda /dev/mapper/ptah-fake_geb \
			-m 2G \
			-rtc base=localtime,clock=host \
			-smp threads=4 \
			-usbdevice tablet \
			-cpu host \
			-vga none \
			-display none \
			-serial tcp:127.0.0.1:$SERIAL,server,nowait \
			-monitor tcp:127.0.0.1:$MONITOR,server,nowait \
			-netdev type=tap,ifname=$IFACE,script=no,downscript=no,id=net0 \
			-device virtio-net,netdev=net0,mac=08:00:27:3d:6e:3a \
			-daemonize

	;;
	stop)
		echo "q" | nc localhost $MONITOR 
		brctl delif br0 $IFACE
		ip link set $IFACE down
		ip tuntap del dev $IFACE mode tap
	;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1;
esac
