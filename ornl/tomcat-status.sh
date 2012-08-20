#!/bin/bash
# Grep for multiple instances of Tomcat and display environmental info from /proc for each
# tr '\0' '\n' < /proc/<pid>/environ or ps eww -p <pid> are handy to parse

#for i in $(ps aux | grep '[t]omcat' | awk '{print $2}')
echo "Found running instances of Tomcat configured as:" 
for i in $(ps -eo pid,command | grep "/usr/share/[t]omcat" | awk '{print $1}')
do
	instance=$(tr /'\0/' /'\n/' < /proc/$i/environ | grep CATALINA_BASE | cut -d "=" -f 2)
	java_opts=$(tr /'\0/' /'\n/' < /proc/$i/environ | grep JAVA_OPTS)
	echo
	echo
	echo -en "\033[32mProcess:\033[0m $i       \033[32mOpen Files:\033[0m `lsof -p $i | wc -l`       \033[32mFile Descriptors in proc:\033[0m `ls /proc/$i/fd | wc -l`"
	echo -en "\n\033[32mCatalina Base: \033[0m $instance"
	echo -en "\n\033[32mJava Options: \033[0m $java_opts"
done
echo
echo
echo "The current file descriptor limit Tomcat is running with is set in"
echo "catalina.sh and displayed when Tomcat is started. The hard limit is set in "
echo "/etc/security/limits.conf"
echo

