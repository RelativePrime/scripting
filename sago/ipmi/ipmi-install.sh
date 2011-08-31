#!/bin/bash
#
# Installs IMPI base RPMs for IMPI to function. 
# This allows console execution of IMPI commands as well
# as the ability to change IPMI settings in the BMC on supported 
# servers without needed to reboot to do so.
#
# This script is not too intelligent, does not verify what OS version,
# does not see what IPMI components are installed first, etc. but you
# can use it as a guide for what is needed at a minimum.
#
# Pete Eby
# Sago Networks
#


# First let's get our stuff . . .

/bin/mkdir /root/ipmitools
cd /root/ipmitools
 
wget http://ks.sagonet.com/ipmi/OpenIPMI-2.0.6-6.el5.i386.rpm
wget http://ks.sagonet.com/ipmi/OpenIPMI-libs-2.0.6-6.el5.i386.rpm
wget http://ks.sagonet.com/ipmi/OpenIPMI-tools-2.0.6-6.el5.i386.rpm
wget http://ks.sagonet.com/ipmi/net-snmp-libs-5.3.1-24.el5_2.1.i386.rpm

/bin/rpm -Uvh net-snmp-libs-5.3.1-24.el5_2.1.i386.rpm
/bin/rpm -Uvh OpenIPMI-libs*
/bin/rpm -Uvh OpenIPMI-tools*
/bin/rpm -Uvh OpenIPMI-2*

# Now let's install IMPIutil 
/bin/rpm -Uvh http://ks.sagonet.com/ipmi/ipmiutil-2.3.9-rhel5.i386.rpm 

/sbin/modprobe ipmi_devintf
/sbin/modprobe ipmi_si

echo
echo
echo -e '\033[31m			OpenIPMI Installed\033[0m'
echo
echo 'You might want run lsmod and verify that ipmi_si and ipmi_devintf are loaded.' 
echo 'This will not work without them.'
echo
echo 'You can run impitool and directly execute IMPI commands, such as:'
echo -e '\033[36m impitool -I open power status\033[0m'
echo -e '\033[36m impitool -I open sel list\033[0m'
echo 'To verify IPMI is working correctly.'
echo
echo 'To email the full server event log to yourself:'
echo -e '\033[36m ipmitool -I open sel list | mail -s "ServerIPAddress" you@sagonet.com\033[0m'
echo
echo -e 'On Dells: to reset the evil orange light, \033[31mafter you have checked the log\033[0m'
echo 'with sel list you can run sel clear:'
echo -e '\033[36m ipmitool -I open sel clear\033[0m'
echo
echo 'Many other IMPI commands are available - see the Wiki. You can also run' 
echo 'ipmitool in interactive console mode and use ? for options, etc.'
echo -e '\033[36m ipmitool -I open shell'
echo 
echo -e '\033[32mhttp://wiki.sagonet.com/wiki/IPMI_Configuration_and_Monitoring\033[0m'
echo
echo



