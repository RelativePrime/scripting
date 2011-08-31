#!/bin/bash
#Sago Make recovery linux script
#Takes 2 arguments, the ip then the gateway
# Written by K.A. - Sago

cd /root
wget ks.sagonet.com/recovery/rootfs-original.cgz
mkdir recovery
cd recovery
gzip -dc ../rootfs-original.cgz | cpio -iumd

#Setup Networking.
echo "ifconfig eth0 $1 netmask 255.255.255.0" >> etc/rc.d/rc.local
echo "route add default gw $2" >> etc/rc.d/rc.local
echo "openvt -v -c 12 /bin/bash" >> etc/rc.d/rc.local
echo "openvt -v -c 8 /bin/bash" >> etc/rc.d/rc.local
#Copy the root Password.
cp /etc/shadow etc/shadow
#Pack it up!
find . | bin/cpio  -o -H newc | gzip -9 > /boot/recovery-initrd.cgz
wget -O /boot/recovery-kernel ks.sagonet.com/recovery/recovery-kernel
cd ..
rm -rf recovery
rm /root/rootfs-original.cgz
chmod 700 /boot/recovery-initrd.cgz
chmod 700 /boot/recovery-kernel

wget -O /boot/bootcontrol.pl ks.sagonet.com/recovery/bootcontrol.pl
chmod +x /boot/bootcontrol.pl
wget -O /boot/setup-sago-recovery.sh ks.sagonet.com/recovery/setup-sago-recovery.sh
chmod +x /boot/setup-sago-recovery.sh

#Now we need to add a grub line
grep "/boot" /etc/fstab > /dev/null
if [ $? -eq 0 ]; then
#We have a boot partition people!
echo "


title         Sago Networks Recovery Environment 
root            (hd0,0)
kernel          /recovery-kernel nokeymap root=/dev/ram0 rw
initrd		/recovery-initrd.cgz" >> /boot/grub/menu.lst
else

echo "


title         Sago Networks Recovery Environment 
root            (hd0,0)
kernel          /boot/recovery-kernel nokeymap root=/dev/ram0 rw
initrd		/boot/recovery-initrd.cgz" >> /boot/grub/menu.lst
fi
