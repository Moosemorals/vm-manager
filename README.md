
# VM Control

A simple perl script (that has evolved from an even more simple bash script)
to manage a small fleet of virtual machines

## Usage

    sudo vmctl.pl {name} {start|stop}

where `name` is the name of an (already configured) vm with a config file something
like

```
id: 1
name: testVM
hda: /dev/mapper/vg_testVM_main
mac: 36:de:b1:d9:48:04
```

`start` creates a tap device (using `id` from the file to number the device), 
brings it up and adds it to an existing bridge (`br0` is assumed to exist).

Then the script runs qemu to start the vm, with a tcp serial port at 5900 + `id` * 2
and a qemu tcp monitor at 5901 + `id` * 2.

`stop` sends a `system_powerdown` message to qemu and waits for qemu to exit. 
Then it removes the tap device from the bridge, takes it down and deletes it.

## TODO:

* Check if the tap device has already been created
* Check if the machine is already running
* Add a CDROM if there is a `cdrom` stanza in the config file
* Move to `-device` instead of `-hda` for drives
* Add `create` mode, which will turn on vga (on the virtual hardware), sdl 
  (for display), and not daemonize (because thats incompatiable with display).


