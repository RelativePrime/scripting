#!/bin/bash
# This script downloads a bundle of RPMs for setting up Luster 
# on a RHEL / CentOS 5 box. 


cd /root
wget http://ks.sagonet.com/tools/lustre/lustre_rpms.zip
unip lustre_rpms.zip

# ecryptfs < 44 is not compatible with lustre. We are not using it anyway currently,
# so just remove it. 
# Then we install all the Luster RPMs in the needed order. 
rpm -e ecryptfs-utils
rpm -Uvh kernel-lustre-2.6.18-128.1.14.el5_lustre.1.8.1.i686.rpm 
rpm -Uvh lustre-modules-1.8.1-2.6.18_128.1.14.el5_lustre.1.8.1.i686.rpm 
rpm -Uvh lustre-ldiskfs-3.0.9-2.6.18_128.1.14.el5_lustre.1.8.1.i686.rpm 
rpm -Uvh lustre-1.8.1-2.6.18_128.1.14.el5_lustre.1.8.1.i686.rpm 
rpm -Uvh e2fsprogs-1.41.6.sun1-0redhat.rhel5.i386.rpm

echo
echo "(The RPM warning messages about '/lib/modules/~.ko needs unknown symbol' can"
echo "be ignored - the kernel symbols are missing as the Luster kernel is not running yet.)"
echo 
echo "Luster RPMs should now be installed and /boot/grub/grub.conf should"
echo "be set to boot the new Lustre kernel. Please reboot into it." 

