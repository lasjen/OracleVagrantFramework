# Oracle Vagrant Framework

## Synopsis

This repository includes a framework for 
- Building an Vagrant box for running an Oracle Database Server (see vagrant-oracle12c-ee)
- Creating and managing database servers running under Vagrant and VirtualBox (see 31_orcl)

You must first use the "vagrant-oracle12c-ee" to create a vagrant box.

Add the new box to your local vagrant repository:
```
vagrant box add OEL67-ORA12 /path/to/the/new.box
```

## Oracle Vagrant Box

Go to the [vagrant-oracle12c-ee](./vagrant-oracle12c-ee) directory, and follow the description.

## Use the vagrant framwork for running Oracle databases under VirtualBox

Copy the "31_orcl" directory to a drive with some space for creating VMs:
```
cp -R 31_orcl /data/vagrant_vms
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
Good Luch
