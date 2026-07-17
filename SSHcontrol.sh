#!/bin/bash

# ANSI Color Codes for CLI Design

CYAN='\e[1;36m'
GREEN='\e[1;32m'
RED='\e[1;31m'
WHITE='\e[1;37m'
YELLOW='\e[1;33m'
RESET='\e[0m'

#configure the API_TOKEN
API_TOKEN="YOUR API TOKEN"
#configure the CHAT_ID
CHAT_ID="YOUR CHAT ID"

#the path for the whitelist ips
WHITELIST_IPS="/home/pc/whitel.txt"



if [ -f /tmp/sshcontrol.pid ] && kill -0 $(cat /tmp/sshcontrol.pid) 2>/dev/null
then
    PID=$(cat /tmp/sshcontrol.pid)
    STATUS="running"
else
    STATUS="stopped"
fi

draw_header() {
    clear
    echo -e "${CYAN}"
    echo "   ███████╗███████╗██╗  ██╗ ██████╗  ██████╗ ███╗   ██╗████████╗██████╗  ██████╗ ██╗"
    echo "   ██╔════╝██╔════╝██║  ██║██╔════╝ ██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔═══██╗██║"
    echo "   ███████╗███████╗███████║██║      ██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║   ██║██║"
    echo "   ╚════██║╚════██║██╔══██║██║      ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║   ██║██║"
    echo "   ███████║███████║██║  ██║╚██████╗ ╚██████╔╝██║ ╚████║   ██║   ██║  ██║╚██████╔╝███████╗"
    echo "   ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${RESET}"

    echo -e "${WHITE}==================================================================================${RESET}"
    if [ "$STATUS" == "running" ]; then
        echo -e "  System Status: [${GREEN} ACTIVE (PID: $PID) ${RESET}]"
    else
        echo -e "  System Status: [${RED} STOPPED ${RESET}]"
    fi
    echo -e "${WHITE}==================================================================================${RESET}"
    echo ""
}


if [[ -z "$API_TOKEN" || -z "$CHAT_ID" ]]
then
         echo "Please Enter The Required Infos..."
         sleep 1.5
         exit 10
fi

echo " Welcome in SSHcontrol "
echo " Preparing the Materials ..."
sleep 1
 draw_header

okay=0
if [ "$STATUS" == "stopped" ]
then
    echo " Choose an option "
    while [[ "$okay" -eq 0 ]]
    do
        echo " [1] Start SSH Analyzing"
        echo " [2] See The Report "
        read OPTION
        if [[ "$OPTION" -eq 1 || "$OPTION" -eq 2 ]]
        then
            okay=1
    else 
	    echo " Please Enter a correct option :"
	    sleep 1
        fi
    done

    case "$OPTION" in
        1)
       echo "Starting the Script .."
      sleep 1
     (tail -f /var/log/auth.log 2> /dev/null || tail -f /var/log/secure) | grep --line-buffered -E "Failed password|Accepted password" | while read -r LINE
           do
                    IP=$(echo "$LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
                  if [ -n "$IP" ]
                  then
                if grep -qx "$IP" "$WHITELIST_IPS" 2>/dev/null
                then
                    :
                else
   curl -s -X POST "https://api.telegram.org/bot$API_TOKEN/sendMessage" \
           --data "chat_id=$CHAT_ID"\
           --data-urlencode "text= UNAUTORIZED LOGIN from $IP" > /dev/null
            fi
         fi
            done &
            echo $! > /tmp/sshcontrol.pid ;;
        2)
                     echo " Preparing The Report..."
                    sleep 1
		    TEMP="tempo.txt"
		    > $TEMP
                    ([ -f /var/log/auth.log ] && cat /var/log/auth.log || cat /var/log/secure) 2> /dev/null |\
                     grep -E "Failed password|Accepted password" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' |\
                     while read -r IP
                     do
                         if grep -qx "$IP" "$WHITELIST_IPS" 2> /dev/null
                         then :
                         else
                                 echo "$IP" >> "$TEMP"
                         fi
                 done
                 sort "$TEMP" | uniq -c | sort -nr > "$(date +%Y-%m-%d)_report.txt"
		 echo "Done ! , check the file in "$(date +%Y-%m-%d)_report.txt""
		 rm -f "$TEMP"
                    ;;
    esac
else

    okay2=0
    echo " Choose an option "
    while [[ "$okay2" -eq 0 ]]
    do
        echo " [1] Stop SSH Analyzing"
        echo " [2] See The Report "
        read OPTION2
        if [[ "$OPTION2" -eq 1 || "$OPTION2" -eq 2 ]]
        then
            okay2=1
        fi
    done
    case "$OPTION2" in
        1)
            echo "Stopping the Script .."
            sleep 1
            kill $PID
            rm -f /tmp/sshcontrol.pid ;;
        2)
                    echo " Preparing The Report..."
                    sleep 1
		    TEMP="temp.txt"
		    > $TEMP
                    ([ -f /var/log/auth.log ] && cat /var/log/auth.log || cat /var/log/secure) |\
                     grep -E "Failed password|Accepted password" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' |\
		     while read -r IP
		     do 
			 if grep -qx "$IP" "$WHITELIST_IPS" 2> /dev/null
			 then :
			 else 
				 echo "$IP" >> "$TEMP"
			 fi
		 done
		 sort "$TEMP" | uniq -c | sort -nr > "$(date +%Y-%m-%d)_report.txt"
		 echo "Done ! , check the file in "$(date +%Y-%m-%d)_report.txt""
		 rm -f "$TEMP"
		    ;;
               
esac
fi 


