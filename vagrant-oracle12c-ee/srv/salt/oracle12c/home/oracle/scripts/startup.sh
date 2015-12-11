#!/bin/bash

export TMP=/tmp
export TMPDIR=$TMP
export PATH=/usr/sbin:/usr/local/bin:$PATH

export ORACLE_SID=cdb12
ORAENV_ASK=NO
. oraenv
ORAENV_ASK=YES

if [ ! -z $1 ] && [ $1 = "UPGRADE" ]; then
STARTUP="STARTUP UPGRADE"; else
STARTUP="STARTUP"; fi

# Start Listener
lsnrctl start

# Start Database
sqlplus / as sysdba << EOF
$STARTUP;
EXIT;
EOF
