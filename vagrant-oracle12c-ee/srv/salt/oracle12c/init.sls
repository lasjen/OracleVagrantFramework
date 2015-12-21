{% from "oracle12c/map.jinja" import extractdir, ora_app, ora_prod with context %}

{% set ora_d = extractdir ~ '/ora' %}


unzip:
  pkg.installed

/etc/security/limits.d/90-nproc.conf:
  file.managed:
    - source: salt://oracle12c/etc/security/limits.d/90-nproc.conf

/etc/fstab:
  file.managed:
    - source: salt://oracle12c/etc/fstab

#download and unzip changed to cmds to avoid attribute problems (executable):
#/tmp/p17694377_121020_Linux-x86-64_1of8.zip:
#  file.managed:
#    - source: http://path.to.software.download/p17694377_121020_Linux-x86-64_1of8.zip
#    - source_hash: md5=017d624abe5165406d3d7c7d2d3a834c

#yet again salt fails on file.managed... do a wget instead:
wget -O /tmp/p17694377_121020_Linux-x86-64_1of8.zip http://path.to.software.download/p17694377_121020_Linux-x86-64_1of8.zip:
  cmd.run

wget -O /tmp/p17694377_121020_Linux-x86-64_2of8.zip http://path.to.software.download/p17694377_121020_Linux-x86-64_2of8.zip:
  cmd.run

#/tmp/p17694377_121020_Linux-x86-64_2of8.zip:
#  file.managed:
#    - source: http://path.to.software.download/p17694377_121020_Linux-x86-64_2of8.zip
#    - source_hash: md5=7f93edea2178e425ff46fc8e52369ea3

mkdir -p {{ora_d}} && unzip /tmp/p17694377_121020_Linux-x86-64_1of8.zip -d {{ora_d}} && unzip /tmp/p17694377_121020_Linux-x86-64_2of8.zip -d {{ora_d}} && rm /tmp/p17694377_121020_Linux-x86-64_1of8.zip /tmp/p17694377_121020_Linux-x86-64_2of8.zip:
  cmd.run

#unzip.linuxamd64_12c_database_1of2.zip:
#  archive:
#    - extracted
#    - name: {{ora_d}}
#    - source: http://path.to.software.download/p17694377_121020_Linux-x86-64_1of8.zip
#    - source_hash: md5=017d624abe5165406d3d7c7d2d3a834c
#    - if_missing: {{ora_d}}/database/install/resource/cons_zh_TW.nls
#    - archive_format: zip
#    - require:
#      - pkg: unzip

#unzip.linuxamd64_12c_database_2of2.zip:
#  archive:
#    - extracted
#    - name: {{ora_d}}
#    - source: http://path.to.software.download/p17694377_121020_Linux-x86-64_2of8.zip
#    - source_hash: md5=7f93edea2178e425ff46fc8e52369ea3
#    - if_missing: {{ora_d}}/database/stage/Components/oracle.rdbms/12.1.0.1.0/1/DataFiles/filegroup19.6.1.jar
#    - archive_format: zip
#    - require:
#      - pkg: unzip


#https://github.com/saltstack/salt/issues/23822:
chmod -R a+x {{extractdir}}:
  cmd.run

oracle-rdbms-server-12cR1-preinstall:
  pkg.installed

{% for file in [ '12c_oracle_EE.rsp','12c_cfgrsp.properties' ] %}
{{extractdir}}/{{file}}:
  file.managed:
    - source: salt://oracle12c/{{file}}
{% endfor %}

{{ora_app}}:
  file.directory:
    - user: oracle
    - group: oinstall
    - mode: 775
    - makedirs: True

#need to -ignorePrereq since numprocesses are not yet read by this shell:
{{ora_d}}/database/runInstaller -silent -ignorePrereq -waitforcompletion -ignoreSysPrereqs -responseFile {{extractdir}}/12c_oracle_EE.rsp:
  cmd.run:
    - user: oracle

/u01/app/oraInventory/orainstRoot.sh:
  cmd.run

{{ora_prod}}/dbhome_1/root.sh:
  cmd.run

{{ora_prod}}/dbhome_1/cfgtoollogs/configToolAllCommands RESPONSE_FILE={{extractdir}}/12c_cfgrsp.properties:
  cmd.run:
    - user: oracle

/tmp/12c_pdb_autostart.sh:
  file.managed:
    - source: salt://oracle12c/12c_pdb_autostart.sh
    - mode: 0755
    - user: oracle
    - group: oinstall
  cmd.run:
    - user: oracle

/etc/init.d/dbora:
  file.managed:
    - source: salt://oracle12c/etc/init.d/dbora
    - user: root
    - group: root
    - mode: 755

chkconfig --add dbora:
  cmd.run

/home/oracle/.profile:
  file.managed:
    - source: salt://oracle12c/home/oracle/.profile
    - user: oracle
    - group: oinstall

#test, create .bash_profile, since .profile will not be read if .bash_profile present and using bash 
/home/oracle/.bash_profile:
  file.managed:
    - source: salt://oracle12c/home/oracle/.profile
    - user: oracle
    - group: oinstall

/home/oracle/scripts:
  file.recurse:
    - source: salt://oracle12c/home/oracle/scripts
    - user: oracle
    - file_mode: 0755

#start database so we can run sqlplus on it afterwords:
/etc/init.d/dbora start:
  cmd.run


#I don't think vktm_highcpu_vbox_hack is needed - let's try withoug
{% for script in [ 'noexpirepw', 'create_dev_users', 'alteruser' ] %}
/tmp/{{script}}.sql:
  file.managed:
    - source: salt://oracle12c/{{script}}.sql

{{ora_prod}}/dbhome_1/bin/sqlplus "/ as sysdba" @/tmp/{{script}}.sql > /tmp/{{script}}.log:
  cmd.run:
    - user: oracle
{% endfor %}

/tmp/shrink_tablespaces_part1.sql:
  file.managed:
    - source: salt://oracle12c/shrink_tablespaces_part1.sql

/tmp/shrink_tablespaces_part2.sql:
  file.managed:
    - source: salt://oracle12c/shrink_tablespaces_part2.sql

# Network Config
{{ora_prod}}/dbhome_1/network/admin/listener.ora
  file.managed:
    - source: salt://oracle12c/u01/app/oracle/product/12.1.0/dbhome_1/network/admin/listener.ora

{{ora_prod}}/dbhome_1/network/admin/tnsnames.ora
  file.managed:
    - source: salt://oracle12c/u01/app/oracle/product/12.1.0/dbhome_1/network/admin/tnsnames.ora

{{ora_prod}}/dbhome_1/bin/sqlplus / as sysdba @/tmp/shrink_tablespaces_part1.sql > /tmp/shrink_tablespaces.log:
  cmd.run:
    - user: oracle

restartDB_ts:
  cmd.run:
    - user: oracle
    - name: /home/oracle/scripts/shutdown.sh && /home/oracle/scripts/startup.sh

{{ora_prod}}/dbhome_1/bin/sqlplus / as sysdba @/tmp/shrink_tablespaces_part2.sql >> /tmp/shrink_tablespaces.log:
  cmd.run:
    - user: oracle

#cleanup
{{extractdir}}:
  file.absent
