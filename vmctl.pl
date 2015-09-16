#!/usr/bin/perl -w

# Start and stop virtual machines.
# Reads config from "name.conf"
#
# config is name: value pairs, blank lines and lines starting with # are ignored.

use strict;
use warnings;

die "Must be root" unless $> == 0;

my (@required_config) = qw/name id hda mac/;
my (%default_config) = (cpu=>'host', netdev=>'virtio-net', shutdown_cmd=>'system_powerdown');

sub read_config($) {
	my ($confFile) = @_;
	$confFile = "${confFile}.conf";
	my (%opts) = %default_config;
	open CONFIG, "<", $confFile || die "Can't open config file [$confFile]: $!";
	while (<CONFIG>) {
		next if /^$/;
		next if /^#/;
		chomp;
		my ($name, $value) = split(/:\s*/, $_, 2);
		$value =~ s/\s*$//;
		$opts{$name} = $value;
	}
	close CONFIG;

	foreach my $key (@required_config) {
		if (!exists $opts{$key}) {
			print "Missing $key from $confFile\n";
			exit 1;
		}
	}
	return %opts;
}



if (@ARGV != 2) {		
	print "Usage: $0 {name} {start|stop}\n";
	exit 1;
} 

my (%opts) = read_config($ARGV[0]);

my $cmd = $ARGV[1];

my $id = $opts{id};
my $iface="tap${id}";
my $serial = 5900 + ($id * 2);
my $monitor = 5901 + ($id * 2);

if ($cmd eq 'start') {
	# Create a tap device, bring it up and add it to the bride.

	system "/bin/ip tuntap add dev $iface mode tap user osric";
	system "/bin/ip link set $iface up";
	system "/sbin/brctl addif br0 $iface";

	# start the vm
	my (@vm) = ( '/usr/bin/qemu-system-x86_64',
		'--enable-kvm',
		'-hda', $opts{hda},
		'-m', '2G',
		'-rtc', 'base=localtime,clock=host',
		'-smp', 'threads=4',
		'-usbdevice', 'tablet',
		'-cpu', $opts{cpu},
		'-vga', 'none',
		'-display', 'none',
		'-serial', "tcp:127.0.0.1:$serial,server,nowait" ,
		'-monitor', "tcp:127.0.0.1:$monitor,server,nowait" ,
		'-netdev', "type=tap,ifname=$iface,script=no,downscript=no,id=net0",
		'-device', "${opts{netdev}},netdev=net0,mac=${opts{mac}}",
		'-daemonize'
	);

	print "Starting ${opts{name}}...\n", join(" ", @vm), "\n";
	exec @vm;
} elsif ($cmd eq 'debug') {
	# Create a tap device, bring it up and add it to the bride.

	system "/bin/ip tuntap add dev $iface mode tap user osric";
	system "/bin/ip link set $iface up";
	system "/sbin/brctl addif br0 $iface";

	# start the vm
	my (@vm) = ( '/usr/bin/qemu-system-x86_64',
		'--enable-kvm',
		'-hda', $opts{hda},
		'-m', '2G',
		'-rtc', 'base=localtime,clock=host',
		'-smp', 'threads=4',
		'-usbdevice', 'tablet',
		'-cpu', $opts{cpu},
		'-vga', 'qxl',
		'-display', 'sdl',
		'-serial', "tcp:127.0.0.1:$serial,server,nowait" ,
		'-monitor', "tcp:127.0.0.1:$monitor,server,nowait" ,
		'-netdev', "type=tap,ifname=$iface,script=no,downscript=no,id=net0",
		'-device', "${opts{netdev}},netdev=net0,mac=${opts{mac}}",
	);

	print "Starting ${opts{name}}...\n", join(" ", @vm), "\n";
	exec @vm;
} elsif ($cmd eq 'stop') {
	# Connect to the control port of the vm, and close it.
	open CONTROL, "|-", "/bin/nc localhost $monitor";
	print CONTROL $opts{shutdown_cmd}, "\n";
	close CONTROL;

	# remove the tap device from the bridge, brint it down and delete it.
	system "/sbin/brctl delif br0 $iface";
	system "/bin/ip link set $iface down";
	system "/bin/ip tuntap del dev $iface mode tap";
} else {
	print "Unknown command: $cmd\n";
}
