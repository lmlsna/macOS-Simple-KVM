#!/bin/bash

# jumpstart.sh: Fetches BaseSystem and converts it to a viable format.
# by Foxlet <foxlet@furcode.co>

VMDIR="$(dirname "$0")"
OVMF="$VMDIR/firmware"
TOOLS="$VMDIR/tools"
SIZE="64G"
MEMORY="2G"
OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
#export QEMU_AUDIO_DRV=pa
#QEMU_AUDIO_DRV=pa

cd "$VMDIR"

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -s, --high-sierra   Fetch High Sierra media."
    echo " -m, --mojave        Fetch Mojave media."
    echo " -c, --catalina      Fetch Catalina media."
    echo
}

error() {
    local error_message="$*"
    echo "${error_message}" 1>&2;
}

argument="$1"
case $argument in
    -h|--help)
        print_usage
        ;;
    -s|--high-sierra)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.13 || exit 1;
        ;;
    -m|--mojave)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.14 || exit 1;
        ;;
    -c|--catalina|*)
        "$TOOLS/FetchMacOS/fetch.sh" -v 10.15 || exit 1;
        ;;
esac

"$TOOLS/dmg2img" "$TOOLS/FetchMacOS/BaseSystem/BaseSystem.dmg" "$VMDIR/BaseSystem.img"

# Verify qemu-img is installed
command -v qemu-img &>/dev/null
if [ $? -ne 0 ]; then
    error "This script requires the qemu-img command, but could not find it."
    error "Please see the README.md for details on installing this package."
    exit 2
fi

# Create image
qemu-img create -f "qcow2" "MyDisk.qcow2" "$SIZE"

if [ $? -ne 0 ]; then
    error "Problem creating disk image. Aborting."
    exit 6
fi


# Run basic.sh

qemu-system-x86_64 \
    -enable-kvm \
    -m $MEMORY \
    -machine q35,accel=kvm \
    -smp 4,cores=2 \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -device ich9-intel-hda -device hda-output \
    -usb -device usb-kbd -device usb-mouse \
    -netdev user,id=net0 \
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file="ESP.qcow2" \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=InstallMedia,format=raw,if=none,file="BaseSystem.img" \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=SystemDisk,if=none,file="MyDisk.qcow2" \
    -device ide-hd,bus=sata.4,drive=SystemDisk

# make.sh: Generate customized libvirt XML.
# by Foxlet <foxlet@furcode.co>

MACHINE="$(qemu-system-x86_64 --machine help | grep q35 | cut -d" " -f1 | grep -Eoe ".*-[0-9.]+" | sort -rV | head -1)"
OUT="template.xml"

sed -e "s|%VMDIR%|$VMDIR|g" -e "s|%MACHINE%|$MACHINE|g" "$VMDIR/tools/template.xml.in" > "$OUT"
echo "$OUT has been generated in $VMDIR"

sudo virsh define "$OUT"
