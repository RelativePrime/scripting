#!/bin/bash

# Called from crontab every 6 hours. Checks to ensure that 3 sshfs mounts and 3 reverse ssh tunnels exist.

# Removed monitor on port 1102, which was for plot - now decomissioned.

#MOUNTS=`mount | egrep '(/reproc1_plots)' | wc -l`
#TUNNELS=`netstat -natlp |  egrep '(127.0.0.1:1100|127.0.0.1:1101|127.0.0.1:1103)' | grep sshd | grep LISTEN | wc -l`

MOUNTS=`mount | egrep '(sshfs)' | wc -l`
TUNNELS=`netstat -natlp |  egrep '(127.0.0.1:1100|127.0.0.1:1101|127.0.0.1:1105)' | grep sshd | grep LISTEN | wc -l`

if /bin/false
then
echo "Looking for the following tunnels:"
echo 'netstat -natlp |  egrep '"'"'(127.0.0.1:1100|127.0.0.1:1101|127.0.0.1:1105)'"'"' | grep sshd | grep LISTEN | wc -l'
echo "Where: 1100=ret1, 1101=reproc1, 1105=dm1 "
echo
echo "If any of the above tunnels are not found, please log into the respective host and run"
echo "/usr/local/etc/reverse-tunnels-mount.sh" 
echo
fi

#Debug
#echo "SSHFS mounted file systems = " $MOUNTS
#echo "Reverse SSH tunnels listening = " $TUNNELS
#MOUNTS=0 
#TUNNELS=0

RECIPIENTS="ebypi@ornl.gov root 7273650046@vtext.com"
#CCRECEPIENT=root@plot1,7273650046@vtext.com

if [ $MOUNTS -ne 3 ]
 then `echo -e "One of the SSHfs mount points on plot1 appears to be unmounted. Please login and check that all the reverse ssh tunnels are listening and that mount shows three sshfs directories mounted.\n\nSee /etc/reverse-tunnels-mount.sh for more information.\n\n (Tunnels Listening = $TUNNELS, SSHfs mounts = $MOUNTS)" | mail -s "PLOT1: Problem with SSHfs Mounts" $RECIPIENTS`
fi


if [ $MOUNTS -ne 3 ]
 then echo -e "One of the SSHfs mount points on plot1 appears to be unmounted. Please login and check that all the reverse ssh tunnels are listening and that mount shows three sshfs directories mounted.\n\nSee /etc/reverse-tunnels-mount.sh for more information.\n\n (Tunnels Listening = $TUNNELS, SSHfs mounts = $MOUNTS)"
fi
