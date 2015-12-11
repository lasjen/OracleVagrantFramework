#!/bin/bash

export TMP=/tmp
export TMPDIR=$TMP
export PATH=/usr/sbin:/usr/local/bin:$PATH

export ORACLE_SID=cdb12
ORAENV_ASK=NO
. oraenv
ORAENV_ASK=YES

# Start Database
sqlplus / as sysdba << EOF
alter pluggable database all close immediate;
alter pluggable database all open upgrade;
EXIT;
EOF
