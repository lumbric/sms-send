#!/bin/bash
#   -----------------------------------------------------
#  | sms scripts                                         |
#  | scripts for easier use of gammu to send sms         |
#  | v0.2 - 2010-08-22   lumbric@gmail.com               |
#   -----------------------------------------------------


pattern=$@
grep -iEho "$pattern.*\[.*\]" /data/doc/handy/W302-SMS-Archiv/massen-sms/aussendungs-archiv/*
grep -iEho "$pattern.*\[.*\]" /data/doc/handy/W302-SMS-Archiv/massen-sms/*
grep -iE "$pattern.*\[.*\]" /data/doc/handy/W302-SMS-Archiv/sent-with-gammu-iskra
grep -iE "$pattern.*\[.*\]" /data/doc/handy/W302-SMS-Archiv/sent-with-gammu-antares
