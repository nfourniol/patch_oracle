# Patch Oracle server and Upgrade of database TSTZ

## Objective
Two scripts:
- patch_oracle.sh ==> upgrade opatch and apply a patch on your oracle server
- upgrade_tstz.sh ==> upgrade TSTZ if timezone_file has been upgraded after applying a patch

It makes you gain some time if you have serveral managed oracle database server that you need to patch + upgrade TSTZ.


## How it works
This script executes the linux and sqlplus commands needed to apply the patch.

This script also manages the application of the opatch patch, as the opatch utility used to patch Oracle databases generally has to be patched before the latest Oracle patch can be applied.


Currently the script requires you to mention a patch for opatch. But if the patch mentioned is older than the opatch currently present on your server, or if it is the same version, then no opatch patch will be applied (the script detects the version installed on your server and determines itself whether the opatch patch mentioned should be installed). If you still don't want to mention an opatch patch, you can simply edit the script and remove the part relating to opatch. Perhaps in a future version I'll make this optional.

## How to configure the oracle patch database script
In the project's root directory, create a file named 'patch_oracle.conf' using 'patch_oracle.conf.sample' as a template.

oracle.opatch.fullpath ==> the full path to the patch for the oracle utility opatch (example: /mnt/refresh/oracle_patch/p6880880_190000_LINUX.zip)

oracle.patch.fullpath ==> the full path to the patch for the oracle database server (example: /mnt/refresh/oracle_patch/p36233126_190000_Linux-x86-64_tstz43.zip)

oracle.patch.directory ==> the directory that contains the whole patch and also container README.html (example: 36233126)

example: oracle.patch.directory=36233126

36233126 is the main directory inside p36233126_190000_Linux-x86-64_tstz43.zip. I didn't find another solution to find the right directory inside p36233126_190000_Linux-x86-64_tstz43.zip, but I you find a better solution, please submit it!

## How to configure the upgrade_tstz script
create upgrade_tstz.conf from a copy of upgrade_tstz.conf.sample

## How to execute the scripts
```
chmod u+x *.sh lib/*.sh *_core
# Firstly apply patch:
./patch_oracle.sh
# Secondly, wait for the patch apply ending (you'll receive a notification if you have well filled patch_oracle.conf)
./upgrade_tstz.sh

## Sources used as references for writing this script

[Upgrade of database time zone](https://oracle-base.com/articles/misc/update-database-time-zone-file)
