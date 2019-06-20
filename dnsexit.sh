#!/bin/bash

MYIP="None"
INTERVAL=300
USERNAME=my_username
PASSWORD=my_password
HOST=my_host
COOKIE_FILE=/tmp/dnsexit.7c57ed0a928e11e9929b1794293d656c.cookie
LOG_FILE=/tmp/dnsexit.ea0894c6928e11e99c914b29ee896236.log

function updateIP() {
    RESULT=$(curl --connect-timeout 8 -b ${COOKIE_FILE} -s "http://update.dnsexit.com/RemoteUpdate.sv?login=${USERNAME}&password=${PASSWORD}&host=${HOST}&myip=${MYIP}&force=Y")
    RESULT=$(echo $RESULT)
    echo $RESULT;
    if [[ "$RESULT" == *"HTTP/1.1 200 OK"* ]]
    then
        echo "current ip: $IP "
        MYIP=${IP}
    fi
}

function checkIP() {
    IP=$(curl --connect-timeout 8 -s "http://ip.dnsexit.com/")
    #IP=$(curl --connect-timeout 8 -s "http://ip2.dnsexit.com/")
    #IP=$(curl --connect-timeout 8 -s "http://ip3.dnsexit.com/")
    IP=$(echo $IP)

    #check ip
    #VALID_CHECK1=$(echo $IP|awk -F. '$1<=255&&$2<=255&&$3<=255&&$4<=255{print "yes"}')
    #VALID_CHECK2=$(echo $IP|grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
    echo "test ip: $IP"
    if [[ -z $IP ]]; then return; fi

    if [ "$IP" != "$MYIP" ]; then
        echo "IP has changed from '$MYIP' to '$IP'";
        updateIP $IP
    else
        echo "IP is still '$MYIP'";
    fi
    echo "Waiting ${INTERVAL}..."
    sleep ${INTERVAL}
}

function login() {
    test -f ${COOKIE_FILE} && return

    RESULT=$(curl --connect-timeout 8 -c ${COOKIE_FILE} -s "http://update.dnsexit.com/ipupdate/account_validate.jsp?login=${USERNAME}&password=${PASSWORD}&version=2.000")
    RESULT=$(echo $RESULT)
    if [[ "$RESULT" == *"0=OK"* ]]
    then
       echo "login successful."
    else
       echo "login failed : ${RESULT}";
       exit
    fi
    echo $RESULT;
}

login;
while true; do
    checkIP;
done;

