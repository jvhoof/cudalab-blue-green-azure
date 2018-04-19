#!/bin/bash
echo "
##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#
# Hello World
#
##############################################################################################################
"

set

echo "--> Secure file location 1: $DOWNLOADSECUREFILE1_SECUREFILEPATH"
echo "--> Secure file location 2: $DOWNLOADSECUREFILE2_SECUREFILEPATH"
echo "--> $TEST"

echo "--> $TESTENC"
echo "--> $0"
echo "--> $1"
echo "--> $2"
echo "--> $3"
echo "--> $4"
echo "--> $5"
echo "--> $6"
echo "--> $7"
echo "--> $8"

while getopts "c:d:p:s:" option; do
    case "${option}" in
        c) CCSECRET="$OPTARG" ;;
        d) DB_PASSWORD="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) SSH_KEY_DATA="$OPTARG" ;;
    esac
done

echo "--> $CCSECRET"
echo "--> $DB_PASSWORD"
echo "--> $PASSWORD"
echo "--> $SSH_KEY_DATA" > /tmp/keytest