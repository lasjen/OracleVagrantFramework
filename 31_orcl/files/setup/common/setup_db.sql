connect / as sysdba
--@@directories.sql
--@@profiles.sql
--@@roles.sql
@@drop_dev_users.sql &1
@@create_dev_users.sql &1
--@@partition_enable.sql
exit
