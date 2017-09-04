#!/bin/bash

# Move PXE-boot file to prevent client from getting stuck in PXE-boot-loop
# Called from postrun in Clonezilla (defined in the file we want to move)

if test "$2" = ""
then
    echo Usage: $0 IP-code IP
    exit
fi

# Directory for all netboot related files and scripts
NETBOOT_PATH="$HOME/offpc/netboot"

# Path to where the PXE-booting machine expects boot files to be
PXELINUX_PATH="${NETBOOT_PATH}/pxe/pxelinux.cfg"

# Place to put boot files when done
DONE_PATH="${NETBOOT_PATH}/done"

# Place to put done-distributing messages when done
DONE_DIST_PATH="${DONE_PATH}/dist"

# File to move
IPCODE="$1"
# what IP?
IP=$2

# Create DONE-directory if not existing already
mkdir -p "$DONE_PATH"

# Create DONE_DIST-directory if not existing already
mkdir -p "$DONE_DIST_PATH"

# Actually move file!
mv -f "$PXELINUX_PATH"/"$IPCODE" "$DONE_PATH"/"$IPCODE"

# 'Send' done-distributing message
filenameAndContent=`date "+%s_%F_%T"`_$IP
echo ${filenameAndContent} > "${DONE_DIST_PATH}"/"${filenameAndContent}"
