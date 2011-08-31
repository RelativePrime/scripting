<?php
	
	$ks_anaconda .= ("
		%post
		chvt 3
		wget -O /root/make-recovery-linux.sh ks.sagonet.com/recovery/make-recovery-linux.sh
		bash /root/make-recovery-linux.sh $ks_ip $ks_gateway > /dev/tty8 2>&1 &	
		echo -e 'Configuring Hostname...' > /dev/tty1
		echo -e 'NETWORKING=yes\nHOSTNAME=$ks_hostname.tpa.sagonet.com' > /etc/sysconfig/network
		echo -e 'Configuring Nameservers...' > /dev/tty1
		echo -e 'nameserver 66.118.170.2\nnameserver 66.118.170.3' > /etc/resolv.conf
		echo -e 'Installing OS Updates...' > /dev/tty1
		wget -O /etc/yum.repos.d/CentOS-Base.repo 'http://ks.sagonet.com/yum/CentOS-Base.repo.5'
		// yum -y update
		/sbin/chkconfig sendmail off
	");
	
	// Sago Support Daemon Installation
	$ks_anaconda .= ('
		cd /etc/rc.d/init.d/
		wget http://ks.sagonet.com/supportd
		/bin/chown root.root /etc/rc.d/init.d/supportd
		/bin/chmod 755 /etc/rc.d/init.d/supportd
		/sbin/chkconfig --level 0126 supportd off
		/sbin/chkconfig --level 345 supportd on	
	');

	// Install OCS
	// This install the newer 1.0.1 client. However it does not support a fully scripted install
	// When run, you have to set up the agent the first time, etc. 
//	if($ks_ocs == 'ocs'){
//		$ks_anaconda .= ('
//		echo -e "Installing OCS. . . Go to vt3 to setup the OCS agent" > /dev/tty1
//		yum -y install perl-XML-Simple perl-Compress-Zlib perl-Net-IP perl-LWP  perl-Digest-MD5 perl-Net-SSLeay
//		cd /root/
//		wget ks.sagonet.com/tools/ocs/OCSNG_UNIX_AGENT-1.02.tar.gz
//		tar zxvf OCSNG_UNIX_AGENT-1.02.tar.gz 
//		rm -f OCSNG_UNIX_AGENT-1.02.tar.gz
//		cd Ocsinventory-Agent-1.0.1/
//		perl Makefile.PL 
//		make
//		make install
//	        echo "/usr/bin/ocsinventory-agent 1 -t Testing-PXE -s ocs.sagonet.com" > /etc/cron.daily/ocsagent.sh
//		chmod +x /etc/cron.daily/ocsagent.sh
//		');
//		}	


	 // Install OCS
	 // Do this before the Cpanel install scripts is run as Cpanel blocks perl* packages in yum.conf once installed.
	 // Install the RPM for the EPEL repo as it has the Agent and all it's dependencies, rpmforge does not
	 // The RPM makes an /etc/sysconfig/ocsinventory-agent file which sets variables and which is 
	 // in turn called by an hourly cron job

	 // You can select below whether you want to install the Agent from EPEL or wget the newer version.

        if($ks_ocs == 'ocs'){
                $ks_anaconda .= ('
		echo -e "Installing OCS. . . " > /dev/tty1

                #If CPanel is already installed it blocks any perl* rpms from being installed, so diasble if present
                sed -i s/perl/sago/ /etc/yum.conf

                cd /root
                #Install the EPEL repo which contains all the stuff needed for OCS in one place
                rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm

                #xyum -y install ocsinventory-agent
                #Do not install the repo version of OCS itself, install the newer RPM version instead

                wget http://ks.sagonet.com/tools/ocs/ocsinventory-agent-1.0.1-2.el4.remi.noarch.rpm
                yum -y install yum-utils
                yum -y --nogpgcheck localinstall ocsinventory-agent-1.0.1-2.el4.remi.noarch.rpm

                echo -e "OCSMODE[0]=cron" >> /etc/sysconfig/ocsinventory-agent
                echo -e "OCSSERVER[0]=ocs.sagonet.com" >> /etc/sysconfig/ocsinventory-agent
                echo -e "OCSTAG[0]=Dedicated-PXE" >> /etc/sysconfig/ocsinventory-agent

                #Leave EPEL repo installed, but turn it off in case we need it later
                #sed -i s/enabled=1/enabled=0/ /etc/yum.repos.d/epel.repo
                #xrm -y epel-release-5-4.noarch.rpm

                #Remove EPEL altogher
                rpm -e epel-release-5-4

                mv /etc/cron.hourly/ocsinventory-agent /etc/cron.daily/

                #Restore Cpanel blocking  perl* rpms from being installed
                sed -i s/sago/perl/ /etc/yum.conf	
		');
                }
	
	// Control Panel Installation
        if($ks_cp == 'cpnl'){
                $ks_anaconda .= ('
                        echo -e "Installing Control Panel..." > /dev/tty1
                        mkdir /home/cpins
                        cd /home/cpins
                        wget http://layer1.cpanel.net/latest
                        mv /home/cpins/latest /home/cpins/install-cpanel.sh
                        chmod +x /home/cpins/install-cpanel.sh
			ln -s /home/cpins/install-cpanel.sh /root/
			umount /backup
                        mkdir /backup
                        echo \'/backup is set with the immutable bit (chattr +i /backup) in order to prevent your root (/) directory from filling up when you dont have your backup drive mounted. If you dont
want this run chattr -i /backup to remove this attribute\' > /backup/why-cant-I-write-to-this-directory
                        chattr +i /backup

                ');
        }
	else if($ks_cp == 'iwrx'){
		$ks_anaconda .= ('
			cd /root/
			wget http://updates.interworx.com/iworx/scripts/iworx-cp-install.sh
		');
	}
	
	// IP Is Specified
	if(strlen($ks_ip) > 0){
		$ks_anaconda .= ("
			echo -e 'Configuring Primary IP Address...' > /dev/tty1
			echo -e 'DEVICE=eth0\nONBOOT=yes\nBOOTPROTO=static\nIPADDR=$ks_ip\nNETMASK=255.255.255.0\nGATEWAY=$ks_gateway\n' > /etc/sysconfig/network-scripts/ifcfg-eth0
		");
	}

	// Setup IP Range
	if($ks_ipnum > 1){
		$ks_anaconda .= ("
			echo -e 'Configuring IP Range...' > /dev/tty1
			echo -e 'IPADDR_START=$ks_ipmin\nIPADDR_END=$ks_ipmax\nCLONENUM_START=0' > /etc/sysconfig/network-scripts/ifcfg-eth0-range0
		");
	}

        $ks_anaconda .= file_get_contents('centos.security.extras');

        // Final Steps
        $ks_anaconda .= ("
        yum -y remove Canna FreeWnn FreeWnn-libs gpm cups 
        yum -y remove iiimf*
        yum -y remove xorg*
        yum -y remove portmap*
        yum -y remove pcmcia-cs bluez*
	yum -y remove pcsc*
	yum -y remove gamin
        yum -y install vim-enhanced screen gcc at 
	yum -y update
	chkconfig sendmail on
	echo \"kernel.sysrq = 1\" >> /etc/sysctl.conf
        chvt 1
        ");

	
?>	
