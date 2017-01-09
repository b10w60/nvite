#!/bin/bash

# nVITE

build=1002

# ######################################################################################

# setting variables that are used
inputfile=$1
outputfile=$2
#filterfile="/etc/alp/alpfilter.alp"
filterfile="/var/opt/nvite/filter.nvite"
usefilter=1

# main function starts here
function main {
	logo	# drawing nVITE-Logo
	checkinputfile	# ensure that the...
	checkoutputfile	# ...needed files...
	checkfilterfile	# ...are in place.

	echo "[$inputfile] => [$outputfile]"
	echo -n "Arbeite..."
	touch $outputfile
	echo "IP,DATE,REQUEST,CODE,RESPONSE,AGENT" > $outputfile

	# start with reading a line from the inputfile
	while read p; do
		# prevent a *wildcard from putting rubbish into the output
		set -f

		# using Alex sed, thanks for that buddy
		string=$(echo $p | sed -r 's/( - - \[|\] "|" |" "|")/,/g')

		# seperating fields from the string and putting them into an array
		IFS=',' read -r -a  output <<< $string

		# seperating the IP field and apply filter
		filter=0
		ip=${output[0]}
		if [ $usefilter -eq 1 ];then filter $ip; fi
	        if [ $filter -eq 1 ]; then continue; fi

		# seperatly extracting the html code from the initial line
		code=$(echo $p | grep -oE " [0-9]{3} ")

		# putting it all into the outputfile
		echo "$ip,${output[1]},${output[2]},$code,${output[4]},${output[5]}" >> $outputfile
	done < $inputfile

	# Work is done
	echo "fertig!"
}
# main function ends here

# ######################################################################################

# all essential functions are listet below

function logo {
	echo "    ▄ ▄ ▄ ▄▄▄ ▄▄"
	echo "█▀▄ █ █ █ ▀█▀ █▀"
	echo "▀ ▀  ▀  ▀  ▀  ▀▀"

}

function filter {
        while read n; do
                if [ "$n" == "$1" ]; then
                        filter=1
                        return
                else
                        filter=0
                fi
        done < $filterfile
}

function checkinputfile {
	if [ -v $inputfile ]; then
		echo "Keine Eingabedatei angegeben. nvite.sh -h fuer weitere Infos."
		exit 1
	fi
	if [ ! -f $inputfile ]; then
		echo "Eingabedatei $n nicht gefunden. nvite.sh -h fuer weitere Infos."
		exit 1
	fi

}

function checkoutputfile {
	if [ -v $outputfile ]; then
		outputfile="accesslog-$(date +%F-%H-%M).csv"
	fi
	c=1
	while [ -f $outputfile ]; do
		c=$(( $c + 1 ))
		outputfile="accesslog-$(date +%F-%H-%M)-$c.csv"
	done
}

function checkfilterfile {
	if [ ! -f $filterfile ]; then
		echo "HINWEIS: keine Filterdatei gefunden. Bearbeitung erfolgt ungefiltert!"
		usefilter=0
		return
	fi
}

function howto {
	logo
	echo "Macht aus einem apache2-Accesslog eine bequemer lesbare .csv, welche in einem Tabellenprogramm wie Libre Office angezeigt werden kann. Die Datei wird im Arbeitsverzeichnis abgelegt."
	echo "Aufruf: nvite.sh [-option] ODER [Eingabedatei] [Ausgabedatei]"
	echo
	echo -e "[-f|-filter]\t Zeigt Speicherort und Inhalt der Filterdatei."
	echo -e "[-h|-hilfe]\t Zeigt diese Hilfeseite an."
	echo -e "[Eingabedatei]\t Name des zu verarbeitenden access-log."
	echo -e "[Ausgabedatei]\t Name der .csv-Datei, die erzeugt wird. Als Trenner wird ein Komma (,) verwendet. Als Texttrenner doppelte Anfuehrungsstriche (\"). Wenn kein Name angegeben wird, lautet er accesslog-$(date +%F-%H-%M).csv"
	echo
	echo "Die IP-Adressen, welche in der Filterdatei angegeben sind, werden nicht in die Ausgabedatei geschrieben. Die Datei kann mit einem Editor bearbeitet werden."
	echo
}

function filterinfo {
	logo
	echo "Speicherort der Filterdatei: $filterfile"
	echo "Inhalt der Filterdatei >>>"
	cat $filterfile
	echo "<<< Ende"
	echo
}

# end of the function area

# ######################################################################################

# programm starts here, collecting options and params

case "$1" in
	-h|-help)	howto;;		# tells something about itself
	-f|-filter)	filterinfo;;	# show the contend of the filter file
	*) main
esac

# clean exit
exit 0
