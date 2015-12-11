export WORKSPACE=/backup
VAGRANT_HOME=$(WORKSPACE)/.vagrant.d
VBOX_USER_HOME=$(WORKSPACE)/.vbox
EXPORT_BOX_FILE=vagrant-oracle12c-ee-`git rev-list --max-count=1 HEAD`.box
export http_proxy=http://proxy.edb.com:8080
export https_proxy=$(http_proxy)

clean:	
	vagrant destroy -f
	rm -f *box

build:	setup
	vagrant up

export: build
	vagrant halt
	vagrant package --output $(EXPORT_BOX_FILE)
	vagrant destroy -f

upload: export
	./uploadboxtoshare.sh $(EXPORT_BOX_FILE)

all:	upload

setup:	clean
	set
	vagrant --version
	VBoxManage --version
	VBoxManage setproperty machinefolder $(VBOX_USER_HOME)/machinefolder
	VBoxManage setproperty hwvirtexclusive off
	vagrant plugin install vagrant-proxyconf
	vagrant plugin install vagrant-vbguest
	vagrant plugin install vagrant-reload

