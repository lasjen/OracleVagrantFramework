# Define APP_USER from in-parameter
V_ORA_VER=${1}

time_start=$(date +"%s")
#setup passwordless SSH for user oracle
#use %VAGRANT_HOME%/insecure_private_key as private key to connect without password
sudo cp -R /home/vagrant/.ssh /home/oracle/.
sudo chown -R oracle:oinstall /home/oracle/.ssh


cd /vagrant/files/setup/common/

echo "Creating OS directories..."
sh /vagrant/files/setup/common/create_directories_OS.sh

#sleep 30
echo "Creating common objects and users in DB..."
sudo -u oracle -i <<EOF
cd /vagrant/files/setup/common
sqlplus /nolog @setup_db.sql $V_ORA_VER
EOF

echo "Importing data from /u02/export"
if [ -f /vagrant/files/DBdumps/dpump_data.dmp.gz ]; then
   sudo -u oracle -i sh /vagrant/files/data_import.sh
fi

echo "Migrating schema if flyway script is available ..."
if [ "$(ls -A /ora_sql/flyway)" ]; then
  sudo -u oracle -i sh /flyway/flyway migrate -baselineOnMigrate=true
else
  echo "Flyway: No scripts available"
fi

time_end=$(date +"%s")
diff=$(($time_end-$time_start))
echo "Provision finished in $(date -d @$(($diff)) +"%M minutes %S seconds")"
