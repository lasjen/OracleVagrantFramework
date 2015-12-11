#!/bin/bash

export TMP=/tmp
export TMPDIR=$TMP
export PATH=/usr/sbin:/usr/local/bin:$PATH

export ORACLE_SID=cdb12 
ORAENV_ASK=NO
. oraenv
ORAENV_ASK=YES

# Stop Database
sqlplus / as sysdba << EOF
SHUTDOWN IMMEDIATE;
EXIT;
EOF

# Stop Listener
lsnrctl stop
