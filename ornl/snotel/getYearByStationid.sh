#!/bin/bash
#
# Script: getYearByStationId.sh
# Purpose: Get yearly data summary for a list of provided stations
# Input: station_list.txt year
# Output: Creates a $YEAR.snotelsummaries directory. Subdirs contain tab seperated data for each state and station.
# Pete Eby, 2011, Oak Ridge Nation Laboratory, All Data is Provisional
# ebypi@ornl.gov

# HOW TO USE:
#
# Obtain a list of stationids by state at:
# http://www.wcc.nrcs.usda.gov/nwcc/sitelist.jsp
#
# Copy the contents the above table to a spreadsheet. Then, rename all the states from
# abbreviations to full names, thus SD becomes south_dakota.
#
# (Grabbing and parsing this table with curl, etc. is problematic as there are
# multiple station IDs formats (05K26S, ME11, 5K30S, etc.) to match with regexes -
# it's just as easy to create a list from the current station list as above.)
#
# The data must also be converted to all lower case as well, but we do this on the fly.
# Paste only these two columns into a file named StationList.txt. Contents should look like:
#
#alaska      49T03S
#alaska      51K05S
#...
# (any combination of whitespace for seperation is fine.)

if  [[ $# -lt 2  ]]
then
    echo "Script to get yearly summaries for all stations."
    echo "usage: $0 STATION_LIST.txt YEAR dryrun"
    echo "where: "
    echo "      STATION_LIST is a .txt file containing the state and station id"
    echo "      YEAR is YYYY"
    echo "	--dryrun (Optional) Show the url format that will be used to wget"
    echo "	the data (for debugging purposes.)"
    exit
fi


STATIONLIST=$1
YEAR=$2

# Leave these
CURRENTSTATE="null"
DOWNLOADS=0

mkdir $YEAR.snotel.summaries
cd $YEAR.snotel.summaries

while read inputline
do
  STATE="$(echo $inputline | awk '{print $1}')"
  STATE="$(echo $STATE | tr '[:upper:]' '[:lower:]')"
if [[ "$CURRENTSTATE" != "$STATE"  &&  -n "$STATE" ]]
then
	CURRENTSTATE=$STATE 
	echo 
	echo "Creating $STATE directory . . . "
	echo
	mkdir $STATE
fi

  STATIONID="$(echo $inputline | awk '{print $2}')"
  STATIONID="$(echo $STATIONID | tr '[:upper:]' '[:lower:]')"

  echo Downloading: State = $STATE and stationid = $STATIONID . . .

if [ -n "$STATE" ]
then 
  let "DOWNLOADS += 1"
fi

###########
# Web table
###########

# You most likely want the below direct link to the .csv file instead.

# Example request url for a specific site. This uses state abbreviations 
# http://www.wcc.nrcs.usda.gov/cgibin/tab-display.pl?filename=33j01s_2010.tab&state=AK&stationid=33j01s

#wget --quiet --wait=3 -O ./$STATE/$YEAR.$STATE.$STATIONID.txt "$YEAR.$STATE.$STATIONID.txt http://www.wcc.nrcs.usda.gov/cgibin/tab-display.pl?filename=${STATIONID}_${YEAR}.tab&state=${STATE}&stationid=${STATIONID}"
# sleep 1

#################
# Direct CSV Link
#################

# Direct link to CSV file. Note full state names are used here. 
# http://www.wcc.nrcs.usda.gov/ftpref/data/snow/snotel/cards/alaska/49t03s_2010.tab

if [ "$3" = "--dryrun" ]
then
 echo
 echo -e "\033[32mDry Run:\033[0m"
 echo The following URL format will be used:
 echo wget --quiet --wait=3 -O ./$STATE/$YEAR.$STATE.$STATIONID.txt "http://www.wcc.nrcs.usda.gov/ftpref/data/snow/snotel/cards/${STATE}/${STATIONID}_${YEAR}.tab"
 echo 
 exit 
fi

wget --quiet --wait=3 -O ./$STATE/$YEAR.$STATE.$STATIONID.txt "http://www.wcc.nrcs.usda.gov/ftpref/data/snow/snotel/cards/${STATE}/${STATIONID}_${YEAR}.tab"
sleep 1 

done < ../$STATIONLIST

echo
echo -e "\033[32mCOMPLETED:\033[0m Water year summaries downloaded to state directories." 
echo "Downloaded $DOWNLOADS annual summaries."
echo 

