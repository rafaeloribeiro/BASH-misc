#!/bin/bash
#
# Simple iOS phone unmounting script
# Created by Rafael de Oliveira Ribeiro <rafael.ribeiro@ieee.org>
# Last updated in 20170625
#
# CAVEATS:
# 1 - Mount point is _hardcoded_.
# 2 - Log file is saved on the same directory ("pwd")

# Variables
DATE_RUN=$(date +%F)
HOUR_RUN=$(date +%T)
FILE=`basename $0`
FILE="${FILE%%.*}"
LOG_FILE="$FILE"_"$DATE_RUN".log

# Directories and commands
PHONE_DIR="/media/iPhone" # Didn't I say it was hardcoded?
LOG_DIR=`pwd`             # Reserved for future /var/log/ destination!
UMOUNT_COMMAND="fusermount -u $PHONE_DIR"

# Prepararing the log file.
if [ -x $LOG_FILE ]; then
 touch $LOG_FILE
fi

echo "-------------------------" >> $LOG_FILE
echo "$FILE at $HOUR_RUN" >> $LOG_FILE
echo "-------------------------" >> $LOG_FILE

# Unmounting!
UMOUNT=`$UMOUNT_COMMAND`
echo "$HOUR_RUN: Phone unmounted successfully. Exiting!" >> $LOG_FILE
exit 0 # Exits
