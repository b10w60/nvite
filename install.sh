#!/bin/bash

# nVITE Installer

build=1002

# ######################################################################################

# setting variables that are used

# main funtion starts here
function main {
	# checking if run by root
	if [[ $EUID -ne 0 ]]; then
		echo "ABBRUCH: Dieses Programm muss als root ausgeführt werden!" 2>&1
		exit 1
	fi

# get my stuff together
if [ ! -f nvite.sh ]; then
	echo "ABBRUCH: nvite.sh nicht gefunden!"
	exit 1
fi

# lets go
echo "Installiere nvite.sh..."
read -p "Soll eine neue Filterdatei angelegt werden (J/n)" -n 1 choice
echo
case "$choice" in
 n|N) createfilter=0;;
 y|Y|j|J) createfilter=1;;
 *) exit;;
esac

# Filterdatei anlegen
if [ $createfilter -eq 1 ]; then
	mkdir -p /var/opt/nvite
	filterfile="/var/opt/nvite/filter.nvite"
	echo "# Eine IP pro Zeile. Auskommentieren möglich. Beispiele:" > $filterfile
	echo "127.0.0.1" >> $filterfile
	echo "#192.168.1.1" >> $filterfile
	echo " ] Filterdatei angelegt"
fi
	# nvite.sh skript nach /bin bringen
	cp nvite.sh /tmp
	mv /tmp/nvite.sh /tmp/nvite
	mv /tmp/nvite /bin
	chown root:root /bin/nvite
	echo " ] Installation abgeschlossen. Programm nun über 'nvite' aufrufbar."
}

main
