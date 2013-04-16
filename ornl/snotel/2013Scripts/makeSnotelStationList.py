#!/bin/python

# Script:  makeSnotelStationList.py
# Purpose: Scrapes NRCS website to create a station list.
# Input:   The URL or HTML file to process
# Output:  Text file containing a list of STATE STATIONID paris.
#          Gets all states and stations by default, but you can modify for a specific state, etc.  
# Usage:   python ./makeSnotelStationList.py > mystationlist.txt
#
# Pete Eby, 2013
# Oak Ridge Nation Laboratory
# All Data is Provisional
# ebypi@ornl.gov


# Helpful sites
# http://stackoverflow.com/questions/13074586/extracting-selected-columns-from-a-table-using-beautifulsoup

import urllib2
from BeautifulSoup import BeautifulSoup
from sys import argv

#get HTML file as a string
#filename = argv[1]
#html_doc = ''.join(open(filename,'r').readlines())
#soup = BeautifulSoup(html_doc)

#get data directly from a url
# One state:
#url = "http://www.wcc.nrcs.usda.gov/nwcc/yearcount?network=sntl&counttype=statelist&state=AK"
# The whole enchilada
url = "http://www.wcc.nrcs.usda.gov/nwcc/yearcount?network=sntl&counttype=statelist"

soup = BeautifulSoup(urllib2.urlopen(url).read())

# The nrcs.usda.gov site currently does not identify the tables with and name. Gee, thanks. 
# View source and determine which table instance we need to parse, currently its 7.
rows = soup.findAll('table')[7].findAll('tr')
for row in rows:
     cell = row.findAll("td")
     if len(cell) > 0:	# Because the first row is blank. Don't ask me. 
       #print cell[1].renderContents(), cell[2].renderContents()
       state = cell[1].renderContents()
       stationID = cell[2].renderContents()
       stationID = stationID[stationID.find("(")+1:stationID.find(")")]
       #Above is just a fancy substring notation, like: stationID = stationID[1:3]
       print state, stationID
