#!/bin/sh
HOST=<your ftp host>
USER=<username>
PASSWD=<password>

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
binary
cd files
put $1
quit
END_SCRIPT
