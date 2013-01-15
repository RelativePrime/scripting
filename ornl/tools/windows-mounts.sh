#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if  [[ $# -lt 1  ]]
then
    echo "Script to mount SMB shares on mercury-ops, mercury1, and mercury3."
    echo "usage: $0 uid"
    echo "where: "
    echo "      uid is a ucams id with permission to mount. "
    exit 1
fi


USER=$1
echo "/nMounting as: $1/n"
echo "You will be asked to authenticate once for each mount /n"

# add --verbose for debug
mount.cifs //mercury-ops/C$ /smb/mercury-ops-C/ -o username=$USER,ro
mount.cifs //mercury-ops/D$ /smb/mercury-ops-D/ -o username=$USER,ro
mount.cifs //mercury-ops/F$ /smb/mercury-ops-F/ -o username=$USER,ro

mount.cifs //mercury1/D$ /smb/mercury1-D/ -o username=$USER,ro

mount.cifs //mercury3/C$ /smb/mercury3-C/ -o username=$USER,ro
mount.cifs //mercury3/D$ /smb/mercury3-D/ -o username=$USER,ro

mount.cifs //mercury-dev/E$ /smb/mercury-dev-E -o username=$USER,ro
