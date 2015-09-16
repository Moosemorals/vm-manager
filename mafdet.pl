#!/usr/bin/perl -w


use strict;
use warnings;

# Configuration

my $name = "mafdet";
my $id = 1;

# Configuration ends

my $iface="tap${id}";
my $serial = 5900 + ($id * 2);
my $monitor = 5901 + ($id * 2);

if (@ARGV == 0 || @ARGV > 1) {		
	print "Usage: $0 {start|stop}\n";
	exit 1;
} elsif ($ARGV[0] eq 'start') {
	# Create a tap device, bring it up and add it to the bride.

	system "/bin/ip tuntap add dev $iface mode tap user osric";
	system "/bin/ip link set $iface up";
	system "/sbin/brctl addif br0 $iface";

	# start the vm
my (@vm) = ( '/usr/bin/qemu-system-x86_64',
		'--enable-kvm',
		'-hda', "/dev/mapper/ptah-${name}_main",
		'-m', '2G',
		'-rtc', 'base=localtime,clock=host',
		'-smp', 'threads=4',
		'-usbdevice', 'tablet',
		'-cpu', 'host',
		'-vga', 'none',
		'-display', 'none',
		'-serial', "tcp:127.0.0.1:$serial,server,nowait" ,
		'-monitor', "tcp:127.0.0.1:$monitor,server,nowait" ,
		'-netdev', "type=tap,ifname=$iface,script=no,downscript=no,id=net0",
		'-device', 'virtio-net,netdev=net0,mac=08:00:27:6d:69:5c',
		'-daemonize'
	);

	exec @vm;
} elsif ($ARGV[0] eq 'stop') {
	# Connect to the control port of the vm, and close it.
	open CONTROL, "|-", "/bin/nc localhost $monitor";
	print CONTROL "system_powerdown\n";
	close CONTROL;

	# remove the tap device from the bridge, brint it down and delete it.
	system "/sbin/brctl delif br0 $iface";
	system "/bin/ip link set $iface down";
	system "/bin/ip tuntap del dev $iface mode tap";
}
