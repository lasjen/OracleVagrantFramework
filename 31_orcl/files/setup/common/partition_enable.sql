shutdown immediate

host cd $ORACLE_HOME/rdbms/lib;make -f ins_rdbms.mk part_on;make -f ins_rdbms.mk ioracle

startup
