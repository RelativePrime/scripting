#!/bin/bash 

# Script to automatically start xflux 
# http://stereopsis.com/flux/

# Place in /home/$USER/.kde4/Autostart to automatically start xflux on user login.

# Usage: /usr/local/bin/xflux [-z zipcode | -l latitude] [-g longitude] [-k colortemp (default 3400)] [-nofork]
# protip: Say where you are (use -z or -l).


instance=`pidof xflux`
if [ -z $instance ]
then
/usr/local/bin/xflux -z 37931
else
echo "xflux is already running with pid $instance."
fi
