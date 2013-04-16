#!/bin/bash
#
# Script:   getYearByStationId.sh
# Purpose:  Get yearly data summary for a list of provided stations
# Input:    station_list.txt year
# Output:   Creates a $YEAR.snotelsummaries directory. Subdirs contain tab seperated data for each state and station.
#
# Pete Eby, 2013
# Oak Ridge Nation Laboratory
# All Data is Provisional
# ebypi@ornl.gov

# HOW TO USE:
#
# Obtain a list of stationids by state using makeSnotelStationList.py 
# This will create a station list of states and station IDs, such as:
#
#AK 1189
#AK 1062 
#...
# (any combination of whitespace for seperation is fine.)

if  [[ $# -lt 2  ]]
then
    echo "Script to get yearly summaries for all stations."
    echo "usage: $0 STATION_LIST.txt YEAR OFFSET [--dryrun]"
    echo "where: "
    echo "      STATION_LIST is a .txt file containing the state and station id"
    echo "      YEAR is YYYY"
    echo "      OFFEST is integer for numer of days to offset start date"
    echo "	dryrun (Optional) Show the curl statment to be used to get"
    echo "	the data (for debugging purposes.)"
    echo "Example: $0 mystations.txt 2012 -466,-100 --dryrun"
    exit
fi

# Get argv
STATIONLIST=$1
YEAR=$2
OFFSET=$3
# Offset is not implemented yet. Might not be required. 

# Leave these
CURRENTSTATE="null"
DOWNLOADS=0

mkdir $YEAR.snotel.summaries
cd $YEAR.snotel.summaries

while read inputline
do
  STATE="$(echo $inputline | awk '{print $1}')"
  #STATE="$(echo $STATE | tr '[:upper:]' '[:lower:]')"
if [[ "$CURRENTSTATE" != "$STATE"  &&  -n "$STATE" ]]
then
	CURRENTSTATE=$STATE 
	echo 
	echo "Creating $STATE directory . . . "
	echo
	mkdir $STATE
fi

  STATIONID="$(echo $inputline | awk '{print $2}')"
  #STATIONID="$(echo $STATIONID | tr '[:upper:]' '[:lower:]')"

  echo Downloading: State = $STATE and stationid = $STATIONID . . .

if [ -n "$STATE" ]
then 
  let "DOWNLOADS += 1"
fi


#################
# Direct CSV Link
#################

# Direct link to CSV file that can be downloaded with curl. In this example:
# YEAR = 2012
# STATE = AK
# STATIONID=1189
# OFFSET = -466,100


# Here we use an offset of -466,-100 instead of the defualt of -7,0 to obtain the date range we need:

# http://www.wcc.nrcs.usda.gov/reportGenerator/beta/view_csv/customSingleStationReport%2Cmetric/daily/1189%3AAK%3ASNTL%7Cid%3D%22%22%7Cname/-466%2C-100/PREC%3A%3Avalue%2CTMAX%3A%3Avalue%2CTMIN%3A%3Avalue%2CTAVG%3A%3Avalue

# By using the dev console in Chrome, network tab, we can extract the URL for the report which is downloaded to the browser, in this case:

#http://www.wcc.nrcs.usda.gov/reportGenerator/generateReport.html?report=customSingleStationReport&begin=2012-01-06&end=2013-01-06&station=1189:AK:SNTL&duration=daily&columns=%3Cdata%20name=%22COL_1%22%20displayName=%22Year-to-Date%26lt;br/%26gt;Precipitation%22%20element=%22PREC%22/%3E%3Cdata%20name=%22COL_2%22%20displayName=%22Max%26lt;br/%26gt;Temp%22%20element=%22TMAX%22/%3E%3Cdata%20name=%22COL_3%22%20displayName=%22Min%26lt;br/%26gt;Temp%22%20element=%22TMIN%22/%3E%3Cdata%20name=%22COL_4%22%20displayName=%22Avg%26lt;br/%26gt;Temp%22%20element=%22TAVG%22/%3E&output=csv&units=metric

if [ "$4" = "--dryrun" ]
then
 echo
 echo -e "\033[32mDry Run:\033[0m"
 echo The following URL format will be used:
 # This is using only year date range, no variables yet
 echo curl "http://www.wcc.nrcs.usda.gov/reportGenerator/generateReport.html?report=customSingleStationReport&begin=2012-01-06&end=2013-01-06&station=${STATIONID}:${STATE}:SNTL&duration=daily&columns=%3Cdata%20name=%22COL_1%22%20displayName=%22Year-to-Date%26lt;br/%26gt;Precipitation%22%20element=%22PREC%22/%3E%3Cdata%20name=%22COL_2%22%20displayName=%22Max%26lt;br/%26gt;Temp%22%20element=%22TMAX%22/%3E%3Cdata%20name=%22COL_3%22%20displayName=%22Min%26lt;br/%26gt;Temp%22%20element=%22TMIN%22/%3E%3Cdata%20name=%22COL_4%22%20displayName=%22Avg%26lt;br/%26gt;Temp%22%20element=%22TAVG%22/%3E&output=csv&units=metric"
 echo 
 exit 
fi

 # This is using only week date range, no variables yet
 curl "http://www.wcc.nrcs.usda.gov/reportGenerator/generateReport.html?report=customSingleStationReport&begin=2012-01-06&end=2012-01-13&station=${STATIONID}:${STATE}:SNTL&duration=daily&columns=%3Cdata%20name=%22COL_1%22%20displayName=%22Year-to-Date%26lt;br/%26gt;Precipitation%22%20element=%22PREC%22/%3E%3Cdata%20name=%22COL_2%22%20displayName=%22Max%26lt;br/%26gt;Temp%22%20element=%22TMAX%22/%3E%3Cdata%20name=%22COL_3%22%20displayName=%22Min%26lt;br/%26gt;Temp%22%20element=%22TMIN%22/%3E%3Cdata%20name=%22COL_4%22%20displayName=%22Avg%26lt;br/%26gt;Temp%22%20element=%22TAVG%22/%3E&output=csv&units=metric" > ./$STATE/$YEAR.$STATE.$STATIONID.txt

sleep 2 
echo 

done < ../$STATIONLIST

echo
echo -e "\033[32mCOMPLETED:\033[0m Water year summaries downloaded to state directories." 
echo "Downloaded $DOWNLOADS annual summaries."
echo 

