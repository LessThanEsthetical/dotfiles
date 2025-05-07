#!/bin/bash

# Made it to easily launch QEMU virtual machines without using libvirt
# Includes usage of KVM, host's CPU, 4G of RAM, host's time, gives ability to connect to the Internet and output an audio via PipeWire

qemu-system-x86_64 system.img \
	-enable-kvm \
	-m 4G \
	-cpu host \
	-boot c \
	-rtc base=localtime \
	-net nic \
	-net user \
	-audiodev pipewire,id=snd0 \
	-device ich9-intel-hda \
	-device hda-output,audiodev=snd0
