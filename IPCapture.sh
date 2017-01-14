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
sleep 2
if [ ! -x /usr/bin/tshark ];then
    echo -e "\n$redColour TShark$endColour$yellowColour: Not installed \n$endColour "
    sleep 1
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
  echo -e "$blueColour Tshark$endColour$yellowColour: Installed $endColour"
fi
if [ ! -x /usr/bin/geoiplookup ];then
    echo -e "\n$redColour geoip-bin$endColour$yellowColour: Not installed \n$endColour "
    sleep 1
    echo -e -n "$greenColour'geoip-bin' will be installed on your computer, do you want to continue?$endColour $blueColour(Yes/No):$endColour"
    read respuestaA

     case $respuestaA in

       Yes | yes | Y | y ) echo " "
            echo -e "$greenColour Starting the installation...$endColour"
            echo " "
            sleep 2
            sudo apt-get install geoip-bin
            echo " "
            echo -e "$blueColour Installation Finished!$endColour"
            echo " "
            echo -e "$redColour Press <Enter> to continue$endColour"
            read
            ;;

       No | n | no | No ) echo " "
            echo -e "$redColour Canceled 'geoip-bin' installation...\n\n$endColour"
            sleep 1
            echo -e "$redColour Closing IPCapture...$endColour"
            sleep 3
            clear
            exit
            ;;
     esac
else
  echo -e "$blueColour geoip-bin$endColour$yellowColour: Installed \n\n$endColour"
  sleep 2
fi
  echo -e $greenColour" Looking for network interfaces\n$endColour"
  sleep 1
  for i in $( ls /sys/class/net ); do
   echo -e $yellowColour" "$i$endColour"\n"
  done
  echo -e -n $greenColour" Select your interface (enp0s25, wlan0 ...):  $endColour"
  read Interfaz
  clear
  echo -e $greenColour" Opening TShark on $Interfaz..\n$endColour"
  sleep 2
  echo -e $purpleColour
  tshark -i $Interfaz -f udp > UDPCapture.txt &
  echo -e $endColour
  sleep 3
  clear
  echo -e $turquoiseColour" ...Capturing IP from UDP packages...$endColour\n"
  while true
  do
      if [ $(cat UDPCapture.txt | tail -n1 | grep -c UDP) == "1" ]; then # check that it is a UDP packet
      if [ $(cat UDPCapture.txt | tail -n1 | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort | head -n1) == $(hostname -I) ]; then # compare the ip with ours
        ipstranger1=$(cat UDPCapture.txt | tail -n1 | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort | tail -n1); # use the other ip
      else
        ipstranger1=$(cat UDPCapture.txt | tail -n1 | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort | head -n1); # use this ip
      fi

      if [ "$ipstranger1" != "$ipstranger" ]; then # his conditional prevents the repetitive ip.
        if [ $(cat UDPCapture.txt | tail -n1 | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort | head -n1) == $(hostname -I) ]; then # same conditional
          ipstranger=$(cat UDPCapture.txt | tail -n1 | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort | tail -n1);
          if [ "$ipstranger" != "" ]; then
            citystranger="- $(curl -s ipinfo.io/$ipstranger | grep city | cut -d ":" -f 2 | sed 's/"//g' | sed 's/,//g')";
            regionstranger="- $(curl -s ipinfo.io/$ipstranger | grep region | cut -d ":" -f 2 | sed 's/"//g' | sed 's/,//g')";
            postalstranger="- $(curl -s ipinfo.io/$ipstranger | grep postal | cut -d ":" -f 2 | sed 's/"//g' | sed 's/ //g')";
            orgstranger="- $(curl -s ipinfo.io/$ipstranger | grep org | cut -d ":" -f 2 | sed 's/"//g' | sed 's/,//g')";
            if [ "$citystranger" = "- " ]; then # avoid empty city
              citystranger=""
            fi
            if [ "$postalstranger" == "- " ]; then #  avoid empty postal code
              postalstranger=""
            fi
            if [ "$orgstranger" == "- " ]; then #  avoid empty org
              orgstranger=""
            fi
            if [ "$regionstranger" == "- " ]; then #  avoid empty org
              regionstranger=""
            fi
            if [ "$regionstranger" == "$citystranger" ]; then #  avoid empty org
              regionstranger=""
            fi
            echo -e "Packets -$blueColour IP: $endColour"$yellowColour $ipstranger $endColour - $turquoiseColour$(geoiplookup $ipstranger | head -n1 | cut -d ":" -f 2 | cut -d "," -f 2 | sed 's/ //g') $regionstranger $citystranger $postalstranger $orgstranger $endColour;
          fi
        else
          ipstranger=$(cat UDPCapture.txt | tail -n1 | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"|sort | head -n1);
          if [ "$ipstranger" != "" ]; then
            citystranger="- $(curl -s ipinfo.io/$ipstranger | grep city | cut -d ":" -f 2 | sed 's/"//g' | sed 's/,//g')";
            regionstranger="- $(curl -s ipinfo.io/$ipstranger | grep region | cut -d ":" -f 2 | sed 's/"//g' | sed 's/,//g')";

            postalstranger="- $(curl -s ipinfo.io/$ipstranger | grep postal | cut -d ":" -f 2 | sed 's/"//g' | sed 's/ //g')";
            orgstranger="- $(curl -s ipinfo.io/$ipstranger | grep org | cut -d ":" -f 2 | sed 's/"//g' | sed 's/,//g')";
            if [ "$citystranger" = "- " ]; then # avoid empty city
              citystranger=""
            fi
            if [ "$postalstranger" == "- " ]; then #  avoid empty postal code
              postalstranger=""
            fi
            if [ "$orgstranger" == "- " ]; then #  avoid empty org
              orgstranger=""
            fi
            if [ "$regionstranger" == "- " ]; then #  avoid empty org
              regionstranger=""
            fi
            if [ "$regionstranger" == "$citystranger" ]; then #  avoid empty org
              regionstranger=""
            fi
            echo -e "Packets -$blueColour IP: $endColour"$yellowColour $ipstranger $endColour - $turquoiseColour$(geoiplookup $ipstranger | head -n1 | cut -d ":" -f 2 | cut -d "," -f 2 | sed 's/ //g') $regionstranger $citystranger $postalstranger $orgstranger $endColour;
          fi
        fi
      fi
    fi
  sleep 1
  done
fi
