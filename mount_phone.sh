#!/bin/bash
#
# Simple iOS phone mounting script
# Created by Rafael de Oliveira Ribeiro <rafael.ribeiro@ieee.org>
# Last updated in 20170625
#
# CAVEATS:
# 1 - Mount point is _hardcoded_.
# 2 - Log file is saved on the same directory ("pwd")
# 3 - Only one Phone at a time is assumed!
#
# The script checks for an already mounted phone, so as not to do it again.
# (idempotency, anyone?).
#
# It also checks for an paired device which hasn't been mounted.
#
# MOUNTING ISSUES:
#
# fuse: mountpoint is not empty
# fuse: if you are sure this is safe, use the 'nonempty' mount option
#
# The above happens when the Phone is _already_ mounted!
#
# PAIRING ISSUES:
# If the device is not ready, the following errors may appear:
#
# ERROR: Could not validate with device <DEVICE-ID> because a passcode is set.
# Please enter the passcode on the device and retry.
#
# OR:
#
# ERROR: Please accept the trust dialog on the screen of device <DEVICE-ID>,
# then attempt to pair again.

# Variables
DATE_RUN=$(date +%F)
HOUR_RUN=$(date +%T)
FILE=`basename $0`
FILE="${FILE%%.*}"
LOG_FILE="$FILE"_"$DATE_RUN".log

# Directories and commands
PHONE_DIR="/media/iPhone" # Didn't I say it was hardcoded?
LOG_DIR=`pwd`             # Reserved for future /var/log/ destination!
PAIR_COMMAND="idevicepair pair"
MOUNT_COMMAND="ifuse $PHONE_DIR"

# Prepararing the log file.
if [ -x $LOG_FILE ]; then
  touch $LOG_FILE
fi

echo "-----------------------" >> $LOG_FILE
echo "$FILE at $HOUR_RUN" >> $LOG_FILE
echo "-----------------------" >> $LOG_FILE

# Main loop

# Checks first for the mount point. If mounted, it is also paired, as well!
if mount | grep "$PHONE_DIR" > /dev/null; then
  echo "$HOUR_RUN: Phone already mounted. Exiting" >> $LOG_FILE
  exit 0 # Exits
fi

UNLOCKED=0  # Variable to control phone screen locking mechanism

# The pairing command must be executed twice. First attempt below.
# Sending the results to a variable.
PAIR=`$PAIR_COMMAND`
echo "$HOUR_RUN: $PAIR" >> $LOG_FILE

if [ "$PAIR" == "SUCCESS*" ]; then # Checks for an already paired device.
  # Effectively mounts the device.
  MOUNT=`$MOUNT_COMMAND`
  echo "$HOUR_RUN: Phone mounted successfully. Exiting!" >> $LOG_FILE
  exit 0 # Exits
else
  while [ "$UNLOCKED" != "1" ]
  do
    input_var=''
    # Wait for user input to run again.
    while [ "$input_var" != "Y" ]
    do
      echo "Please unlock the device and accept the trust dialog. When finished, press Y"
      read input_var
    done
    # Running again
    PAIR=`$PAIR_COMMAND`
    echo "$HOUR_RUN: $PAIR" >> $LOG_FILE
    # Catching a "funny" user :)
    if [ "$PAIR" == "ERROR:*" ]  ; then
      echo "You haven't being paying attention, have you? Device locked! Try again!"
      continue
    else
      UNLOCKED=1
    fi
  done

  # Effectively mounting the device.
  MOUNT=`$MOUNT_COMMAND`
  echo "$HOUR_RUN: Phone mounted successfully. Exiting!" >> $LOG_FILE
fi
exit 0 # Exits
