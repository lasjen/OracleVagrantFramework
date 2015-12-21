{% from "oracle12c/map.jinja" import extractdir, ora_app, ora_prod with context %}

#should it be installed? or should patch util find it inside oracle install???
perl:
  pkg.installed

shutdownDB:
  cmd.run:
    - user: oracle
    - name: /home/oracle/scripts/shutdown.sh

#remove old opatch:
{{ora_prod}}/dbhome_1/OPatch:
  file.absent

/tmp/p6880880_121010_Linux-x86-64.zip:
  file.managed:
    - source: http://path.to.software.download/p6880880_121010_Linux-x86-64.zip
    - source_hash: md5=fd388cef00f928d383d29b722d3cb912
    - user: oracle

unzip /tmp/p6880880_121010_Linux-x86-64.zip -d {{ora_prod}}/dbhome_1 && rm /tmp/p6880880_121010_Linux-x86-64.zip:
  cmd.run:
    - user: oracle

##opatch util update:
#unzip.opatch:
#  archive:
#    - extracted
#    - name: {{ora_prod}}/dbhome_1
#    - source: http://path.to.software.download/p6880880_121010_Linux-x86-64.zip
#    - source_hash: md5=fd388cef00f928d383d29b722d3cb912
#    - archive_user: oracle
#    - if_missing: {{ora_prod}}/dbhome_1/OPatch
#    - archive_format: zip

chown -R oracle:oinstall {{ora_prod}}/dbhome_1/OPatch:
  cmd.run

/tmp/p21520444_121020_Linux-x86-64.zip:
  file.managed:
    - source: http://path.to.software.download/p21520444_121020_Linux-x86-64.zip
    - source_hash: md5=0252b595cbb6634958c2db278ddf0b5f
    - user: oracle

{{extractdir}}/patchset:
  file.directory:
    - makedirs: True
    - user: oracle
    - group: oinstall

unzip /tmp/p21520444_121020_Linux-x86-64.zip -d {{extractdir}}/patchset && rm /tmp/p21520444_121020_Linux-x86-64.zip:
  cmd.run:
    - user: oracle

#patchset:
#unzip.patchset:
#  archive:
#    - extracted
#    - name: {{extractdir}}/patchset
#    - source: http://path.to.software.download/p21520444_121020_Linux-x86-64.zip
#    - source_hash: md5=0252b595cbb6634958c2db278ddf0b5f
#    - if_missing: {{extractdir}}/patchset
#    - archive_format: zip

{{extractdir}}/ocm.rsp:
  file.managed:
    - source: salt://oracle12c/ocm.rsp
    - user: oracle

{% for patch in [ '21359755', '21555660' ] %}
opatch apply {{patch}}:
  cmd.run:
    - cwd: {{extractdir}}/patchset/21520444/{{patch}}
    - user: oracle
    - name: {{ora_prod}}/dbhome_1/OPatch/opatch apply -silent -ocmrf {{extractdir}}/ocm.rsp
{% endfor %}

startupDB_UPGRADE:
  cmd.run:
    - user: oracle
    - name: /home/oracle/scripts/startup.sh UPGRADE

upgradePDBs:
  cmd.run:
    - user: oracle
    - name: /home/oracle/scripts/upgrade_pdb.sh

datapatch:
  cmd.run:
    - user: oracle
    - name: {{ora_prod}}/dbhome_1/OPatch/datapatch -verbose

restartDB:
  cmd.run:
    - user: oracle
    - name: /home/oracle/scripts/shutdown.sh && /home/oracle/scripts/startup.sh

#cleanup
{{extractdir}}:
  file.absent
