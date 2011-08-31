<?php

// For Linux Distributions That Use Anaconda

$ks_anaconda = ("
	install
	authconfig --enableshadow --enablemd5
	network --device eth0 --bootproto dhcp
	firewall --disabled
	selinux --disabled
	lang en_US.UTF-8
	#langsupport --default=en_US.UTF-8
	keyboard us
	url --url $ks_repos
	text
");

// Manual Partitions
if($ks_partitions == 'man'){ }

// testing Partitions make a minimal base for quick formatting

else if($ks_partitions == 'testing'){
                        $script_partition = ("
        clearpart --drives=$ks_hd --initlabel
        part swap --recommended --ondisk=$ks_hd --asprimary
        part / --size=20480 --ondisk=$ks_hd --asprimary
                        ");
                }

// Software RAID 0
else if($ks_partitions == '0'){
	
	// No Control Panel
	if($ks_cp == 'none'){
			$script_partition = ("
	clearpart --drives=$ks_hd,$ks_hd2 --initlabel
	part /boot --size=250 --ondisk=$ks_hd --asprimary
	part swap --recommended --ondisk=$ks_hd2 --asprimary
	part raid.103 --size=1 --grow --ondisk=$ks_hd --asprimary
	part raid.104 --size=1 --grow --ondisk=$ks_hd2 --asprimary
	raid / --fstype ext3 --level=0 --device=md1 raid.103 raid.104
			");		
	} // End No CP
	
	// CP 
	else {
				$script_partition = ("
	clearpart --drives=$ks_hd,$ks_hd2 --initlabel
	part /boot --size=250 --ondisk=$ks_hd --asprimary
	part swap --recommended --ondisk=$ks_hd2 --asprimary
	part raid.104 --size=5120 --ondisk=$ks_hd --asprimary
	part raid.105 --size=5120  --ondisk=$ks_hd2 --asprimary
	part raid.106 --size=15360 --ondisk=$ks_hd
	part raid.107 --size=15360 --ondisk=$ks_hd2
	part raid.108 --size=20480 --ondisk=$ks_hd
	part raid.109 --size=20480 --ondisk=$ks_hd2
	part raid.110 --size=1024 --ondisk=$ks_hd
	part raid.111 --size=1024 --ondisk=$ks_hd2
	part raid.112 --size=1 --grow --ondisk=$ks_hd
	part raid.113 --size=1 --grow --ondisk=$ks_hd2
	raid / --fstype ext3 --level=0 --device=md1 raid.104 raid.105
	raid /usr --fstype ext3 --level=0 --device=md2 raid.106 raid.107
	raid /var --fstype ext3 --level=0 --device=md3 raid.108 raid.109
	raid /tmp --fstype ext3 --level=0 --device=md4 raid.110 raid.111
	raid /home --fstype ext3 --level=0 --device=md5 raid.112 raid.113
			");
	} // End CP
} // End Software RAID 0

// Software RAID 1
else if($ks_partitions == '1'){

	// No Control Panel
	if($ks_cp == 'none' || $ks_cp == 'plsk' || $ks_cp == 'iwrx'){
			$script_partition = ("
	clearpart --drives=$ks_hd,$ks_hd2 --initlabel
	part swap --recommended --ondisk=$ks_hd --asprimary
	part swap --recommended --ondisk=$ks_hd2 --asprimary
	part raid.102 --size=1 --grow --ondisk=$ks_hd --asprimary
	part raid.103 --size=1 --grow --ondisk=$ks_hd2 --asprimary
	raid / --fstype ext3 --level=1 --device=md1 raid.102 raid.103
			");
	} // End No CP
	
	// cPanel
	else {
				$script_partition = ("
	clearpart --drives=$ks_hd,$ks_hd2 --initlabel
	part swap --recommended --ondisk=$ks_hd --asprimary
	part swap --recommended --ondisk=$ks_hd2 --asprimary
	part raid.102 --size=5120 --ondisk=$ks_hd --asprimary
	part raid.103 --size=5120  --ondisk=$ks_hd2 --asprimary
	part raid.104 --size=15360 --ondisk=$ks_hd
	part raid.105 --size=15360 --ondisk=$ks_hd2
	part raid.106 --size=20480 --ondisk=$ks_hd
	part raid.107 --size=20480 --ondisk=$ks_hd2
	part raid.108 --size=1024 --ondisk=$ks_hd
	part raid.109 --size=1024 --ondisk=$ks_hd2
	part raid.110 --size=1 --grow --ondisk=$ks_hd
	part raid.111 --size=1 --grow --ondisk=$ks_hd2
	raid / --fstype ext3 --level=1 --device=md1 raid.102 raid.103
	raid /usr --fstype ext3 --level=1 --device=md2 raid.104 raid.105
	raid /var --fstype ext3 --level=1 --device=md3 raid.106 raid.107
	raid /tmp --fstype ext3 --level=1 --device=md4 raid.108 raid.109
	raid /home --fstype ext3 --level=1 --device=md5 raid.110 raid.111
			");
	} // End cPanel
} // End Software RAID 1

else if($ks_partitions == 'none'){

	// No Control Panel
	if($ks_cp == 'none' || $ks_cp == 'plsk' || $ks_cp == 'iwrx'){
	
		// Install on Any HD
		if($ks_hd == 'any'){
			$script_partition = ("
	clearpart --all --initlabel
	part swap --recommended --asprimary
	part / --fstype ext3 --size=1 --grow --asprimary
			");
			
		// User Specified HD
		} else {
			$script_partition = ("
	clearpart --drives=$ks_hd --initlabel
	part swap --recommended --ondisk=$ks_hd --asprimary
	part / --fstype ext3 --size=1 --grow --ondisk=$ks_hd --asprimary
			");
		}
	} // End No CP
	
	// cPanel
	else {
	
		// Install on Any HD
		if($ks_hd == 'any'){
				$script_partition = ("
	clearpart --all --initlabel
	part swap --recommended --asprimary
	part / --size=5120 --asprimary
	part /usr --size=20480
	part /var --size=51200
	part /tmp --size=1024
	part /home --size=1 --grow
		");
			
		// User Specified HD	
		} else {	
			$script_partition = ("
	clearpart --drives=$ks_hd --initlabel
	part swap --recommended --ondisk=$ks_hd --asprimary
	part / --size=5120 --ondisk=$ks_hd --asprimary
	part /usr --size=20480 --ondisk=$ks_hd
	part /var --size=51200 --ondisk=$ks_hd
	part /tmp --size=1024 --ondisk=$ks_hd
	part /home --size=1 --grow --ondisk=$ks_hd
			");
		}	
	} // End cPanel
} // End Automatic Partitions

// Add Partition Info To KS
$ks_anaconda .= $script_partition;

$ks_anaconda .= ("
	bootloader --location=mbr
	timezone America/New_York
	rootpw $ks_password
	skipx
	%packages
	e2fsprogs
	grub
	mdadm
	kernel
"); 
?>
