#!/bin/bash
# Pete Eby 14 July 2011
# Cheesy script to install Mod_security for RHEL 6 and install the ever popular GotRoot ruleset.
# Adapted from the horrific install instructions at:
# http://www.atomicorp.com/wiki/index.php/Atomic_ModSecurity_Rules

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

yum --enablerepo=epel install mod_security

# Well, that was hard. 
# You can now just restart apache, and run with the basic mod_sec rules in /etc/httpd/modsecurity.d/
# These rules are, however, rather limited. 
# To install the Got Root rules:

mkdir -p /var/asl/tmp
mkdir -p /var/asl/data/msa
mkdir  /var/asl/data/audit
mkdir  /var/asl/data/suspicious
chown -R apache:apache /var/asl/data/

mkdir /etc/asl
touch /etc/asl/whitelist

# Put the Got Root rules in their own include dir, so we can easily use either the default
# mod_security rules, or the Got Root rules. The Got Root rules can be too restrictive, and 
# may need tweaked. 
mkdir /etc/httpd/modsecurity.d/asl_rules

cd /root
wget http://updates.atomicorp.com/channels/rules/delayed/modsec-2.5-free-latest.tar.bz2
tar jxvf modsec-2.5-free-latest.tar.bz2 
cp modsec/* /etc/httpd/modsecurity.d/asl_rules

echo
echo
echo -e '\033[32mTo Complete Installation:\033[0m'
echo 
echo "Please edit /etc/httpd/conf.d/mod_security.conf"
echo
echo "Include modsecurity.d/asl_rules/*asl*.conf <=== Add only the *asl*.conf rules or you will get errors when starting"
echo "#Include modsecurity.d/base_rules/*.conf  <== Comment this out to use only the Got Root rules"
echo
echo "(Running both rule sets simultaneously is possible, better to use one or the other.)"
echo 
echo "Note: You can enable / disable rule enforement by changing this directive and restarting apache:"
echo "SecRuleEngine On"
echo
echo "Once mod_security.conf is configured, test the config and restart Apache:"
echo "apachectl configtest"
echo "apachectl graceful"
echo 
echo -e '\033[32mTesting:\033[0m'
echo "Try running: wget http://localhost/foo.php?foo=http://www.example.com"
echo "If you get a 403 (access denied) the got root rules worked, if you get a 404 there is a problem."
echo 

