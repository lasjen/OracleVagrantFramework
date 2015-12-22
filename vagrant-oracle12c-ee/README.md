Pre-build tasks:
================
0. Set WORKSPACE parameter in Makefile
0. Download source files from Oracle Download and patches from metalink, and place at reachable destination (from now on called "path.to.software.download")
1. p17694377_121020_Linux-x86-64_1of8.zip
1. p17694377_121020_Linux-x86-64_2of8.zip
1. p6880880_121010_Linux-x86-64.zip (patch)
0. Edit "path.to.software.download" in init.sls and patch.sls (In future this should be changed to a parameter)

Building Oracle Vagrant box:
============================
```
# make build
```
