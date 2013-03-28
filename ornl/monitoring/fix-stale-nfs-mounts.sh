#!/bin/sh

# Changed this over from monitoring NFS mounts to remounting iSCSI daymet_data logical volumes

#df |grep :|grep " - " >/tmp/fsnm.$$
#df |grep : >/tmp/fsnm.$$
# /proc tends to be more uniform, whereas df output varies slightly between distros.
#cat /proc/mounts | grep nfs | awk {'print $2'} > /tmp/fsnm.$$
cat /proc/mounts | grep daymet_data | awk {'print $2'} > /tmp/fsnm.$$

# Uncomment to simulate a failure by adding nonexistent mount
#echo 'nowhere:/nonexistent' >> /tmp/fsnm.$$
# /proc version test
#echo '/nonexistent' >> /tmp/fsnm.$$

if ! [ -s /tmp/fsnm.$$ ]
then
  rm /tmp/fsnm.$$
  echo "Empty mount list. This is not designed to fix mounts which are not present, or mount them and check for errors, etc."	
  exit
fi

FAILED=false
  
while read LINE
do
  #MNT=$(echo $LINE | cut -d ":" -f 2 )
  MNT=$(echo $LINE)
#  echo "Remounting: $MNT"
  # Odd: If you do a mount -o remount $MNT here, rather than 
  # the conditional below, it fails. Weird. 
  #mount $MNT

  if (mount -o remount $MNT) 
  then
#    echo $MNT fixed
    :
  else
      echo "Couldn't mount $MNT" >> /tmp/fsnm-err.$$
      FAILED=true
  fi
done < "/tmp/fsnm.$$"

# Clean up and exit

if ! $FAILED
then
rm /tmp/fsnm.$$
#echo "No stale mounts detected."
exit
fi

# Create log file to email and exit

if $FAILED 
then
time=`date +%F:%H:%M`
#echo " " >> /tmp/fsnm.$$
#echo " " >> /tmp/fsnm-err.$$
#cat /tmp/fsnm.$$ >> /tmp/fsnm-err.$$
echo $time >> /tmp/fsnm-err.$$
cat /tmp/fsnm-err.$$ | mail -s "NFS Mount: $HOSTNAME" -t you@yourcooljob.com 
#cat /tmp/fsnm-err.$$ | mail -t you@yourcooljob.com you@gmail.com -s "NFS Mount: $HOSTNAME" 
fi


