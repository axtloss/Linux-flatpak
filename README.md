# Linux-flatpak <img src="https://github.com/axtloss/Linux-flatpak/blob/main/linux-flatpak.png?raw=true" height=30 width=30>
<img src="https://github.com/axtloss/Linux-flatpak/blob/main/linux-flatpak.png?raw=true" height=100 width=100>
packaging the linux kernel as a flatpak, just because

https://user-images.githubusercontent.com/60044824/172443953-37a01a4a-66d8-47af-a25f-45c811abf797.mp4


# Building
__this is still in deveploment, use it at your own risk!__

Currently the linux tarball used can only be built on arch system due to the `mkinitcpio` tool that is only available on arch(-based) distros
first you have to build the kernel, to do that download the kernel source of the version you want to build and extract it and configure the kernel to what you want it to be, in my experience the arch default config worked the best and will be used in this guide.

### The automated way
install the dependencies with
```bash
sudo pacman -S base-devel wget
```
then download the kernel source, preferrably from https://kernel.org, extract the tarball and apply any patches if you need any

then, if you want, generate a custom kernel configuration or get a premade one, if none is made then the default arch configuration will be used

then just run `build-linux-tarball.sh /path/to/extracted/tarball <kernel-version> [path to custom kernel configuration]`

### The manual way

```bash
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.18.2.tar.xz #we grab the kernel source of linux-5.18.2 from kernel.org
tar -xvf linux-5.18.2.tar.xz # extracting the kernel tarball
cd linux-5.18.2
wget https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/linux/trunk/config # downloading the arch config, skip this part if you have a custom kernel config
make # build the kernel
make modules # build the modules
sudo make modules_install # install the modules to the right directory
cd ../
mkdir linux-packaged
cd linux-packaged
cp ../linux-5.18.2/arch/x86 . # we copy the x86 build directory of the kernel source tree, this is the default for x86_64
cp ../linux-5.18.2/System.map . # copy the System.map file to the root of the kernel tarball
cp /lib/modules/5.18.2 . # copy the installed modules to the root of the kernel tarball
sudo cp /lib/mkinitcpio.d/linux.preset /lib/mkinitcpio.d/5.18.2.preset
```
then open the file `/lib/mkinitcpio.d/5.18.2.preset` with your text editor of choice and replace every occurance of `linux` with `5.18.2`
```
mkinitcpio -p 5.18.2 ./initramfs --kernelimage ./x86/boot/bzImage # generating the tarball
cd ..
tar -cvf linux.tar linux-packaged/
```

---
Regardles of the method used, you should end up with a tarball that has this file structure:
```
.
├── <kernel-version>
│   └── <module stuff>
├── initramfs
├── System.map
└── x86
    └── <kernel stuff>
```

If you used arch in a vm to build the kernel tarball you can use [magic-wormhole](https://github.com/magic-wormhole/magic-wormhole) to transfer the file to the actual machine you want to "flatpakboot"
Then copy the generated `linux.tar` in the same directory of the other files and run the flatpak build command:
`flatpak-builder --user --install --force-clean build-dir org.kernel.Linux.yml`

once that's finished you can just execute `flatpak run org.kernel.Linux` and it will copy everything to the right directories.

After that's done you'll just have to modify your bootloader to recognize the new kernel and initramfs

# why
Honestly, no idea, I was very bored and had nothing better to do.
