<?php
header('Content-Type: text/plain'); 

// Parse Data from PXE Menu
$gd_split = explode(':', $_GET['x']);
$ks_os = $gd_split[0];
$ks_bit = $gd_split[1];
$ks_partitions = $gd_split[2];
$ks_hd = $gd_split[3];
$ks_hd2 = $gd_split[4];
$ks_cp = $gd_split[5];
$ks_ip = $gd_split[6];
$ks_ipnum = $gd_split[7];
$ks_password = $gd_split[8];
$ks_ocs = $gd_split[9];


// Set Other Variables
$ks_hostname = str_replace('.', '-', $ks_ip);
$ks_ipsplit = explode('.', $ks_ip);
$ks_gateway = ($ks_ipsplit[0] . '.' . $ks_ipsplit[1] . '.' . $ks_ipsplit[2] . '.1');
$ks_ipmax = ($ks_ipsplit[0] . '.' . $ks_ipsplit[1] . '.' . $ks_ipsplit[2] . '.' . (($ks_ipsplit[3] + $ks_ipnum) -1));
$ks_ipmin = ($ks_ipsplit[0] . '.' . $ks_ipsplit[1] . '.' . $ks_ipsplit[2] . '.' . ($ks_ipsplit[3] +1));

// Set Architechture
if($ks_bit == '64'){ $ks_arch = 'x86_64'; } 
else { $ks_arch = 'i386'; }

// Set Defaults
if(strlen($ks_password) <1){ $ks_password = 's4g0n3t'; }
if(strlen($ks_partitions) <1){ $ks_partitions = 'none'; }
if(strlen($ks_cp) <1){ $ks_cp = 'none'; }
if(strlen($ks_hd) <1){ $ks_hd = 'any'; }

//***** OS SELECTION *****
switch ($ks_os) {

	// CentOS 3.8
	case "c39":
		$ks_repos = "http://yum.sagonet.com/3.9/os/$ks_arch";
		require_once('anaconda.php');
		require_once('post_c4.php');
		$ks_script = $ks_anaconda;
	break;
	case "c48":
		$ks_repos = "http://yum.sagonet.com/4.8/os/$ks_arch";
		require_once('anaconda.php');
		require_once('post_c4.php');
		$ks_script = $ks_anaconda;
	break;
        // CentOS 5.2
        case "c52":
		//The 5.2 Official repo get updated to 5.3, so you have to use one from the vault
		//site, or make one locally on cobbler. Let's use the vault so we don't need to mirror it. 
                //
		//Point this to Cobbler server where a 5.2 repo is, outside IP for VNC installs
                // $ks_repos = "http://66.111.32.131/cblr/links/c52-i386";
                
		//Use the official vault site for 5.2 
		$ks_repos = "http://vault.centos.org/5.2/os/$ks_arch";
		require_once('anaconda.php');
                require_once('post_c5.2.php');
                $ks_script = $ks_anaconda;
        break;	

	// CentOS 5.3
        case "c53":
                $ks_repos = "http://yum.sagonet.com/5.3/os/$ks_arch";
                require_once('anaconda.php');
                require_once('post_c5.2.php');
                $ks_script = $ks_anaconda;
        break;

	// CentOS 5.4
        case "c54":
                $ks_repos = "http://yum.sagonet.com/5.4/os/$ks_arch";
                require_once('anaconda.php');
                require_once('post_c5.2.php');
                $ks_script = $ks_anaconda;
        break;
	
	// CentOS 5.5
        case "c55":
               # $ks_repos = "http://yum.sagonet.com/5.5/os/$ks_arch";
                $ks_repos = "http://centos-mirror.tpa.sagonet.net/5.5/os/$ks_arch";
                require_once('anaconda.php');
                require_once('post_c5.2.php');
                $ks_script = $ks_anaconda;
        break;

	// Fedora Core 5
	case "fc5":
		$ks_repos = "http://fedora-mirror.tpa.sagonet.net/5/$ks_arch/os/";
		require_once('anaconda.php');
		require_once('post_fedora.php');
		$ks_script = $ks_anaconda;
	break;
	
	// Fedora Core 6
	case "fc6":
		$ks_repos = "http://fedora-mirror.tpa.sagonet.net/6/$ks_arch/os/";
		require_once('anaconda.php');
		require_once('post_fedora.php');
		$ks_script = $ks_anaconda;
	break;

	// Fedora Core 7
	case "fc7":
		$ks_repos = "http://fedora-mirror.tpa.sagonet.net/7/$ks_arch/os/";
		require_once('anaconda.php');
		require_once('post_fedora.php');
		$ks_script = $ks_anaconda;
	break;
	
	// Fedora Core 8
	case "fc8":
		$ks_repos = "http://fedora-mirror.tpa.sagonet.net/8/$ks_arch/os/";
		require_once('anaconda.php');
		require_once('post_fedora.php');
		$ks_script = $ks_anaconda;
	break;

        // Fedora Core 9
        case "fc9":
                $ks_repos = "http://fedora-mirror.tpa.sagonet.net/9/$ks_arch/os/";
                require_once('anaconda.php');
                require_once('post_fedora.php');
                $ks_script = $ks_anaconda;
        break;

	// Fedora Core 10
        case "fc10":
                $ks_repos = "http://fedora-mirror.tpa.sagonet.net/10/$ks_arch/os/";
                require_once('anaconda.php');
                require_once('post_fedora.php');
                $ks_script = $ks_anaconda;
        break;

	 // Fedora Core 11
        case "fc11":
                $ks_repos = "http://fedora-mirror.tpa.sagonet.net/11/$ks_arch/os/";
                require_once('anaconda.php');
                require_once('post_fedora.php');
                $ks_script = $ks_anaconda;
        break;

	// Fedora Core 12
        case "fc12":
                $ks_repos = "http://fedora-mirror.tpa.sagonet.net/12/$ks_arch/os/";
                require_once('anaconda.php');
                require_once('post_fedora.php');
                $ks_script = $ks_anaconda;
        break;
	
	// Fedora Core 13
        case "fc13":
                $ks_repos = "http://fedora-mirror.tpa.sagonet.net/13/$ks_arch/os/";
                require_once('anaconda.php');
                require_once('post_fedora.php');
                $ks_script = $ks_anaconda;
        break;

	// Fedora Core 14
        case "fc14":
                #$ks_repos = "http://fedora-mirror.tpa.sagonet.net/14/$ks_arch/os/";
                $ks_repos = "http://mirror.anl.gov/fedora/linux/releases/14/Fedora/$ks_arch/os/";
                require_once('anaconda.php');
                require_once('post_fedora.php');
                $ks_script = $ks_anaconda;
        break;


	
	// Ubuntu 6.10 (Edgy)
	case "edgy":
		$ks_repos = "http://ubuntu-mirror.tpa.sagonet.net/";
		require_once('ubuserv.php');
		$ks_script = $ks_anaconda;
	break;

	// Ubuntu 6.10 (Edgy)
	case "dapper":
		$ks_repos = "http://ubuntu-mirror.tpa.sagonet.net/";
		require_once('ubuserv.php');
		$ks_script = $ks_anaconda;
	break;
	// Ubuntu 6.10 (Edgy)
	case "feisty":
		$ks_repos = "http://ubuntu-mirror.tpa.sagonet.net/";
		require_once('ubuserv.php');
		$ks_script = $ks_anaconda;
	break;


} 
//***** END OS SELECTION *****

//Display Script
echo "#Here are some examples of the Magick PXE string:
#http://ks.sagonet.com/?x=c53:::sda::cpnl:66.118.151.60:02:s4g0n3t:ocs
#                       x=os:bit:partitions:installdrive:secondinstalldrive:cpanel:ip:#ips:password:ocs";
echo $ks_script;

?>
