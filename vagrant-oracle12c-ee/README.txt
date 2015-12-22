Pre-build tasks:
================
- Set parameters in oracle12c/map.jinja file
- Download source files (p17694377_121020_Linux-x86-64_1of8.zip & p17694377_121020_Linux-x86-64_2of8.zip) from Oracle Download
- Download patch (p6880880_121010_Linux-x86-64.zip) from Oracle Support
- Edit "path.to.software.download" in init.sls and patch.sls (In future this should be changed to a parameter)

Building Oracle Vagrant box:
============================
# make build
