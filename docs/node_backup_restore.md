# Performing Backup & Restore operations on your Plugin ($PLI) node

This document aims to provide guidance on the usage of the scripts associated with performing manual backup & restore operations.

_NOTE: There is no **TL;DR** section on this topic given the significance of operations being performed so please take the time to read the documentation_

This particular document assumes that you have already prepared your new node as per [Setting up a Plugin $PLI node - Steps 1 to 4](node_autosetup.md).


### What files are backed up?

The following details clarify what we are backing up, but as part of the process all files are compressed using gunzip and then gpg encrypted.
####   - Conf files
All files in you $HOME folder with the _'plinode'_ prefix are selected for backup. This covers the following as an example;

>    - node & backup vars files
>    - exported node recovery keys json files


####   - Database files
Using the inbuilt postgres database utility, we take a full backup of the plugin node database **"plugin_mainnet_db"**, which produces a single sql data file.


####   - File Encryption
As touched on above, all compressed backup files are gpg encrypted.  The process follows the same approach as the actual node installation whereby the **_KEYSTORE PASSWORD_** is used to secure the backup files.  

As you are already expected to have this password securely stored in your password manager / key safe, it was the logical method to employ rather than creating another strong password to have to store & document.


#### Exclusions disclaimer

The following files/folders are not currently backed up as part of this process;

  - External Initiators
  - External Adapters & Bridges


---

### Where are my backup files stored?

When you manually run the backup script, the file are always written to the folder named **"plinode_backups"** which itself is located at the Root '/' folder.

   Backups Folder is `/plinode_backups`

### When should I run the backup script?

You should make your first backup after deploying the node and having completed the validation alarm clock test as part of node approval submission. 

Follow up backups should be captured when you have added additional adapter/initiator configuration to the node.


| **CAUTION :: A backup is not guaranteed until you have performed a restore and validated the integrity of the data.** |
|---|

### How do I integrate these new scripts to my nodes existing scripts

To obtain the latest scripts, you simply update the local scripts folder (a.k.a. repo or repository). This is explained in the ['Refreshing your local repo'](node_scripts_details.md#refreshing-your-local-repo) section on the main readme.


---
---

# Performing a BACKUP

**IMPORTANT ::** _Backups are stored locally on your VPS host. It is **YOUR responsibility** as a node operator to ensure these files are copied to another location off the local node so that you can recover the node in the event of disk corruption / failure._

## 1st time backup - setup step

In the scenario where you are backing up any files for the fisrt time, we need to run the setup script to ensure that all the backup folder and permissions are in place.

  1. Lets now run the setup script to ensure that the backup folder & permissions are in place;

            cd ~/pli_node_conf && ./_plinode_setup_bkup.sh

  2. This will produce output to the terminal as it executes, the following is an example of what you can expect;

            nmadmin@plitest:~/pli_node_conf$ ./_plinode_setup_bkup.sh
            [sudo] password for nmadmin:
            pre-check vars - checking if gdrive user exits
            pre-check vars - setting group members for backups - without gdrive
            pre-check vars - assiging user-group permissions..
            checking vars - updating file plinode_plitest_bkup.vars variable 'DB_BACKUP_DIR' to: plinode_backups
            checking vars - assigning permissions for directory: /plinode_backups
            checking vars - assigning 'DB_BACKUP_PATH' variable: /plinode_backups
            nmadmin@plitest:~/pli_node_conf$

  3. Lets check the permissions on the "/plinode_backups" folder

            ll / | grep plinode

  4. We should see the folder permissions set like the following example;

            drwxrwxr-x   2 nmadmin nodebackup       4096 Apr 13 10:09 plinode_backups

### Usage syntax

A brief explanation of the function syntax 

        Usage: ./_plinode_backup.sh {function}

        where {function} is one of the following;

              -full      ==  performs a local backup of both config & DB files only
              -conf      ==  performs a local backup of config files only
              -db        ==  performs a local backup of DB files only


The following commands will perform a **FULL** backup

    cd ~/pli_node_conf && ./_plinode_backup.sh -full


The following commands will perform a **CONFIG files** only backup

    cd ~/pli_node_conf && ./_plinode_backup.sh -conf


The following commands will perform a **DATABASE** only backup 

    cd ~/pli_node_conf && ./_plinode_backup.sh -db

---

### Check the backups folder contents

Once you have run any of the backup functions listed above, you may way to confirm that the files have been created successfully to verfiy the completion messages that the scripts provide.

To do this simply list the contents of the `plinode_backups` folder as follows;

    ll /plinode_backups


You should see something similar to the following;


    nmadmin@plitest:~/pli_node_conf$ ll /plinode_backups/
    total 628
    drwxrwxr-x  2 nmadmin nodebackup  4096 Apr 15 23:34 ./
    drwxr-xr-x 21 nmadmin       1007  4096 Apr 12 22:43 ../
    -rw-r--r--  1 nmadmin nodebackup  2658 Apr 12 22:43 plitest_conf_vars_2022_04_12_22_43.tar.gz.gpg
    -rw-r--r--  1 nmadmin nodebackup  2891 Apr 13 10:09 plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg
    -rw-r--r--  1 nmadmin nodebackup  2924 Apr 15 22:52 plitest_conf_vars_2022_04_15_22_52.tar.gz.gpg
    -rw-r--r--  1 nmadmin nodebackup 28277 Apr 12 22:43 plitest_plugin_mainnet_db_2022_04_12_22_43.sql.gz.gpg
    -rw-r--r--  1 nmadmin nodebackup 28763 Apr 12 22:54 plitest_plugin_mainnet_db_2022_04_12_22_54.sql.gz.gpg
    -rw-r--r--  1 nmadmin nodebackup 29059 Apr 15 22:52 plitest_plugin_mainnet_db_2022_04_15_22_52.sql.gz.gpg
    nmadmin@plitest:~/pli_node_conf$

    
---
---

# Performing a RESTORE

There are two approaches to the restore operation as set out below.

---
## The in-place RESTORE

An 'in-place' restore is where you need to revert the node to a previous state, this could be either just the conf files or the database files or indeed both. This scenario does not invole the re-installation of the node deployment files. 

This is not a very involved operation with minimal steps as follows;

  1. run the restore script as follows;
    
            ./_plinode_restore.sh

  2. Now to selecting the type & date-time stamp backup file to restore. You should be presented with a list of files similar to the following;
     **NOTE ::** _The list of files that you see will be dependent on how many backups you have performed._


                      Showing last 8 backup files.
                      Select the number for the file you wish to restore

            1) /plinode_backups/plitest_conf_vars_2022_04_12_22_43.tar.gz.gpg	       6) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_25.sql.gz.gpg
            2) /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg	       7) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_29.sql.gz.gpg
            3) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_43.sql.gz.gpg  8) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz.gpg
            4) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_54.sql.gz.gpg  9) QUIT
            5) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_21.sql.gz.gpg
            #?

    
   3. The code detects the file selection and calls the appropriate function to handle the file. 
   
      i.  If you choose a "conf" file then the script proceeds to restore the contents to the original location: $HOME
          An example of the output would be as follows;

                   RESTORE MENU - Restoring file: /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg
                   CONFIG FILES RESTORE....
                uncompressing gz file: /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz
                unpacking tar file: /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar
                home/nmadmin/plinode_job_alarmclock.json
                home/nmadmin/plinode_plitest_bkup.vars
                home/nmadmin/plinode_plitest_bkup.vars.bak
                home/nmadmin/plinode_plitest_keys_2022_04_12_21_44.json
                home/nmadmin/plinode_plitest_keys_2022_04_13_09_10.json
                home/nmadmin/plinode_plitest.vars

            
   
      ii. If you chose a "db" file you will then be presented with the scenario check message as follows; where you confirm which approach you wish to execute;

            ######################################################################################
            ######################################################################################
            ##
            ##      RESTORE SCENARIO CONFIRMATION...
            ##
            ##
            ##  A Full Restore is ONLY where you have moved backup files to a FRESH / NEW VPS host
            ##  this includes where you have reset your previous VPS installation to start again..
            ##

            Are you performing a Full Restore to BLANK / NEW VPS? - Please answer (Y)es or (N)o 

  4. As this is an 'in-place' restore, we simply respond No to proceed.
     **NOTE ::** _There is also a timer set on this input which presents the following message; before repeating to list the available files for restore._

            ....timed out waiting for user response - please select a file to restore...

  5. At this point you either select the file to restore or quit


---
---
## Full RESTORE 



The full restore approach targets the following scenarios;

>  1.  where a full rebuild of your current VPS host - using the "reset_pli.sh" script _(soft reset)_
>  2.  where a full rebuild of your current VPS host - using the control panel reset option of your VPS hosting portal _(hard reset)_
>  3.  migration of your node to another VPS hosting platform 


With scenario 1. the assumption is that there is no movement of any backup files and they have remained intact in their default location of "/plinode_backups".

With scenarios 2. & 3. the assumption is that you have copied the relevant backup files to the original path "/plinode_backups" on your now reset / new VPS host.

All of these scenarios involved the installation of the node deployment files

### KEY POINTS TO REMEMBER 

**_!! READ CAREFULLY !!_**

>
>  - The "vars" configuration file name structure uses the 'hostname' of the VPS where it was created. When migrating to a new VPS hosting platform be aware that the newly provisioned VPS will have a different 'hostname'.  
>
>
>  - To reduce effort it is recommended that you rename the restored conf files so that they are compatible with the scripts.  See the [renaming files section](node_backup_restore.md#renaming-files) 
>
>
>  - The script will always restore to the location where the backup files originated. This is only a concern when performing a Full Restore. Operators should ensure that they maintain the same user account details when migrating.
>

---
>
---
### How to perform a full restore

> The process consists of 4 main steps;
>
>   1. Perform system updates & clone the repo
>   2. Setup system permissions
>   3. Restore the conf files
>   4. Perform a fresh node deployment install
>   5. Restore the database 
>


---
#### Setup system permissions

  1. To update your system & clone the deployment scripts from github, simply follow steps 1 through 4 of the [Setting up a Plugin $PLI node - Automated Script Method](node_autosetup.md) & logon as your new admin user.
  
  
  2. With the necessary files copied to the fresh VPS under folder "/plinode_backups", we need to set the necessary file permissions so that the main scripts can execute. Lets get into the correct folder to run the scripts;

            cd ~/pli_node_conf

  3. Lets now run the setup script to ensure that the backup folder & permissions are in place;

            ./_plinode_setup_bkup.sh

  4. This will produce output to the terminal as it executes, the following is an example of what you can expect to see;

            nmadmin@plitest:~/pli_node_conf$ ./_plinode_setup_bkup.sh
            [sudo] password for nmadmin:
            COMPELTED BACKUP SETUP SCRIPT
            nmadmin@plitest:~/pli_node_conf$


---
---

>  **NOTE :: At this point you would copy the backup files onto the new VPS host, now that the backups folder has been re-created.**
>
>  **An example of this would be using SCP to copy between linux VPS e.g. Scenario 3 and [copy backup files between 2 Linux VPS hosts](node_backup_restore.md#Copy-backup-files-between-Linux-VPS-hosts)**
>
>  **You will need to re-run the above setup script `_plinode_setup_bkup.sh` to reset the file permissions for the files that you have copied into the backups folder in order that the scripts will have the correct permissions to the files as part of the restore process.**

---
---
#### Restore the conf files

  1. Now we progress to restore the "conf" files so that we have all our credentials and variables necessary for the re-install of the node software.
     During this step you will be prompted for your origianl _KEYSTORE PASSWORD_ so best to have it to hand ready for pasting into the terminal.

  2. Lets kick off the "conf" files restore by running the main restore script;
    
            ./_plinode_restore.sh

  3. Now to selecting the type & date-time stamp backup file to restore. You should be presented with a list of files similar to the following;
     **NOTE ::** _The list of files that you see will be dependent on how many backups you have performed._


                      Showing last 8 backup files.
                      Select the number for the file you wish to restore

            1) /plinode_backups/plitest_conf_vars_2022_04_12_22_43.tar.gz.gpg	       6) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_25.sql.gz.gpg
            2) /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg	       7) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_29.sql.gz.gpg
            3) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_43.sql.gz.gpg  8) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz.gpg
            4) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_54.sql.gz.gpg  9) QUIT
            5) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_21.sql.gz.gpg
            #?


    _NOTE :: The code detects the file selection and calls the appropriate function to handle the file._
   
  4. Choose a "conf" file then the script proceeds to restore the contents to the original location: $HOME
          An example of the output would be as follows;

                   RESTORE MENU - Restoring file: /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg
                   CONFIG FILES RESTORE....
                uncompressing gz file: /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz
                unpacking tar file: /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar
                home/nmadmin/plinode_job_alarmclock.json
                home/nmadmin/plinode_plitest_bkup.vars
                home/nmadmin/plinode_plitest_bkup.vars.bak
                home/nmadmin/plinode_plitest_keys_2022_04_12_21_44.json
                home/nmadmin/plinode_plitest_keys_2022_04_13_09_10.json
                home/nmadmin/plinode_plitest.vars

        
       **INPORTANT REMINDER :: _Be aware of changes to your systems hostname when migrating to a new VPS. At the very least you will need to rename the restored conf file to match your new VPS hostname._**
       
       **Checkout the [renaming files](node_backup_restore.md#renaming-files) section on how to change the vars filename.**


---
#### Perform a fresh node deployment install

  1. We now have your original conf files restored & [renamed](node_backup_restore.md#renaming-files) the conf file to match your new VPS hostname (`hostname -f`)

  Now we can perform a fresh node installation which will re-use those existing credentials & settings

            ./pli_node_scripts.sh fullnode


  2. When the installation completes you will see the credentials & node address details output to the terminal screen. You should note that the node address is different from your original working node. This is where our db restore comes into play.
  
  3. **IMPORTANT STEP** Now REBOOT the VPS host
  
  4. Once the VPS has successfully rebooted, we then proceed to restore the database.


---
#### Restore the database

  1. Lets kick off the "db" file restore by running the main restore script;
    
            cd ~/pli_node_conf
            ./_plinode_restore.sh


  2. Now to selecting the type & date-time stamp backup file to restore. You should be presented with a list of files similar to the following;
     **NOTE ::** _The list of files that you see will be dependent on how many backups you have performed._


                      Showing last 8 backup files.
                      Select the number for the file you wish to restore

            1) /plinode_backups/plitest_conf_vars_2022_04_12_22_43.tar.gz.gpg	       6) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_25.sql.gz.gpg
            2) /plinode_backups/plitest_conf_vars_2022_04_13_10_09.tar.gz.gpg	       7) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_29.sql.gz.gpg
            3) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_43.sql.gz.gpg  8) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz.gpg
            4) /plinode_backups/plitest_plugin_mainnet_db_2022_04_12_22_54.sql.gz.gpg  9) QUIT
            5) /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_08_21.sql.gz.gpg
            #?


  **_NOTE ::_** **_The code detects the file selection and calls the appropriate function to handle the file._**


  3. Choose a "db" file you will then be presented with the scenario check message as follows; where you confirm which approach you wish to execute;

               RESTORE MENU - Restoring file: /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz.gpg
                   ######################################################################################
                   ######################################################################################
                   ##
                   ##      RESTORE SCENARIO CONFIRMATION...
                   ##
                   ##
                   ##  A Full Restore is ONLY where you have moved backup files to a FRESH / NEW VPS host
                   ##  this includes where you have reset your previous VPS installation to start again..
                   ##

                   Are you performing a Full Restore to BLANK / NEW VPS? - Please answer (Y)es or (N)o 


  4. As this is a full restore, we simply respond Yes to proceed.

     **NOTE ::** _There is also a timer set on this input which presents the following message; before repeating to list the available files for restore._

            ....timed out waiting for user response - please select a file to restore...


  5. Having confirmed Yes to the scenario confirmation message, this sets a flag within the code the forces a rebuild of the External Initiator (EI) process. We see the script restore messages as follows;

               DB RESTORE.... unzip file name: /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql.gz
               DB RESTORE.... psql file name: /plinode_backups/plitest_plugin_mainnet_db_2022_04_13_10_05.sql
               DB RESTORE.... restarting service postgresql
            ..   DB RESTORE.... API connection responding - continuing


  6. There will be a short delay here where the script waits for the local node API to respond following the database service restart.

  7. The next updates to the terminal will show the External Initiator (EI) process being stopped & deleted as part of the rebuild process

            [PM2] Applying action stopProcessId on app [3_initiatorStartPM2](ids: [ 5 ])
            [PM2] [3_initiatorStartPM2](5) ✓
            ┌─────┬────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
            │ id  │ name                   │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
            ├─────┼────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
            │ 0   │ 2_nodeStartPM2         │ default     │ N/A     │ fork    │ 845384   │ 7s     │ 3    │ online    │ 0%       │ 3.1mb    │ nmadmin  │ disabled │
            │ 5   │ 3_initiatorStartPM2    │ default     │ N/A     │ fork    │ 0        │ 0      │ 0    │ stopped   │ 0%       │ 0b       │ nmadmin  │ disabled │
            └─────┴────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
            [PM2] Applying action deleteProcessId on app [3_initiatorStartPM2](ids: [ 5 ])
            [PM2] [3_initiatorStartPM2](5) ✓
            ┌─────┬───────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
            │ id  │ name              │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
            ├─────┼───────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
            │ 0   │ 2_nodeStartPM2    │ default     │ N/A     │ fork    │ 845384   │ 7s     │ 3    │ online    │ 0%       │ 3.1mb    │ nmadmin  │ disabled │
            └─────┴───────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
            [PM2][WARN] Current process list is not synchronized with saved list. App 3_initiatorStartPM2 differs. Type 'pm2 save' to synchronize.


  8. The following messages immediately follow, confirming the rebuild of the External Initiator (EI) & restarting the PM2 process

            DB RESTORE - REBUILD EI - authenticate to API with credentials file: .env.apicred
            DB RESTORE - REBUILD EI - delete existing EI
            DB RESTORE - REBUILD EI - generating new EI values & extract to file
            DB RESTORE - REBUILD EI - reading new EI values to variables
            DB RESTORE - REBUILD EI - creating new EI file
            [PM2] Starting /home/nmadmin/plugin-deployment/3_initiatorStartPM2.sh in fork_mode (1 instance)
            [PM2] Done.
            ┌─────┬────────────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
            │ id  │ name                   │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
            ├─────┼────────────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
            │ 0   │ 2_nodeStartPM2         │ default     │ N/A     │ fork    │ 846491   │ 16s    │ 7    │ online    │ 0%       │ 3.1mb    │ nmadmin  │ disabled │
            │ 6   │ 3_initiatorStartPM2    │ default     │ N/A     │ fork    │ 846584   │ 0s     │ 0    │ online    │ 0%       │ 3.3mb    │ nmadmin  │ disabled │
            └─────┴────────────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
            [PM2] Saving current process list...
            [PM2] Successfully saved in /home/nmadmin/.pm2/dump.pm2


  9. The final message should be confirmation that the restore completed

               DB RESTORE - COMPLETED
            

  10. In order to validate that the External Initiator (EI) rebuild was successful, we generate a dummy job for the local node, using the job script as follows;

            ./job_alarmclock_test.sh

  11. When prompted enter a dummy string beginning with either xdc or 0x as shown below;

            #
            #   This script generates the necessary json blob for the Oracle Job-Setup section in the docs
            #   source: https://docs.goplugin.co/oracle/job-setup
            #
            #   The script uses the 'name' & 'endpoint' variables from your local VARS file & prompts
            #   you to enter the newly generated Oracle contract address (which was generated by the Oracle Deployment section)
            #
            #   The script checks for leading  / trailing white spaces and removes as necessary
            #   & converts the 'xdc' prefix to '0x' as necessary
            #
            #
            Enter your Oracle Contract Address : xdcthisisadummyocatest


  12. Having entered the dummy OCA and hit enter, you will see further output as follows;

            --- /dev/fd/63	2022-04-14 01:35:00.131731297 +0000
            +++ /dev/fd/62	2022-04-14 01:35:00.131731297 +0000
            @@ -1 +1 @@
            -xdcthisisadummyocatest
            +0xthisisadummyocatest
            #
            Local node Alarm Clock Sample job id - Copy to your Solidity script
            =================================================================

            Your Oracle Contract Address is   : 0xthisisadummyocatest
            Your Alarm Clock Sample Job ID is : cce1ab17354d46d29ce30356d03f4148


  13. With a valid Job ID printed to the terminal you have validated that the db restore  & the External Initiator (EI) rebuild was successful

  14. The final check is to confirm that the local Node Address is the same as before you reset / migrated your node. Do this by running the following command;

            ./pli_node_scripts.sh address


  15. This command with print the local Node Address to the terminal screen for you to check.

            nmadmin@plitest:~/pli_node_conf$ ./pli_node_scripts.sh address

            Your Plugin node wallet address is: 0x160C2b4b7ea040c58D733feec394774A915D0cb5

            #########################################################################

  16. **FINAL VERIFICATION STEP**
  As this is a production node restore, you should now proceed to complete the following steps;
  
    - Perform a complete AlarmClockSample job with new OCA etc. as per the official docs
    - confirm the local node balance for PLI & XDC tokens




---
---

**_NOTE :: Caution should be taken with the following steps as they will impact the success of running a restore_**

## Renaming a VPS

By renaming the VPS it can potentially save on having to rename a number of files, which can possibly introduce further issues.


**Back ground ::**  The deployment scripts use the following command; from which the filenames are derived.

        hostname -f

The above command sources the value from the following system setting "**Static hostname**"; using the command **hostnamectl**

        nmadmin@plitest:~$ hostnamectl
           Static hostname: plitest
                 Icon name: computer-vm
                   Chassis: vm
                Machine ID: c81f3d359a224cfba34b06e348e717aa
                   Boot ID: 0f3571ddc762471ba83b09e6ea8e00cf
            Virtualization: vmware
          Operating System: Ubuntu 20.04.4 LTS
                    Kernel: Linux 5.4.0-105-generic
              Architecture: x86-64


So to change your systems "**Static hostname**" value, you need to run the following command; the example is renaming the system to 'plitest-renamed'

**IMPORTANT :: Do NOT use any underscores "_" in your name as these introduce further considerations**

-- Lets just **K**eep **I**t **S**imple !!


        sudo hostnamectl set-hostname plitest-renamed


Now verify the change using the command **hostnamectl**

        nmadmin@plitest:~$ hostnamectl
           Static hostname: plitest-renamed
                 Icon name: computer-vm
                   Chassis: vm
                Machine ID: c81f3d359a224cfba34b06e348e717aa
                   Boot ID: 0f3571ddc762471ba83b09e6ea8e00cf
            Virtualization: vmware
          Operating System: Ubuntu 20.04.4 LTS
                    Kernel: Linux 5.4.0-105-generic
              Architecture: x86-64


All the above information has been sourced from the following article which will provide more detail;
_source: [How to Set or Change Hostname in Linux](https://linuxize.com/post/how-to-change-hostname-in-linux/)_

Once the 'Static hostname' has been changed, you must ensure that you also update the 'hosts' file.



---------

## Renaming files

In the scenario where the restore system is different from the original system where the backup files were created, you will need to update the main 'vars' file at a minimum. The file name structure adheres to the following structure;

     plinode_{hostname}.vars

Once the "conf" files are restored you should rename the file to match your current systems 'hostname' as follows;

  1. change in to the folder where the vars file is located - by default this is your users home folder.

            cd /$HOME

  2. now we rename the file to match the current system 'hostname'. The following example shows the original vars file of a host system named 'plitest';

            mv plinode_plitest.vars "plinode_$(hostname -f)".vars



---------

## Copy backup files between Linux VPS hosts

The following steps provide an example of how to move your backup files from the 'original' VPS to a new 'target' VPS. 

As set out above in other parts of this documentation, the following steps assume that you have maintained the same username & password on the 'target' VPS as was used on the 'original' VPS. If this is not the case then you should adjust appropriately.

  1. Logon to your new 'target' VPS with your user admin account.

  2. From the 'target' VPS run the following command;

            scp -P 5329 bhcadmin@162.55.179.118:/plinode_backups/*.gpg ~/

     - This will connect into the 'original' VPS, using the specified `-P` port number and copy the backup files to the 'target' VPS. The following exmaple shows the admin user account as `bhcadmin` with the IP address of the 'original' VPS. 

     - The `:/plinode_backups/*.gpg` portion of the command is the backups folder where we know our backup scripts create the back files to.  We also know that the created backup files are encrypted with the extension `gpg`, so we copy all the `gpg` files.
     
     - The final portion of the command `~/` is the linux alias for the user home folder and represents the home folder on the 'target' VPS to where you are copying the files. 


If using ssh keys then there is an extra parameter `-i ~/.ssh/my_user.key` that you need to include in the command, as follows;

      scp -i ~/.ssh/my_user.key -P 5329 my_user@original_vps_ip:/plinode_backups/*.gpg ~/
