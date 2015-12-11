#!/bin/ksh

cd /vagrant/files/DBdumps/

echo ""
echo "`date`: Import Schema"
echo ""

sqlplus /nolog <<EOT
connect / as sysdba
create or replace directory dpdump_exports as '/vagrant/files/DBdumps/';
grant read, write on directory dpdump_exports to system;
exit
EOT

echo "gunzip dumpfile..."
gunzip -c dpump_data.dmp.gz > /u02/export/dpump_data.dmp

echo "importing objects ..."
impdp USERID="'/ as sysdba'" \
DIRECTORY=dpdump_exports \
DUMPFILE=dpump_data.dmp \
LOGFILE=dpump_imp.log \
EXCLUDE=MATERIALIZED_VIEW \
EXCLUDE=USER, PROCOBJ \
EXCLUDE=PACKAGE_BODY:\"=\'LJ_GRANT\'\" \
EXCLUDE=PACKAGE:\"=\'LJ_GRANT\'\" \
TABLE_EXISTS_ACTION=APPEND

echo "Disable FK constraints ..."
sqlplus ljdata/lj @/vagrant/files/setup/common/create_fk_scripts.sql
mv /tmp/tmp_fk_*able.sql /u02/export/.

sqlplus /nolog <<EOT
conn pwhdata/pwh
@/u02/export/tmp_fk_disable.sql
exit
EOT

echo "gunzip dumpfile..."
if [[ $VAGRANT_FULL_DUMP -eq 1 || $VAGRANT_FULL_DUMP -eq 2 ]]; then
   DUMP_NAME=DATA_MASKED;
elif [[ $VAGRANT_FULL_DUMP -eq 3 || $VAGRANT_FULL_DUMP -eq 4 ]]; then
   DUMP_NAME=DATA;
else
   DUMP_NAME=META;
fi

gunzip -c dpump_PWH_${DUMP_NAME}.dmp.gz > /u02/pwh/export/dpump_PWH_DATA.dmp

echo "importing PWH base data ..."
impdp USERID="'/ as sysdba'" \
      DIRECTORY=dump \
      DUMPFILE=dpump_PWH_DATA.dmp \
      LOGFILE=dpump_imp_PWH_DATA.log \
      CONTENT=DATA_ONLY \
      TABLE_EXISTS_ACTION=APPEND


if [[ $VAGRANT_FULL_DUMP -eq 2 || $VAGRANT_FULL_DUMP -eq 4 ]]; then
   if [[ $VAGRANT_FULL_DUMP -eq 2 ]]; then
      DUMP_NAME=AUT_MASKED;
   else
      DUMP_NAME=AUT;
   fi

   echo "gunzip AUT dump file ..."
   gunzip -c dpump_PWH_${DUMP_NAME}.dmp.gz > /u02/pwh/export/dpump_PWH_AUT.dmp 
   
   echo "Importing PWH V_AUT data ..."
   impdp USERID="'/ as sysdba'" \
         DIRECTORY=dump \
         DUMPFILE=dpump_PWH_AUT.dmp \
         LOGFILE=dpump_imp_PWH_AUT.log \
         CONTENT=DATA_ONLY \
         TABLE_EXISTS_ACTION=APPEND
fi

echo "Enabling FK constraints ..."
sqlplus /nolog <<EOT
conn pwhdata/pwh
@/u02/pwh/export/tmp_fk_enable.sql
exit
EOT

echo "Deleting files ..."
rm /u02/pwh/export/dpump_PWH.dmp
rm /u02/pwh/export/dpump_PWH_DATA.dmp
if [[ -f /u02/pwh/export/dpump_PWH_AUT.dmp ]]; then
   rm /u02/pwh/export/dpump_PWH_AUT.dmp 
fi   
rm /u02/pwh/export/tmp_fk_*able.sql

echo ""
echo "`date`: Import completed for PWHDATA Schema"
echo ""

exit
/
