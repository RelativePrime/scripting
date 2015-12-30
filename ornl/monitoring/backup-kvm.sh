#!/bin/bash

# Create an LVM Snapshot of a KVM hypervisor and rsync off VMs
# 

logfile=/var/log/vm.rsync.log
echo "" >> $logfile
echo "* * * * NEW BACKUP * * * " >> $logfile
echo "KVM VM backup log created" >> $logfile 
date >> $logfile
echo "" >> logfile

/bin/umount /vg_backup

# Determine space LV is using
lvsize=$(df -h / | tail -n 1 | awk {'print $2'})

# Delete last snapshot
# If you have enough space, create the new snapshot first.
echo "Deleting previous snaphot" | tee -a  $logfile
/sbin/lvremove -f /dev/vg_alicehyper/root-vg_alicehyper-backup 2>&1 | tee -a  $logfile

# Create new snapshot
# Should do a check to ensure VG contains enough free space for $lvsize
echo "Snapshotting root fs" | tee -a  $logfile
/sbin/lvcreate --size=$lvsize --snapshot --name=root-vg_alicehyper-backup /dev/vg_alicehyper/LogVol00 2>&1 | tee -a  $logfile

# Mount the snapshot and rsync VMs from it
/bin/mount -o ro /dev/mapper/vg_alicehyper-root--vg_alicehyper--backup /vg_backup/

echo "Performing rsyncs. Data logged to $logfile"

/usr/bin/rsync -e "ssh -c arcfour" -avzpW /vg_backup/var/lib/libvirt root@destination:/data/alice-hyper-backups 2>&1 | tee -a  $logfile
/usr/bin/rsync -e "ssh -c arcfour" -avzpW /vg_backup/etc/libvirt/qemu root@destination:/data/alice-hyper-backups 2>&1 | tee -a  $logfile

/bin/umount /vg_backup

echo "Backup complete." | tee -a  $logfile
date >> $logfile
echo "" >> logfile

# Email a summary of the destination directory file sizes
# The tr -d is so that the output is displayed in the email body, rather than being attached.
ssh root@destination -t "ls -lhatr /data/alice-hyper-backups/libvirt/images" | tr -d \\r | mailx -s "ALICE VM Backup Summary" me@somewhere.com

