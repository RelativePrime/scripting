#!/bin/bash

# Script to use sshfs to mount NFS exports from various hosts onto plot1 as systems are in
# different protection zones.
# Pete Eby
# 4 Jan 2011

# Reverse tunnels from ret1, reproc1, and iop3 should have been created to this host (plot1)
# Those connetions are made using usr/local/etc/reverse-tunnels.sh (or /etc/rc3.d/S99Local for reproc1)

# We should now be able to connect to ports on localhost and use sshfs to mount file systems from these hosts
# This is currently mounting as user pae, but any user in the fuse group should be able to do this. 
# (SSH keys are already in place for user pae as well on all hosts.) 

# First, do a check here to ensure that ports 1100 - 1103 (for sshfs) are listening. 
#netstat -natlp |  egrep '(127.0.0.1:1100|127.0.0.1:1101|127.0.0.1:1102|127.0.0.1:1103)' | grep sshd | grep LISTEN 

# 	HOST PORT MAPPING 	#
# Host		Localport
# plot1 	Open Reasearch		
# ret1 		(ARM_CSAT)		1100
# reproc1 	(ARM_CSAT)		1101
# iop3		(ARM_CSAT)		1103
# dm1 		(ARM_CSAT)		1103
# ui1		Open Research		

TUNNELERROR=0

echo "Checking to ensure tunnels have been created and ports on localhost are listening . . . "
echo 

# We could be fancy and loop through these, but this works.
STATUS=`netstat -natlp |  egrep '(127.0.0.1:1100)' | grep sshd | grep LISTEN | wc | awk '{print $1}'`
if [ $STATUS -ne 1 ]
        then echo "There does not appear to be a tunnel established between ret1 and plot1."
        TUNNELERROR=1
fi

STATUS=`netstat -natlp |  egrep '(127.0.0.1:1101)' | grep sshd | grep LISTEN | wc | awk '{print $1}'`
if [ $STATUS -ne 1 ]
        then echo "There does not appear to be a tunnel established between reproc1 and plot1."
        TUNNELERROR=1
fi

STATUS=`netstat -natlp |  egrep '(127.0.0.1:1105)' | grep sshd | grep LISTEN | wc | awk '{print $1}'`
if [ $STATUS -ne 1 ]
        then echo "There does not appear to be a tunnel established between dm1 and plot1."
        TUNNELERROR=1
fi
# STATUS=`netstat -natlp |  egrep '(127.0.0.1:1102)' | grep sshd | grep LISTEN | wc | awk '{print $1}'`

# if [ $STATUS -ne 1 ]
#       then echo "There does not appear to be a tunnel established between plot and plot1."
#        TUNNELERROR=1
# fi

#STATUS=`netstat -natlp |  egrep '(127.0.0.1:1103)' | grep sshd | grep LISTEN | wc | awk '{print $1}'`

#if [ $STATUS -ne 1 ]
#        then echo "There does not appear to be a tunnel established between iop3 and plot1."
#        TUNNELERROR=1
#fi

if [ $TUNNELERROR -eq 1 ]
        then echo -e '\033[31m Fail \033[0m Not all ssh tunnels are listening. '
                echo "To correct the above, log into the host which originates the SSH tunnel and investigate."
                echo "The /usr/local/etc/reverse-tunnel.sh script should run on that host to establish the tunnel."
                echo " "
fi

if [ $TUNNELERROR -eq 0 ]
        then echo -e '\033[32m Success! \033[0m There are three ssh tunnels listening on ports 1100 - 1105. Mounting can continue. '
	echo  
fi

# Mount the sshfs volumes:

#*************
# Mount ret1
#**************

#echo "Mounting /var/ftp/armguest from ret1 . . . "
#echo "Actually no, we are not - IDL chokes on sending output to ret1 via SSHfS, so this will be done via rsync in arm's crontab on ret1."
# Nope, that issue with IDL was fixed - modified anders.pl to user IDL 8 instead of 5.6 which worked, so we are using the SSHFS mount again.
# Update: 7 Nov 2011 - sshfs was recently updated. We now must supply a mapped uid and gid or all users will get permission denied 
#sshfs -o nonempty -o UserKnownHostsFile=/root/.ssh/known_hosts_ret1 -o IdentityFile=/home/pae/.ssh/id_rsa -p 1100 -o rw,allow_other,default_permissions -o gid=997,uid=102 pae@localhost:/var/ftp/armguest /var/ftp/armguest_user

# We have to do this as user arm so that arm really has rw access for rsync to work 
# Update 17-Mar-2010: However, the anders.pl script is unable to write for the sshfs directory when IDL is called. 
# Bit of a mystery. For now we are going to try to run the job on ret1 and just rsync the results between ret1 and plot1.
# sshfs -o UserKnownHostsFile=/home/arm/.ssh/known_hosts -o IdentityFile=/home/arm/.ssh/id_rsa -p 1100 -o rw,allow_other arm@localhost:/var/ftp/armguest /var/ftp/armguest_user
#echo

# Dec 17, 2012
# The recent ability to NFS mount from ret1 -> plot1 has disappeared, so we are re-implementing the sshfs mount
echo "Mounting ret1:/var/ftp/armguest to /var/ftp/armguest_user . . . "
sshfs -o nonempty -o UserKnownHostsFile=/root/.ssh/known_hosts_ret1 -o IdentityFile=/home/pae/.ssh/id_rsa -p 1100 -o rw,allow_other,default_permissions -o gid=997,uid=102 pae@localhost:/var/ftp/armguest /var/ftp/armguest_user
echo

#*****************
# Reproc1 can be NFS mounted now
#*****************
echo "Mounting /file1/data/datastream from reproc1"
sshfs -o UserKnownHostsFile=/root/.ssh/known_hosts_reproc1 -o IdentityFile=/home/pae/.ssh/id_rsa -p 1101 -o ro pae@localhost:/files1/data/datastream /var/ftp/reproc1_plots
echo

#*****************
# Removing Plot as it is decomissioned
#*****************
# echo "Mounting /var/ftp/armguest from plot  . . ."
# sshfs -o UserKnownHostsFile=/home/arm/.ssh/known_hosts_plot -o IdentityFile=/home/arm/.ssh/id_rsa -p 1102 -o rw,allow_other,default_permissions arm@localhost:/var/ftp/armguest /var/ftp/armguest
# echo

#**************
# Plot1 and UI1 are now both in open research and so NFS is used rather than sshf.
#*************** 
# echo "Mounting /var/ftp/armguest from ui1  . . ."
# sshfs -o UserKnownHostsFile=/home/arm/.ssh/known_hosts_plot -o IdentityFile=/home/arm/.ssh/id_rsa -p 1102 -o rw,allow_other,default_permissions arm@localhost:/work/anders /var/www/anders
#echo

#echo "Mounting /var/ftp/arm-iop/0showcase-data/cmbe from iop3 . . . "
#sshfs -o UserKnownHostsFile=/root/.ssh/known_hosts_iop3 -o IdentityFile=/home/pae/.ssh/id_rsa  -p 1103 -o ro pae@localhost:/var/ftp/arm-iop/0showcase-data/cmbe /workarea
#echo

#*********************
# Adding mounts for DM1 as the NFS capability has magically disappeared
# dm1.ornl.gov:/data      /datadm1  
#*********************
echo "Mounting ret1:/data to /datadm1  . . ."
sshfs -o nonempty -o UserKnownHostsFile=/root/.ssh/known_hosts_dm1 -o IdentityFile=/home/pae/.ssh/id_rsa -p 1105 -o rw,allow_other,default_permissions -o gid=997,uid=102 pae@localhost:/data      /datadm1 
echo

echo
echo -e '\033[32m Complete \033[0m'
echo "SSHfs mounts should now be working. If not, ensure the tunnel is up. If the tunnel is not up, investigate from the other host side of things - start with /usr/local/etc/reverse-tunnels.sh"

# After mounting, plot1 should show:

#sshfs#pae@localhost:/data on /datadm1 type fuse (rw,nosuid,nodev,allow_other,default_permissions)
#sshfs#pae@localhost:/files1/data/datastream on /var/ftp/reproc1_plots type fuse (ro,nosuid,nodev,max_read=65536)
#sshfs#arm@localhost:/var/ftp/armguest on /var/ftp/armguest_user type fuse (rw,nosuid,nodev,max_read=65536,allow_other,default_permissions

# Not sure if this one is still needed
#sshfs#pae@localhost:/var/ftp/arm-iop/0showcase-data/cmbe on /workarea type fuse (ro,nosuid,nodev,max_read=65536)
