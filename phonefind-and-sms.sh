#!/bin/bash
#   -----------------------------------------------------
#  | sms scripts                                         |
#  | scripts for easier use of gammu to send sms         |
#  | v0.2 - 2010-08-22   lumbric@gmail.com               |
#   -----------------------------------------------------

# Archivfile falls uebergeben...
if [ "$1" = '--archivefile' ]; then
  archivfile="$1 $2"
  shift 2
fi

# Get search pattern if not given as param...
pattern=$@
if [ -z $pattern ]; then
  echo -n "Sende SMS an:  "
  read pattern
  echo  
fi

# Write result to screen...
#echo 'Suchergebnis:'
#./phonefind.sh $pattern|tail -n1
#echo  
#echo 'Any key to continue, [CTRL] + [C] to abort...'
#read -n 1


recipient=`./phonefind.sh $pattern|tail -n1|sed -e 's/\[[0-9 :-]*\] -> //'`
./sendpersonalSMS.sh $archivfile "$recipient"


echo 
echo Press ESC to close.
while [ -z "`read -s -n1 KEY && echo $KEY|od -t x1|grep 1b`" ]; do echo nothing > /dev/null; done

