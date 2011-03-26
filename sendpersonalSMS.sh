#!/bin/bash
#   -----------------------------------------------------
#  | sms scripts                                         |
#  | scripts for easier use of gammu to send sms         |
#  | v0.2 - 2010-08-22   lumbric@gmail.com               |
#   -----------------------------------------------------


# Script zum SMS-Versand mit Gammu
# Syntax zum Aufruf ueber Aufruf mit Parameter --help
#
# 2009-01-29: initiale Version
# 2010-08-05: Anpassung mit variabler Archivdatei
# 2010-08-22: Anpassungen fuer Suche nach Kontakten und Versand

# --- Parameter ---
maxchars=600    # Maximale Laenge von SMS
archivedatei='~/sent-with-gammu'  # das ist nur der Default-Wert
# ------------------

# Bekannte Probleme:
#   - bei SMS mit mehr als $maxchars gibts vielleicht seltsame Effekte (abgeschnitten?)
#   - keine Moeglichkeit bisher zum chars zaehlen waehrend dem Schreiben der SMS
# ------------------


# Gib Hilfetext aus...
if [ "$1" = '--help' ] || [ "$1" = "h" ] || [ "$1" = "help" ]
then
  echo 'sendpersonalSMS v0.2 - 2010-01-29 PR

sendpersonalSMS NUMMER [TEXT]

NUMMER		Emfpaenger-Nummer im Format: Name [0699123..]
		Achtung 0043699... geht nicht!
		es geht nur: +43699... oder 0699...	

TEXT		Inhalt der SMS
		Wenn nicht angegeben, fragt ein Dialog nach dem Text.
'
  echo  
  exit 0
fi


# Pfad zur Archivdatei wenn uebergeben... 
if [ "$1" = '--archivefile' ]; then
  archivedatei=$2
  shift 2
fi


# Wenn Parameter $nummer keine Telefonnummer ist...
empfaenger=$1
if ! (echo "$empfaenger"|egrep -q '\[[0-9+]+\]')
then
  echo "Keine gueltige Telefonnummer uebergeben."
  echo "$empfaenger ist keine gueltige Nummer."
  echo "Mehr mit '--help'."
  echo  
  exit 0
fi

echo "Versende SMS an:"

echo "$empfaenger"
echo 

# Wenn Parameter 2 leer ist, , dh. kein Text zum verschicken,
# frag nach dem Text...
text=$2 
if [ -z "$text" ]
then
  text=$(zenity --entry --title='Nachrichtentext eingeben' --text='Bitte Nachrichtentext eingeben:' --width=400)
  if [ -z "$text" ]; then
    echo 'Texteingabe und SMS-Versand abgebrochen.'
    echo 
    exit
  fi  
fi

echo "Versende die SMS, ${#text} Zeichen:"
echo "$text"
echo 
echo "Any key to continue or [Ctrl] + [C] to abort."

# Lies ein Zeichen ein...
read -s -n1
echo
echo Sende SMS...

# Zum archivieren der SMS inklussive Ergebnis von gammu...
#$(date +%F_%H.%M.%S)

# SMS + Datum in Logfile schreiben...
echo "[$(date '+%F %H:%M:%S')] -> $empfaenger" >> "$archivedatei"
echo "$text" >> "$archivedatei"
echo '------- Gammu-Result -------' >> "$archivedatei"


nummer=$(echo "$empfaenger"|egrep -o '\[[0-9+]+\]'|egrep -o '[0-9+]+')
	
# Verschicke die SMS...
echo
echo "$text"|gammu --sendsms TEXT $nummer -autolen $maxchars|tee -a "$archivedatei"

senderror=$?

echo '----------------------------' >> "$archivedatei"
echo >> "$archivedatei"
echo >> "$archivedatei"


echo 
echo
echo
if [ $senderror -eq 0 ]; then
	echo 'Done.'
else
	echo 'An error might have occured.'
fi

