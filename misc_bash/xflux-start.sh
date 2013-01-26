#!/bin/bash 

# Script to automatically start xflux 
# http://stereopsis.com/flux/
# wget http://secure.herf.org/flux/xflux.tgz

# To have it start automatically on user login:
# KDE: Place binary or this script in /home/$USER/.kde4/Autostart
# Gnome / Ubuntu: Run gnome-session-properties in terminal and add xflux (or this script) to the startup program list
# See: http://askubuntu.com/questions/48321/how-to-start-applications-at-startup-automatically
# Other: Create a symlink to the binary, or place it in your environments startup folder, etc. 

# Usage: /usr/local/bin/xflux [-z zipcode | -l latitude] [-g longitude] [-k colortemp (default 3400)] [-nofork]
# protip: Say where you are (use -z or -l).

instance=`pidof xflux`
if [ -z $instance ]
then
/usr/local/bin/xflux -z yourZipCode 
else
echo "xflux is already running with pid $instance."
echo "You may kill it with: kill $instance or pkill xflux"
fi
