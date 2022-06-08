#!/usr/bin/env bash
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <path to extracted kernel source> <kernel version> <kernel config>"
    exit 1
fi
KERNEL_VERSION=$2

mkdir -p ~/linux-tmp
cd ~/linux-tmp
cp -r $1 linux-$KERNEL_VERSION
cd linux-$KERNEL_VERSION
if [ -z "$3" ]; then
    cp $3 .config
else
    wget https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/linux/trunk/config
fi
make
make modules
echo "Executing sudo for:"
echo "make modules_install"
sudo make modules_install
cd ../
mkdir linux-packaged
cd linux-packaged
cp ../linux-$KERNEL_VERSION/arch/x86 .
cp ../linux-$KERNEL_VERSION/System.map .
cp /lib/modules/$KERNEL_VERSION .
echo "Executing sudo for writing mkinitcpio config file"
sudo echo "ALL_config=\"/etc/mkinitcpio.conf\"" >> /etc/mkinitcpio.d/$KERNEL_VERSION.preset
sudo echo "ALL_kver=\"/boot/vmlinuz-$KERNEL_VERSION\"" >> /etc/mkinitcpio.d/$KERNEL_VERSION.preset
sudo echo "PRESETS=('default' 'fallback')" >> /etc/mkinitcpio.d/$KERNEL_VERSION.preset
sudo echo "default_image=\"/boot/initramfs-$KERNEL_VERSION.img\"" >> /etc/mkinitcpio.d/$KERNEL_VERSION.preset
sudo echo "fallback_image=\"/boot/initramfs-$KERNEL_VERSION-fallback.img\"" >> /etc/mkinitcpio.d/$KERNEL_VERSION.preset
sudo echo "fallback_options=\"-S autodetect\"" >> /etc/mkinitcpio.d/$KERNEL_VERSION.preset
mkinitcpio -p $KERNEL_VERSION -g ./initramfs --kernelimage ./x86/boot/bzImage --kernelfile ./System.map
cd ..
tar -cvf linux.tar linux-packaged
echo "Done! The linux tarball now should be at $(pwd)/linux.tar!"