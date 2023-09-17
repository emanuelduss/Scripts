#!/bin/bash
########################################################################
#
# Braindump - Expand your knowledge!
# Skript um Wörterlisten zu lernen.
#
# 2010-04-06; Emanuel Duss; Erste Version
# 2010-04-08; Emanuel Duss; Keyboardeingabe, Status, Statusanzeige
# 2010-04-14; Emanuel Duss; Antworten in ein File schreiben
#
########################################################################

########################################################################
# TODO
# -------------------------------------------------------------
# Technik
# * Optionen mit 'getopt' herauslesen
# -------------------------------------------------------------
# Funktionen
# * Version (-v): Version ausgeben
# * Mehrere Files angeben
# * Random (-r): Zufallsabfrage
########################################################################

########################################################################
# Variabeln
richtig="0"
falsch="0"
unbeantwortet="0"
erledigt="0"

datum=`date +%Y-%m-%d`

########################################################################
# Funktionen
Line() {
  echo "==============================================================="
}
Version()
{
  echo "***************************************************************"
  cat << EOT
   , __                              Braindump = Knowledge ++
  /|/  \            o             |  Version: $version ($changedate)
   | __/ ,_    __,      _  _    __|          _  _  _     _
   |   \/  |  /  |  |  / |/ |  /  |  |   |  / |/ |/ |  |/ \_
   |(__/   |_/\_/|_/|_/  |  |_/\_/|_/ \_/|_/  |  |  |_/|__/
                                                      /|
   snafu@fnord:~$ dd if=/dev/knowledge of=/dev/brain  \|

EOT
  echo "***************************************************************"
}
Usage(){
  echo "Usage: $0 <filename>"
}

########################################################################
# Main
clear
Version
if [ -r "$1" ]
then
  filename="$1"
else
  echo "Datei nicht angegeben oder nicht lesbar."
  Usage
  exit
fi
echo " Lerndatei: $filename"
total=`cat $filename | wc -l`
echo " Total $total Fragen"
Line

exec 3<&1
cat $filename | sort -u -R | tr "\t" "+" | while read line
do
  eins=`echo $line | cut -d+ -f1`
  zwei=`echo $line | cut -d+ -f2`

  echo "Frage:   $eins"
  echo -n "Antwort: "
  read antwort  <&3
  case $antwort in
    $zwei)
        echo "Richtig!"
        richtig=`expr $richtig + 1`
        ;;
    "")
        echo "Antwort: $zwei"
        unbeantwortet=`expr $unbeantwortet + 1`
        ;;
    *)
        echo -e "Falsch! Die richtige Antwort ist: $zwei"
        falsch=`expr $falsch + 1`
        echo -e "$eins \t $zwei" >> `echo $filename | sed 's/\.\([^.]*\)$/.fail.'$datum'.\1/g'`
        ;;
  esac

  erledigt=`expr $richtig + $falsch + $unbeantwortet`
  erledigtprozent=`expr 100 / $total \* $erledigt`

  if [ $richtig -eq 0 ]
  then
    richtigprozent="0"
  else
    richtigprozent="`expr 100 / $erledigt \* $richtig`"
  fi
  if [ $falsch -eq 0 ]
  then
    falschprozent="0"
  else
    falschprozent="`expr 100 / $erledigt \* $falsch`"
  fi
  if [ $unbeantwortet -eq 0 ]
  then
    unbeantwortetprozent="0"
  else
    unbeantwortetprozent="`expr 100 / $erledigt \* $unbeantwortet`"
  fi
  echo 
  echo "Richtig: $richtig von $erledigt ($richtigprozent%); Falsch: $falsch von $erledigt ($falschprozent%)"
  echo "Nichts: $unbeantwortet von $erledigt ($unbeantwortetprozent%); Erledig: $erledigt von $total ($erledigtprozent%)"
  Line
done
echo "Du bist fertig!"

# EOF
