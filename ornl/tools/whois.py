#!/usr/bin/env python
#
# Whios port being blocked got you down?
# Query for whois info via http and parse results with 
# BeautifulSoup. Networksolutions.com whois info
# is handily returned in <pre> tag for easy parsing.
#
# Need BeautifulSoup?
# On RHEL6:
#  yum --enablerepo=epel install python-pip
#  pip-python install beautifulsoup
#  For manual install, see the official site:
#  http://www.crummy.com/software/BeautifulSoup/
#
# For ipv6 support optionally install IPy
# pip-python install IPy
# (Uncomment below to import)
# http://pypi.python.org/pypi/IPy/
#
# Curl works to:
#  curl -s http://www.networksolutions.com/whois/results.jsp?ip=4.2.2.2
#  curl -s http://www.networksolutions.com/whois-search/domain
#  Bash whois script: http://pastebin.com/G2dvRzVr
#
# Handy URLs
#  http://www.whos.com/whois/domain
#  (Supports .gov)
#  http://www.networksolutions.com/whois-search/domain 
#  (Does not support .gov, but tidy htlm)
#  http://www.networksolutions.com/whois/results.jsp?ip=
#
# Pete Eby
# 17 July 2012 
# Oak Ridge National Lab

from BeautifulSoup import BeautifulSoup
import urllib2
import sys
import socket
import re
import os
# Optionally, pip install IPy for ipv6 support
#import IPy

if len(sys.argv)<2:
	print "\033[91mUseage: " + sys.argv[0] + " domain.com or ipv4 addr\033[0m"
	print "\033[91mipv6 supported if IPy module is installed.\033[0m"
	sys.exit()

domain = sys.argv[1]

# If a valid IP is passed, use it - else use string as FQDN

# Check for valid ipv4 / ipv6 addr:
try:
	#For ipv4/ipv6 dual stack identifiation
	if 'IPy' in sys.modules:
		IPy.IP(domain)
	# socket for ipv4 only
	else:
		socket.inet_aton(domain)
	print "\033[92mQuerying by IP address " + domain +"\033[0m"
	url="http://www.networksolutions.com/whois/results.jsp?ip=" + domain
	page=urllib2.urlopen(url)
	soup = BeautifulSoup(page.read())
	whois=soup.findAll('pre')
	print whois

	print "\n \033[92m The reverse PTR is: \033[0m"
	cmd = "dig +short -x " + domain
	os.system(cmd)
	# Alternate way using IPy:
	# domain.reverseNames()

# Otherwise just use the string
except:
#socket module has an .error method, but IPy does not, so just catch all. 
#except socket.error:
	print "\033[92mQuering by domain name " + domain +"\033[0m"
	url="http://www.whos.com/whois/" + domain

	# Whois lookups on .gov domains are only allowed on some whois servers, and
	# only return if the domain is Active or not. Using whos.com works, but
	# the html is less than clean
	if domain.endswith('.gov'):
		print "Whois on .gov domains will only return status as Active or None"
	        page=urllib2.urlopen(url)
	        soup = BeautifulSoup(page.read())
		agency = soup.find(text=re.compile('ACTIVE'))
		#agency = soup.findAll('h2',{'style':'text-decoration':'blink'})
		#agency = soup.find(text=re.compile('ACTIVE'))
		print "Status: " + str(agency)
		sys.exit
	else:
		# Network solutions output is tidy and easy
		url="http://www.networksolutions.com/whois-search/" + domain
		page=urllib2.urlopen(url)
		soup = BeautifulSoup(page.read())
		whois = soup.findAll('pre')
		print whois
		
		# Ways to check for empty whois result set returned
		#if soup.title:
		#	print "Nothing returned. Perhaps typo in domain name: " + domain
		#	print soup.title
		#	sys.exit()
		#print soup.title

		if not whois:
			print "Nothing returned. Perhaps typo in domain name: " + domain
			print "Or the whois server is being evil."
			sys.exit()

	print "\n \033[92m Dig shows Authoritative name servers are \033[0m"
	cmd = 'dig -t ns ' + domain + ' | grep -A 6 "ANSWER SECTION" '
	os.system(cmd)


# Posterity postulation 
# Add API query to SourceFire to show IP threat

