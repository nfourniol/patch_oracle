# Patch Oracle server and Upgrade of database TSTZ

## Objective
Two scripts:
- patch_oracle.sh ==> upgrade opatch and apply a patch on your oracle server
- upgrade_tstz.sh ==> upgrade TSTZ if timezone_file has been upgraded after applying a patch

It makes you gain some time if you have serveral managed oracle database server that you need to patch + upgrade TSTZ.

Both scripts must be executed as the `oracle` user. They run in background: the logs are written in the `logs` directory (logs older than 240 days are removed), and you are notified by email and/or Teams at the end (see the configuration below).


## How it works

### patch_oracle.sh
This script executes the linux and sqlplus commands needed to apply the patch. It launches `patch_oracle_core` in background, which:
1. reads `patch_oracle.conf` and checks the environment (oracle user, ORACLE_BASE, ORACLE_HOME, at least 15 GB of free disk space, patch files);
2. updates OPatch if the OPatch zip is more recent than the installed version (the previous version is kept in `$ORACLE_HOME/OPatch.old.v<version>`);
3. unzips the patch into `$ORACLE_BASE/patch` and finds, from its README.html, the directory from which `opatch apply` must be run;
4. stops the listener and the database, runs `opatch apply`, then restarts the database and the listener (also when `opatch apply` fails);
5. removes the unzipped patch (it is kept for analysis when `opatch apply` fails).

If something is wrong before step 4 (configuration, disk space, zip content...), the script stops without stopping the database.

This script also manages the application of the opatch patch, as the opatch utility used to patch Oracle databases generally has to be patched before the latest Oracle patch can be applied.

Currently the script requires you to mention a patch for opatch. But if the patch mentioned is older than the opatch currently present on your server, or if it is the same version, then no opatch patch will be applied (the script detects the version installed on your server and determines itself whether the opatch patch mentioned should be installed). If you still don't want to mention an opatch patch, you can simply edit the script and remove the part relating to opatch. Perhaps in a future version I'll make this optional.

### upgrade_tstz.sh
It asks for a confirmation (`yes` or `y`), because all the sessions connected to the database are killed, then launches `upgrade_tstz_core` in background, which upgrades the time zone file (TSTZ) of the database to the latest version available in ORACLE_HOME (`DBMS_DST.get_latest_timezone_version`):
- in a CDB: `CDB$ROOT`, `PDB$SEED` (the template of the new PDBs) and every PDB. The closed PDBs are opened;
- in a non-CDB: the database.

Only the containers whose version is lower than the latest one are upgraded: if everything is up to date, nothing is done. When `CDB$ROOT` (or the non-CDB database) needs an upgrade, the database is restarted in UPGRADE mode: every PDB is closed during this step. When only PDBs need an upgrade, only these PDBs are restarted.

If a container is in an unfinished DST upgrade (`DST_UPGRADE_STATE` other than `NONE`, e.g. after an interrupted run), the script stops before any modification: check it manually.

At the end, the version of every container is checked and the notification gives a summary, e.g. `CDB$ROOT: 32 -> 43; PDB$SEED: 32 -> 43; PDB1: 32 -> 43;`.

### Only one execution at a time
At startup, each script creates a lock file `<PID>.patch_oracle` or `<PID>.upgrade_tstz` in its directory, removed automatically at the end (also on error, Ctrl+C or kill). If another execution is running, the script stops. A lock file left by a process which is no longer running (e.g. `kill -9`) is removed automatically.


## How to configure the oracle patch database script
In the project's root directory, create a file named 'patch_oracle.conf' using 'patch_oracle.conf.sample' as a template.

oracle.opatch.fullpath ==> the full path to the patch for the oracle utility opatch (example: /mnt/refresh/oracle_patch/p6880880_190000_LINUX.zip)

oracle.patch.fullpath ==> the full path to the patch for the oracle database server (example: /mnt/refresh/oracle_patch/p36233126_190000_Linux-x86-64_tstz43.zip)

oracle.patch.directory ==> the directory that contains the whole patch and also container README.html (example: 36233126)

example: oracle.patch.directory=36233126

36233126 is the main directory inside p36233126_190000_Linux-x86-64_tstz43.zip. You can list the root directories of the zip with `unzip -Z1 p36233126_190000_Linux-x86-64_tstz43.zip | cut -d / -f 1 | sort -u`. If the directory is wrong, the error message gives the root directories of the zip.

Optional properties, to be notified at the end (success or error):
- mail.smtp_host, mail.mail_to (several addresses separated by `;`), mail.mail_from ==> email notification
- teams.workflow.tecinfra ==> URL of a Teams workflow ("Post to a chat when a webhook request is received"): green notification on success, red on error

## How to configure the upgrade_tstz script
create upgrade_tstz.conf from a copy of upgrade_tstz.conf.sample (same optional notification properties as patch_oracle.conf).

`patch_oracle.conf` and `upgrade_tstz.conf` are ignored by git: never commit them, they contain the Teams workflow URL.

## How to execute the scripts
```
chmod u+x *.sh lib/*.sh *_core
# Firstly apply patch:
./patch_oracle.sh
# Secondly, wait for the patch apply ending (you'll receive a notification if you have well filled patch_oracle.conf)
./upgrade_tstz.sh
```

## Sources used as references for writing this script

[Upgrade of database time zone](https://oracle-base.com/articles/misc/update-database-time-zone-file)

[Pitfalls: Connect to a PDB directly with ORACLE_PDB_SID](https://mikedietrichde.com/2020/07/13/pitfalls-connect-to-a-pdb-directly-with-oracle_pdb_sid/)
