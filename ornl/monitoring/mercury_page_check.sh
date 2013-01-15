#!/bin/bash
# Script to check the status code in http headers for a designated sites.
# If status != 200, emails notification
# Pete Eby

time=`date +%F:%H:%M`

statuscode=`curl -s -I -L http://mercury.ornl.gov/clearinghouse | grep HTTP | tail -1 | awk '{print $2}'`

if [ "$statuscode" != "200" ]; then
	echo "Problem with mercury/clearinghouse detected. Sending notification email."
	echo "Problem with http://mercury.ornl.gov/clearinghouse/" > mercury_check.log
	echo "(Tomcat may need restarted on mercury-ops. This notice sent from daacadmin's cron.)" >> mercury_check.log
	echo "Status Code: " $statuscode >> mercury_check.log
	echo $time >> mercury_check.log
	cat mercury_check.log | Mail -s "Mercury Problem" you@email.com 
fi

bison_statuscode=`curl -s -I -L http://bison.ornl.gov/ | grep HTTP | tail -1 | awk '{print $2}'`
if [ "$bison_statuscode" != "200" ]; then
        echo "Problem with bison.ornl.gov detected. Sending notification email."
        echo "Problem with http://bison.ornl.gov" > bison_check.log
        echo "Web page status code does not look good. This notice sent from daacadmin's cron.)" >> bison_check.log
        echo "Status Code: " $bison_statuscode >> bison_check.log
        echo $time >> bison_check.log
        cat bison_check.log | Mail -s "Bison Problem" you@email.com 
fi

gbifsolr_statuscode=`curl -s -I -L http://nbii-gbif2.ornl.gov/gbif_solr/ | grep HTTP | tail -1 | awk '{print $2}'`
if [ "$gbifsolr_statuscode" != "200" ]; then
        echo "Problem with gbif solr dected. Sending notification email."
        echo "Problem with http://nbii-gbif2.ornl.gov/gbif_solr/" > gbifsolr_check.log
        echo "Web page status code does not look good. This notice sent from daacadmin's cron.)" >> gbifsolr_check.log
        echo "Status Code: " $bison_statuscode >> gbifsolr_check.log
        echo $time >> gbifsolr_check.log
        cat gbifsolr_check.log | Mail -s "Gbif Solr Problem" you@email.com 
fi


