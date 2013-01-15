#!/bin/bash

# Rsyncs data from mounted Mercury SMB shares (/smb/blah) to /data which is then accessed locally and 
# NFS exported to mercury-ops2. /usr/local/bin/windows.mounts.sh mounts the SMBs.

# People love to run things with sudo don't they?
if [ $(whoami) != "mercury" ]
then
echo "You must run this as the user mercury to maintain correct permissions. Sudo is not needed."
exit 5
fi


# Check for SMB and iSCSI mounts and fail if not present
if [ ! -d "/smb/mercury3-D/Mercury_instances" ]; then
    echo "The source directory Mercury_instances on SMB mount /smb/mercury3-D appears to be missing."
    echo "Please see /usr/local/bin/windows-mount-monitor.sh"
    echo "and /usr/local/bin/windows-mounts.sh" 
    exit 1
fi

if [ ! -d "/data/Mercury_instances" ]; then
    echo "The destination directory Mercury_instances on iSCSI / LVM  mount /data appears to be missing."
    echo "Check the iSCSI initiator and ensure the LVM vg is active." 
    exit 2
fi


# What user should these files be owned as - tomcat?

echo "Performing rsyncs. Data logged to mercury.rsync.log.txt"


logfile=/data/Mercury_instances/mercury.rsync.log.txt
echo "New log created" > $logfile 
date >> $logfile
echo "" >> logfile

#copy all instances
#rsync -rva --delete /smb/mercury3-D/Mercury_instances/             /data/Mercury_instances/           2>&1 | tee  $logfile
#rsync -rva --delete /smb/mercury1-D/Mercury_instances/             /data/Mercury_instances/           2>&1 | tee  $logfile

#ber
rsync -rva --delete /smb/mercury3-D/Mercury_instances/ber/             /data/Mercury_instances/ber           2>&1 | tee  $logfile

#ornldaac

rsync -rva --delete /smb/mercury3-D/Mercury_instances/ornldaac/ 		/data/Mercury_instances/ornldaac/		2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/landval/  	/data/Mercury_instances/ornldaac/landval	2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/rgd/		/data/Mercury_instances/ornldaac/rgd		2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/lpdaac/  		/data/Mercury_instances/ornldaac/lpdaac		2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/daacweb/  	/data/Mercury_instances/ornldaac/daacweb	2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/lba/  		/data/Mercury_instances/ornldaac/lba		2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/fluxnet/  	/data/Mercury_instances/ornldaac/fluxnet	2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/obfs/  		/data/Mercury_instances/ornldaac/obfs		2>&1 | tee  $logfile
#rsync -rva /smb/mercury3-D/Mercury_instances/ornldaac/lter/  		/data/Mercury_instances/ornldaac/lter		2>&1 | tee  $logfile

#USGS
rsync -rva --delete /smb/mercury1-D/Mercury_instances/usgs/             	/data/Mercury_instances/usgs/           2>&1 | tee  $logfile

#cdiac
rsync -rva --delete /smb/mercury3-D/Mercury_instances/cdiac/              /data/Mercury_instances/cdiac/           2>&1 | tee  $logfile

#OCEAN
rsync -rva --delete /smb/mercury3-D/Mercury_instances/ocean/              /data/Mercury_instances/ocean/           2>&1 | tee  $logfile

#mastdc
rsync -rva --delete /smb/mercury3-D/Mercury_instances/mastdc/              /data/Mercury_instances/mastdc/           2>&1 | tee  $logfile

#edora
rsync -rva --delete /smb/mercury3-D/Mercury_instances/edora/              /data/Mercury_instances/edora/           2>&1 | tee  $logfile

#iai
rsync -rva --delete /smb/mercury3-D/Mercury_instances/iai/              /data/Mercury_instances/iai/           2>&1 | tee  $logfile

#lba
rsync -rva --delete /smb/mercury3-D/Mercury_instances/lba/              /data/Mercury_instances/lba/           2>&1 | tee  $logfile

#lpdaac
rsync -rva --delete /smb/mercury3-D/Mercury_instances/lpdaac/              /data/Mercury_instances/lpdaac/           2>&1 | tee  $logfile

#soilspcape
rsync -rva --delete /smb/mercury3-D/Mercury_instances/soilscape/              /data/Mercury_instances/soilscape/           2>&1 | tee  $logfile

#daddi
rsync -rva --delete /smb/mercury3-D/Mercury_instances/daddi/              /data/Mercury_instances/daddi/           2>&1 | tee  $logfile

#lter
rsync -rva --delete /smb/mercury3-D/Mercury_instances/lter/              /data/Mercury_instances/lter/           2>&1 | tee  $logfile
rsync -rva --delete /smb/mercury3-D/Mercury_instances/ilter/              /data/Mercury_instances/ilter/           2>&1 | tee  $logfile


#ngee
rsync -rva --delete /smb/mercury3-D/Mercury_instances/ngee/              /data/Mercury_instances/ngee/           2>&1 | tee  $logfile

#narsto
rsync -rva --delete /smb/mercury3-D/Mercury_instances/narsto/              /data/Mercury_instances/narsto/           2>&1 | tee  $logfile

#wind
rsync -rva --delete /smb/mercury3-D/Mercury_instances/wind/              /data/Mercury_instances/wind/           2>&1 | tee  $logfile


#usanpn
rsync -rva --delete /smb/mercury1-D/Mercury_instances/usanpn/              /data/Mercury_instances/usanpn/           2>&1 | tee  $logfile

#datanet
#rsync -rva --delete /smb/mercury1-D/Mercury_instances/datanet/              /data/Mercury_instances/datanet/           2>&1 | tee  $logfile

#i3n
rsync -rva --delete /smb/mercury1-D/Mercury_instances/i3n/              /data/Mercury_instances/i3n/           2>&1 | tee  $logfile




