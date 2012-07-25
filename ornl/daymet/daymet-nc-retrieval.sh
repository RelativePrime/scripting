#!/bin/bash
# Script to download individual .nc files from the ORNL
# Daymet server at: http://daymet.ornl.gov
#
# NOTE: Compressed tar.gz files containing all .nc files for 
# a tile are separately available at the above address.
# Downloading the tar.gz files is far faster should you
# require all available data for a tile. 
# 
# Tile IDs must be provided either as a range
# of values, or as a space seperated list. Tile IDs may
# be determined from the Daymet mask of the conterminous 
# United States, visible for example at:
# http://daymet.ornl.gov/gridded
#
# Methods using wget and curl are shown. Each uses a resaonable
# rate limit for downloading data. Users attempting to download
# data at higher rates may be rate limited by the server. 
#
# The example downloads the vp.nc file for given year and tile
# ranges. You may change vp.nc to be any of the following: 
# vp.nc, tmin.nc, tmax.nc, swe.nc, srad.nc, prcp.nc, dayl.nc
#
# Data is also available via the THREDDS web interface at:
# http://daymet.ornl.gov/thredds/catalog/allcf/catalog.html
#
# Citation Information is available at:
# http://daymet.ornl.gov/sites/default/files/Daymet_Reference_Citation.pdf
#
# Pete Eby
# Oak Ridge National Lab


# For ranges use {start..end}
# for individul vaules, use: 1 2 3 4 
for year in {2002..2003}
do
   for tile in {1159..1160}
        do wget --limit-rate=3m http://daymet.ornl.gov/thredds/fileServer/allcf/${year}/${tile}_${year}/vp.nc -O ${tile}_${year}_vp.nc
        # An example using curl instead of wget
	#do curl --limit-rate 3M -o ${tile}_${year}_vp.nc http://daymet.ornl.gov/thredds/fileServer/allcf/${year}/${tile}_${year}/vp.nc
     done
done
