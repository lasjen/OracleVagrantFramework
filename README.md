# Oracle Vagrant Framework

## Synopsis

This repository includes a framework for 
1. Building an Vagrant box for running an Oracle Database Server (see vagrant-oracle12c-ee)
2. Creating and managing database servers running under Vagrant and VirtualBox (see 31_orcl)

You must first use the "vagrant-oracle12c-ee" to create a vagrant box. Then you can use the "31_orcl" framework to administer your Oracle database servers.

## 1. Oracle Vagrant Box

Go to the [vagrant-oracle12c-ee](./vagrant-oracle12c-ee) directory, and follow the description.

Add the new box to your local vagrant repository:
```
vagrant box add OEL67-ORA12 /path/to/the/new.box
```
You are now ready to use the "31_orcl" framework described below.

## 2. Managing your Oracle databases using the "31_orcl" framework

### Use the vagrant framwork for running Oracle databases under VirtualBox

Copy the "31_orcl" directory to a drive with some space for creating VMs:
```
cp -R 31_orcl /data/vagrant_vms
cd /data/vagrant_vms/31_orcl
vi Vagrantfile
```
Edit the Vagrantfile, and set V_HOSTNAME_APPENIX to the number you used i your directory name: 

```
 $V_HOSTNAME_APPENIX="31"
```

### Start your database
Now you are ready to start your database:
```
vagrant up
```
THis will create a new machine under VirtualBox named "OEL67-ORA12-ORCL-31".

### Connect to the database node
To connect to the server run:
```
vagrant ssh
-- or --
ssh vagrant@localhost -p 2231
```

### Connect to your database
The database can now be reached from your host machine using localhost and port 1531:
```
sql lj@//localhost:1531/orcl
```
### Stop the database machine
The database machine can be stopped by running:
```
vagrant halt
```

### Create a new Oracle server and database

Copy the "31_orcl" to a new directory - for instance "32_orcl", remove the .vagrant directory (with the 31 machine), and edit the Vagrantfile::
```
cp -R 31_orcl 32_orcl
cd 32_orcl
rm -rf .vagrant
vi Vagrantfile
```
Set the $V_HOSTNAME_APPENIX to 32:
```
 $V_HOSTNAME_APPENIX="32"
```

And you are now ready for starting a new database exposed on localhost:1532 with "vagrant up".

Good Luch
