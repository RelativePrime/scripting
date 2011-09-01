#!/bin/bash
#
# Adds header information to islscp data sets.
# (Run it in a direcory containing islscp zip'ed datasets) 
#
# This script loops through the contents of a directory, unzipping any files it finds.
# It then iterates through cd'ing into each unziped directory, and adding a header to 
# each file. 
# 
# It will try to determin what kind of dataset it is (1 degree or half degree) and
# add the appropriate header. 
# 
# Logs to headers.log
#
# Pete Eby
# Oak Ridge National Laboratory
#

# Things to add:
# Perform a check to ensure each .asc file has either X or Y numbers of lines, which 
# indicates that headers have been added. 
#
# Check using the file command, etc. to see if the .asc file contains ^M character, and if so 
# convert using dos2unix


# Functions defined first, main() follows that

#####################
function determine_dataset {
#####################

	# This assumes the header files are in the same directory that the script runs from
	# If not, you an always just set script_dir to where they are by uncommenting the following line:
	# script_dir=/path/to/headers

	# Figure out if this is a 1d or 1h dataset. (Each needs a different header.)	
	setType=`ls | grep -m1 .asc`

	if [[ $setType == *_1d_* ]]
        then
        echo -e "\tThis is a 1 degree data set."
	cp $script_dir/header_1d.txt ./
        dataSet=1

	 elif  [[ $setType == *_1deg ]]
        then
        echo -e "\tThis is a 1 degree data set."
        cp $script_dir/header_1d.txt ./
        dataSet=2

	elif  [[ $setType == *_hd_* ]]
        then
        echo -e "\tThis is a half degree data set."
	cp $script_dir/header_halfd.txt ./
        dataSet=2

        elif  [[ $setType == *_hdeg ]]
        then
        echo -e "\tThis is a half data set."
	cp $script_dir/header_halfd.txt ./
        dataSet=2

	else
        echo -e "\tI don't know if these are 1 degree of half degree data sets, so I am stopping."
        exit
	fi
	}

#####################
function add_header() {
#####################	
		# Now add the header to each .asc filei
		# (Looping now in main, so loop not needed here.)
		#for f in `ls | grep .asc`
		#do echo -e "\t\tAdding header to $f"
	        echo -e "\t\tAdding header to $file"
		# add the header
		cat header*.txt $file > $file.tempfile
		mv $file.tempfile $file
		#done
	}

#################
# Main script body
#################

# Direct all std out to log file
exec > >(tee -a headers.log)
echo "Script run on: " >> headers.log 
date >> headers.log

#We set this so we know where to copy things from later, and where to return to.
script_dir=$(cd `dirname $0` && pwd)

# Check to make sure we have header files to use, if not than exit.
# (to be added.)

# Make sure our locale setting are correct
# (This is not really imperative now as we are using the find command now to locate the files and directories.)
my_LC_TIME=`locale | grep LC_TIME | cut -d= -f 2`
if [[ "$my_LC_TIME" != "en_US.UTF-8" ]]
then
echo "Note: Your LC_TIME setting is not set to en_US.UTF.8"
#echo "Your locale settings, especially LC_TIME, need to be set to en_US.UTF-8. Please correct this by esecuting: export LC_TIME=en_US.UTF-8 and then verify your setting with the locale command. (If not set correctly, the script will not be able to correctly determine filenames.)"
fi

################
# The real work:
################

# Get a list of the .zip files
for i in `ls -l | grep .zip | awk '{print $9}'`
do echo "Unzipping $i" 
unzip $i 
done

# On each unziped directory, cd to it, determine the header and continue
#for d in `ls | grep -v .zip | grep E`
for d in $(find ./ -maxdepth 1 -type d -print | grep -v ./$ | sort )
	do cd $d
	echo -e "\t\033[1;42;37mChanging directory to $d\033[0m"
			for subdir in $(find ./ -maxdepth 1 -type d -print | grep -v ./$ | sort)
			do
			cd $subdir
			echo -e "\tGoing into $subdir"
			determine_dataset
				for file in $( find ./ -name "*.asc" -print )
				do
				echo -e "\t\tFound $file"
				add_header $file
				line_count=`wc -l $file | cut -d" " -f 1` 
					if [[ line_count -ne 186 ]] 
					then
					echo -e "\t\t\033[5;1;37;41mLINE COUNT ERROR:\033[0m"
					echo -e "\t\t$file does not appear to contain the correct number of lines after adding the header."
					echo -e "\t\t(Number of lines was $line_count )"
					read -p "Continue processing (y/n)?"
	                                [ "$REPLY" != "y" ] && exit 0
					fi
				done
			rm header*.txt
			#cd $script_dir
			#echo -e "\tFinished with $d "
		        #read -p "Continue processing next subdir (y/n)?"
        		#[ "$REPLY" != "y" ] && exit 0
 			cd ../
        		done
		cd $script_dir
	done

echo -e "\033[1;42;37mAll directories processed. Results logged to headers.log\033[0m"

exit 0

