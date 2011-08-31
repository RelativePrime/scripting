#!/bin/bash

############################################################
#		Sago Networks
#	OCS Inventory Agent Install Script	
#	
#	This will detect which OS is running and then
#	install the appropriate version of the OCS Agent
#	and set up the environment. Note that we do not 
#	necessarily just install the repo version of the
#	agent as there are differences between the versions
#	available in various distro's repos, etc. 
#
#	You can also build a stand alone binary agent with
#	perl dependencies compiled in. This is what is used
#	for CentOS 4. The script to create a stand alone binary
#	is in the /tools directory of some RPM versions - 
#	especially those obtained directly from the developer's
#	personal repo. Other version may lack these tools.
#	See Sago wiki for more info:
#
#	http://wiki.sagonet.com/wiki/OCSNG_Inventory_Management
#	http://timelordz.com/wiki/OCSNG_Inventory_Management
#
# 	Pete Eby
###########################################################

# Set the tag to be sent to the OCS Server. Once set this can only be changed
# manually in the database, the OCSAgent can NOT change it, so ensure it is correct.

export OCSTag=PXE-Install
#export OCSTag=DC-Audit


# First let's see if OCS is already installed:

if [ -a /usr/sbin/ocsinventory-agent ] || [ -a /bin/ocsinventory-agent.bin ] || [ -a /usr/local/bin/ocsinventory-agent ]
        then
        echo -e "\033[31m Is OCS already installed? \033[0m" 
        echo "OCS Agent appears to already be installed in /usr/sbin/ocsinventory-agent"
        echo "Please verify by try to run ocsinventory-agent and checking the log"
        echo "(if it exists) at /var/log/ocsinventory-agent/ for the result of running it."
        exit 1
        fi

# Cpanel overwrites /etc/issue with a custom one, so installing OCS after Cpanel
# requires getting the OS elsewhere, like from redhat-release. We may find other 
# OS / Control panel combos do the same, in which case we might need to change 
# this to a case statment and set OSVersion in an appropriate way for each situation.
#
# IF AUTO DETECTION DOES NOT WORK and you need to set the OS version manually, 
# simply uncomment the following line and set it to match the options below. 
# Then comment out the auto detection if block that follows.

#export OSVersion="CentOS release 4" #or whatever it is in /etc/issue or /etc/redhat-release, etc.


# Autodetect OS version
if [ -a /etc/redhat-release ]
	then
export OSVersion=`head -1 /etc/redhat-release | cut -f 1 -d "."`
	else
export OSVersion=`head -1 /etc/issue | cut -f 1 -d "."`

fi

############
# Next are the sections which match the OS detected to the appropriate
# steps needed to install the OCS Agent on that platform
############


if [ "$OSVersion" == "CentOS release 5" ] || [ "$OSVersion" == "CentOS release 5 (Final)" ]

	then
########
# CentOS 5.x
########

# We send some messages to both console and /dev/tty1 so they are visible when run from
# the PXE install.
echo -e "Installing OCS. . . " > /dev/tty1
echo -e "Installing OCS. . . "
		
		#If CPanel is already installed it blocks any perl* rpms from being installed, so diasble if present
		sed -i s/perl/sago/ /etc/yum.conf 				

                cd /root
		#Install the EPEL repo which contains all the stuff needed for OCS in one place
		rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm

		#yum -y install ocsinventory-agent
		#Do not install the repo version of OCS itself, install the newer RPM version instead
		
		wget http://ks.sagonet.com/tools/ocs/ocsinventory-agent-1.0.1-2.el4.remi.noarch.rpm
		yum -y install yum-utils
                yum -y --nogpgcheck localinstall ocsinventory-agent-1.0.1-2.el4.remi.noarch.rpm

 		echo -e "OCSMODE[0]=cron" >> /etc/sysconfig/ocsinventory-agent
 		echo -e "OCSSERVER[0]=ocs.sagonet.com" >> /etc/sysconfig/ocsinventory-agent
 		echo -e "OCSTAG[0]=$OCSTag" >> /etc/sysconfig/ocsinventory-agent
		
		#Optional: Leave EPEL repo installed, but turn it off in case we need it later
		#sed -i s/enabled=1/enabled=0/ /etc/yum.repos.d/epel.repo
		#rm -y epel-release-5-4.noarch.rpm
		
		#Remove EPEL altogher
		rpm -e epel-release-5-4

                mv /etc/cron.hourly/ocsinventory-agent /etc/cron.daily/	

		#Restore Cpanel blocking  perl* rpms from being installed
                sed -i s/sago/perl/ /etc/yum.conf
		
		#Run it now
		/etc/cron.daily/ocsinventory-agent
		
		exit 0
fi

########
# CentOS 4.x
########

if [ "$OSVersion" == "CentOS release 4" ]
        then

echo -e "Installing OCS. . . " > /dev/tty1
echo -e "Installing OCS. . . "
                
		# For CentOS 4.x we use a compiled version of the agent, rather than the RPM. This is due
		# to the RPM version not working after a Cpanel installs, which produces errors in Logger.pm, etc.
		# (This is due to how Cpanel changes the perl binaries and environement.) 
		# Our Sago compiled binary includes all needed perl dependencies and so should not be affected 
		# by Cpanel perl changes, etc. 
		
		cd /bin
                wget http://ks.sagonet.com/tools/ocs/ocsinventory-agent.bin
		chmod +x ocsinventory-agent.bin
		
		# Create the cron job

		# On Cpanel /tmp is noexec which will prevent the binary from running
		# Also, tmp is sometime bind mounted to /var/tmp so we have to ensure 
		# we remount the actual partition, and not just /tmp, so let's find that first

		tmp_partition=$(blkid | grep tmp | cut -d : -f 1)

		touch /etc/cron.daily/ocsagent.sh
		echo -e "mount -o remount,rw $tmp_partition /tmp" >> /etc/cron.daily/ocsagent.sh
		echo -e "/bin/ocsinventory-agent.bin 1 -t $OCSTag -s ocs.sagonet.com" >> /etc/cron.daily/ocsagent.sh
		echo -e "mount -o remount,noexec,nosuid $tmp_partition /tmp" >> /etc/cron.daily/ocsagent.sh

		chmod 755 /etc/cron.daily/ocsagent.sh
		
		#Run it now
		mount -o remount,rw $tmp_partition /tmp
		/etc/cron.daily/ocsagent.sh
		mount -o remount,noexec,nosuid $tmp_partition /tmp

		exit 0
fi		


########
# CentOS 3.x
########

if [ "$OSVersion" == "CentOS release 3" ]
        then

echo -e "Installing OCS. . . " > /dev/tty1
echo -e "Installing OCS. . . "
                
                # For CentOS 3.x we use the compiled version of the agent, rather than the RPM. 
                # The compiled binary includes all needed perl dependencies and so should not be affected 
                # by Cpanel perl changes, and God know what perl version a CentOS 3.x customer is using etc. 
               
		# NOTE: It does not appear to need the same steps for finding the block device associated
		# with /tmp and remounting it as we do for CentOS 4 above, but we might find we 
		# need to include the use of $tmp_partition here too - we will see. 
		 
                cd /bin
                wget http://ks.sagonet.com/tools/ocs/ocsinventory-agent.bin
                chmod +x ocsinventory-agent.bin

		# Create the cron job
                # On Cpanel /tmp is noexec which will prevent the binary from running
                touch /etc/cron.daily/ocsagent.sh
                echo -e "mount -o remount,rw /tmp" >> /etc/cron.daily/ocsagent.sh
                echo -e "/bin/ocsinventory-agent.bin 1 -t $OCSTag -s ocs.sagonet.com" >> /etc/cron.daily/ocsagent.sh
                echo -e "mount -o remount,noexec /tmp" >> /etc/cron.daily/ocsagent.sh

                chmod 755 /etc/cron.daily/ocsagent.sh

                #Run it now
                mount -o remount,rw /tmp
                /etc/cron.daily/ocsagent.sh
                mount -o remount,noexec /tmp

                exit 0
fi



#######
# Fedora (Any Version)
######

# Need to parse this differently as Fedora does not use periods for a delimeter like CentOS
# OCS is in the normal Fedora Repos though, so that makes it easy.

# NOTE: Some older versions of Fedora in the wild might have Cpanel, which might pose a problem
# with /tmp being noexec or with needing to use the precompiled agent like with CentOS 4.
# But this way should work 99% of the time. 

export Fedora=`echo $OSVersion | cut -f 1 -d " "`

if [[ "$Fedora" == Fedora* ]]
then
		yum -y install ocsinventory-agent
                echo -e "OCSMODE[0]=cron" >> /etc/sysconfig/ocsinventory-agent
                echo -e "OCSSERVER[0]=ocs.sagonet.com" >> /etc/sysconfig/ocsinventory-agent
                echo -e "OCSTAG[0]=$OCSTag" >> /etc/sysconfig/ocsinventory-agent

		mv /etc/cron.hourly/ocsinventory-agent /etc/cron.daily/

		/etc/cron.daily/ocsinventory-agent

exit 0

fi

########
# Debain
########

#This works on Debian 4 and 5
		
if [[ "$OSVersion" == Debian\ GNU/Linux* ]]
        then

	#This should be in main repo
	apt-get install ocsinventory-agent
	echo -e "server=ocs.sagonet.com" >> /etc/ocsinventory/ocsinventory-agent.cfg
	echo -e "tag=$OCSTag" >> /etc/ocsinventory/ocsinventory-agent.cfg
	echo -e "logfile=/var/log/ocsinventory-client/ocsinventory-agent.log" >> /etc/ocsinventory/ocsinventory-agent.cfg
	touch /var/log/ocsinventory-client/ocsinventory-agent.log
	/etc/cron.daily/ocsinventory-agent
	

exit 0 

fi

########
# Ubuntu
########


if [[ "$OSVersion" == "Ubuntu*" ]]
        then

echo -e "\033[35m Drat! OS detected as $OSVersion but it does have an OCS Agent install script. \033[0m" 
echo -e "\033[35m Maybe you could write one? \033[0m" 

exit 1

fi

########
# Suse
########


if [[ "$OSVersion" == "Welcome to Suse*" ]]
        then

echo -e "\033[35m Drat! OS detected as $OSVersion but it does have an OCS Agent install script. \033[0m" 
echo -e "\033[35m Maybe you could write one? \033[0m" 

exit 1

fi

########
# FreeBSD
########


if [[ "$OSVersion" == "FreeBSD*" ]]
        then

echo -e "\033[35m Drat! OS detected as $OSVersion but it does have an OCS Agent install script. \033[0m" 
echo -e "\033[35m Maybe you could write one? FreeBSD likely needs a stand alone binary compiled. \033[0m" 

exit 1

fi

#############
# OS detection or match problem fall through
############

echo -e "\033[31m It didn't work \033[0m" 
echo -e ""
echo -e "\033[35m I detected OS as  $OSVersion but there is either no matching sript for this  \033[0m" 
echo -e "\033[35m or it was misdetected. If you know OCS should install on this system then  \033[0m" 
echo -e "\033[35m You may be able to modify the script to skip checking for the OS in the very  \033[0m" 
echo -e "\033[35m beginning, and just set the variable like OSVersion=OS section to use \033[0m" 



