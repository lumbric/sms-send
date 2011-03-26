#!/bin/bash
#   -----------------------------------------------------
#  | sms scripts                                         |
#  | scripts for easier use of gammu to send sms         |
#  | v0.2 - 2010-08-22   lumbric@gmail.com               |
#   -----------------------------------------------------

# 2009-01-29 
# Script zum Massensms-Versand mit Gammu
# Syntax zum Aufruf ueber Aufruf mit Parameter --help

# --- Parameter ---
maxchars=600    # Maximale Laenge von SMS
delay=1         # Verzoegerung zwischen 2 versendeten SMS
list=$1         # Pfad zur Datei mit den Nummern
text=$2         # Text der per SMS versendet werden soll

# ------------------


# Bekannte Probleme:
#   - bei SMS mit mehr als $maxchars gibts vielleicht seltsame Effekte (abgeschnitten?)
#   - 


# Gib Hilfetext aus...
if [ "$1" = '--help' ] || [ "$1" = "h" ] || [ "$1" = "help" ]
then
  echo 'sendmassSMS v0.1 - 2009-01-29 PR

sendmassSMS NUMMERLISTE [TEXT]

NUMMERLISTE		Textdatei mit Liste der Emfpaenger-Nummern.

			Pro Zeile eine Nummer im Format: Name oder so [1234...]
			Alles hinter einem "#" ist Kommentar.
				
			Achtung: 0043699... geht nicht!
			es geht nur: +43699... oder 0699...
	
TEXT			Inhalt der SMS
			Wenn nicht angegeben, fragt ein Dialog nach dem Text.
'
  echo  
  exit 0
fi

# Wenn Parameter 1 keine lesbare Datei ist...
if [ ! -r "$1" ]
then
  echo "Keine gueltige Nummerndatei uebergeben."
  echo "Der erste Parameter beim Aufruf des Scripts muss der Pfad zu einer"
  echo "Textdatei sein, die Empfaengernummern enthaelt. Mehr mit '--help'."
  echo  
  exit 0
fi

# Wenn Parameter 2 leer ist, , dh. kein Text zum verschicken,
# frag nach dem Text...
if [ -z "$text" ]
then
  text=$(zenity --entry --title='Nachrichtentext eingeben' --text='Bitte Nachrichtentext eingeben:' --width=400)
  
  # fuer weiter Versionen des Scripts:
  # Vorbelegung des Wertes mit --entry-text=asdf moeglich
  # so koennte ein Template vorgeschlagen werden, das auch in der Datei mit der
  # Nummerliste steht.
  if [ -z "$text" ];then
    echo 'Texteingabe und SMS-Versand ohne Aenderungen und Versand abgebrochen.'
    echo   
    exit
  fi  
fi

echo "Versende die SMS, ${#text} Zeichen:"
echo "$text"
echo 
echo "Versende SMS an:"
egrep -o '^[^#]*' $list
echo 
echo "Any key to continue or [Ctrl] + [C] to abort."

# Lies ein Zeichen ein...
read -sn 1
echo
echo Sende SMS...


# For-Schleife ginge auch, geht aber nicht Zeilen sondern Woerter durch...
# -> fuehrt nicht zu erwuenschtem Ergebnis.
#for empfaenger in `egrep -o '^[^#]*' list`; do
#do
#	echo $empfaenger
#done


# Zum archivieren der SMS inklussive Ergebnis von gammu...
logfilename=$list$(date +%F_%H.%M.%S)

# SMS + Datum in Logfile schreiben...
echo "[$(date '+%F %H:%M:%S')]" > "$logfilename"
echo "$text" >> "$logfilename"
echo '---' >> "$logfilename"

i=1
numberofsms=$(egrep -o '^[^#]*' $list|egrep -o '\[[0-9+]*\]'|egrep -o '[0-9+]*'|wc -l)

# Gehe die Textdatei $list Zeilweise durch, wobei alles nach '#'
# entfernt wird (Kommentar) und dann leere Zeilen nicht mehr dabei sind.
# Jeweils eine solche Kommentarbereinigte Zeile steht in $empfaenger...
egrep -o '^[^#]*' $list|while read empfaenger; do
	# Finde die Nummer in [  ] und speichere nachher nur die Nummer ohne [ ]
	nummer=$(echo $empfaenger|egrep -o '\[[0-9+]*\]'|egrep -o '[0-9+]*')
	
	# Wenn die $nummer nicht leer ist nach Entfernung von ungueltigen Zeichen
	# verschicke die SMS...
	if [ ! -z "$nummer" ]; then
		echo |tee -a $logfilename
		echo "Sende an $empfaenger... (Empfaenger $i von $numberofsms)"|tee -a "$logfilename"
	
		# Damit das Handy sich nicht ueberanstrengt... ;)
		# (Und man auch eine Chance bekommt abzubrechen)
		sleep $delay
		
		senderror=0
		echo "$text"|gammu --sendsms TEXT $nummer -autolen $maxchars|tee -a "$logfilename"
		senderror=$?
				
		i=$(($i+1))
	fi

	if [ $senderror -ne 0 ]; then
		echo 
		echo 
		echo 'An error might have occured.'
		exit $senderror
	fi
done

# Exit another time because loop is subshell
exit $?

echo 
echo 
echo 'Done.'


