-- TEMP Tablespace

DROP TABLESPACE TEMP INCLUDING CONTENTS AND DATAFILES;

CREATE TEMPORARY TABLESPACE TEMP TEMPFILE 
  '/u01/app/oracle/oradata/cdb12/temp_01.dbf' SIZE 5M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

alter database default temporary tablespace TEMP;

--DROP TABLESPACE TEMP2 INCLUDING CONTENTS AND DATAFILES;
-- The above line would require a second bounce of the database. The tablespace is small, we let it live

exit
