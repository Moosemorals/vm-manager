# sudo qemu-system-x86_64 -m 1024 -hda /dev/mapper/ptah-ptah--win7 -runas osric -enable-kvm -vga std -usbdevice tablet

sudo qemu-system-x86_64 --enable-kvm -hda /dev/mapper/ptah-ptah--win7 -m 2G -rtc base=localtime,clock=host -smp threads=4 -usbdevice tablet -cpu host -vga vmware -netdev bridge,id=hn0 -device e1000,netdev=hn0,id=nic1

