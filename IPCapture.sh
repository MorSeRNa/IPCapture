#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

clear
if [ $(id -u) != "0" ]; then
   echo -e "\n$redColour You must be root to run this program $endColour\n"
   exit
else
echo -e "$greenColour Let's see what programs you have installed and which ones are missing... \n$endColour"
sleep 3
if [ ! -x /usr/bin/tshark ];then
    echo -e "\n$redColour TShark$endColour$yellowColour: Not installed \n$endColour "
    echo -e -n "$greenColour'TShark' will be installed on your computer, do you want to continue?$endColour $blueColour(Yes/No):$endColour"
    read respuestaA

     case $respuestaA in

       Yes | yes | Y | y ) echo " "
            echo -e "$greenColour Starting the installation...$endColour"
            echo " "
            sleep 2
            sudo apt-get install tshark
            echo " "
            echo -e "$blueColour Installation Finished!$endColour"
            echo " "
            echo -e "$redColour Press <Enter> to continue$endColour"
            read
            ;;

       No | n | no | No ) echo " "
            echo -e "$redColour Canceled 'tshark' installation...\n\n$endColour"
            sleep 1
            echo -e "$redColour Closing IPCapture...$endColour"
            sleep 3
            clear
            exit
            ;;
     esac
else
  echo -e "$blueColour Tshark$endColour$yellowColour: Installed \n\n$endColour"
  sleep 2
fi
  echo -e $greenColour" Buscando interfaces de red..\n$endColour"
  sleep 1
  for i in $( ls /sys/class/net ); do
   echo -e $yellowColour" "$i$endColour"\n"
  done
  echo -e -n $greenColour" Selecciona tu interfaz (enp0s25, wlan0 ...):  $endColour"
  read Interfaz
  clear
  echo -e $greenColour" Opening TShark on $Interfaz..\n$endColour"
  sleep 2
  gnome-terminal -x bash -c "tshark -i $Interfaz -f udp > UDPCapture.txt"
  echo -e $redColour" ...Getting UDP packages...$endColour\n"
  while true
  do
    if [ $(cat UDPCapture.txt | tail -n1 | grep -c UDP) == "1" ]; then
      if [ $(hostname -I) != $(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 2 | cut -d "U" -f 1 | tr -d '[[:space:]]') ]; then
        if [ "$ipstranger" != "$(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 2 | cut -d "U" -f 1 | tr -d '[[:space:]]')" ]; then
          echo -e "$blueColour STRANGER IP - $endColour"$yellowColour $(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 2 | cut -d "U" -f 1 | tr -d '[[:space:]]') $endColour;
          ipstranger=$(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 2 | cut -d "U" -f 1 | tr -d '[[:space:]]')
        fi
      else
        if [ "$ipstranger1" != "$(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 1 | cut -d "-" -f 1 | sed 's/^ //g' | sed 's/  / /g' | cut -d " " -f 3 | sed  's/[ \t]*$//')" ]; then
          echo -e "$blueColour STRANGER IP - $endColour"$yellowColour $(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 1 | cut -d "-" -f 1 | sed 's/^ //g' | sed 's/  / /g' | cut -d " " -f 3 | sed  's/[ \t]*$//')$endColour;
          ipstranger1=$(cat UDPCapture.txt | tail -n1 | cut -d ">" -f 1 | cut -d "-" -f 1 | sed 's/^ //g' | sed 's/  / /g' | cut -d " " -f 3 | sed  's/[ \t]*$//')
        fi
      fi
    fi
  sleep 0.25
  done
fi
