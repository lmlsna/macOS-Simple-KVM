# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

Forked from [@FoxletFox](https://twitter.com/foxletfox)

New to macOS and KVM? Check [the FAQs.](docs/FAQs.md)

## Getting Started
You'll need a Linux system with `qemu` (3.1 or later), `python3`, `pip` and the KVM modules enabled. A Mac is **not** required. Some examples for different distributions:

```
sudo apt-get install qemu-system qemu-utils python3 python3-pip  # for Ubuntu, Debian, Mint, and PopOS.
sudo pacman -S qemu python python-pip python-wheel  # for Arch.
sudo xbps-install -Su qemu python3 python3-pip   # for Void Linux.
sudo zypper in qemu-tools qemu-kvm qemu-x86 qemu-audio-pa python3-pip  # for openSUSE Tumbleweed
sudo dnf install qemu qemu-img python3 python3-pip # for Fedora
sudo emerge -a qemu python:3.4 pip # for Gentoo
```

## Step 1
Run `./bootstrap.sh` to download installation media for macOS (internet required). The default installation uses Catalina, but you can choose which version to get by adding either `--high-sierra`, `--mojave`, or `--catalina`. For example:
```
./bootstrap.sh --mojave
```
> Note: If you're running on a headless system (such as on Cloud providers), you will need `-nographic` and `-vnc :0 -k en-us` for VNC support.

## Step 2 (Headless Systems)
If you're using a cloud-based/headless system, you can use `headless.sh` to set up a quick VNC instance. Settings are defined through variables as seen in the following example. VNC will start on port `5900` by default.
```
HEADLESS=1 MEM=1G CPUS=2 SYSTEM_DISK=MyDisk.qcow2 ./headless.sh
```

## Step 3

You're done!

To fine-tune the system and improve performance, look in the `docs` folder for more information on [adding memory](docs/guide-performance.md), setting up [bridged networking](docs/guide-networking.md), adding [passthrough hardware (for GPUs)](docs/guide-passthrough.md), tweaking [screen resolution](docs/guide-screen-resolution.md), and enabling sound features.
