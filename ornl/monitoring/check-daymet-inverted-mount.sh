#!/bin/bash

log=/home/daymet/inverted-check.log

touch /daymet_data/V2/inverted/mount-test

if [ $? -ne 1 ]
then   
    echo date > $log
    echo "Problem writting to /daymet_data/V2/inverted" >> $log
    cat $log | mail -s "Daymet Inverted Mount" ebypi@ornl.gov 7273650046@vtext.com
    exit 1
fi

rm /daymet_data/V2/inverted/mount-test
