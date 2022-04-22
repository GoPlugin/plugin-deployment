<br/>
<p align="center">
<a href="https://goplugin.co" target="_blank">
<img src="https://github.com/GoPlugin/Plugin/blob/main/docs/plugin.png" width="225" alt="Plugin logo">
</a>
</p>
<br/>

This repository contains the scripts for automation of the [Plugin](https://goplugin.co/) Node setup which can be used by the Node operators.


# Table of Contents
---
## Scripts Method (recommended)
  - ### [Script: Guide on node auto deployment](docs/node_autosetup.md)
    - #### Details on the scripts usage & functions
      - ##### [Usage & syntax](docs/node_scripts_details.md#usage)
      - ##### [Function: fullnode](docs/node_scripts_details.md#function-fullnode)
      - ##### [Function: initiator](docs/node_scripts_details.md#function-initiator)
      - ##### [Function: keys](docs/node_scripts_details.md#function-keys)
      - ##### [Function: logrotate](docs/node_scripts_details.md#function-logrotate)
      - ##### [Function: Address](docs/node_scripts_details.md#function-address)


---
  - ### [Script: Guide on how to backup & restore your node](docs/node_backup_restore.md)

      - #### [What files are backed up?](docs/node_backup_restore.md#what-files-are-backed-up)
      - #### [Where are the backup files stored?](docs/node_backup_restore.md#where-are-my-backup-files-stored)
      - #### [When should I run a backup?](docs/node_backup_restore.md#when-should-i-run-the-backup-script)
      - #### [How can I use these new scripts with my existing scripts?](docs/node_backup_restore.md#how-do-i-integrate-these-new-scripts-to-my-nodes-existing-scr)
    
  - ### [Backup Function](docs/node_backup_restore.md#performing-a-backup)
      - #### [1st time backup - setup step](docs/node_backup_restore.md#1st-time-backup---setup-step) 
      - #### [Usage syntax](docs/node_backup_restore.md#usage-syntax) 
      - #### [Performing a Full Backup](docs/node_backup_restore.md#full-backup) 
      - #### [Performing a Config file backup only](docs/node_backup_restore.md#config-backup) 
      - #### [Performing a database backup only](docs/node_backup_restore.md#database-backup) 
      - #### []() 
  - ### [Restore Function](docs/node_backup_restore.md#performing-a-restore)

      - #### [Performing an in-place restore](docs/node_backup_restore.md#the-in-place-restore)
      - #### [Performing a full restore](docs/node_backup_restore.md#full-restore)
        - ##### [Key points to remember!](docs/node_backup_restore.md#key-points-to-remember)
        - ##### [How to perform a full restore](docs/node_backup_restore.md#how-to-perform-a-full-restore)
          - ###### [Setting system permissions](docs/node_backup_restore.md#setup-system-permissions)
          - ###### [Restoring the 'conf' file](docs/node_backup_restore.md#restore-the-conf-files)
          - ###### [Perform a fresh installation](docs/node_backup_restore.md#perform-a-fresh-node-deployment-install)
          - ###### [Restoring the 'db' file & verification](docs/node_backup_restore.md#restore-the-database)
  - ### [Script: Guide on how to integrate a legacy manual script deployment](docs/manual-script_integrate_bkup.md)

---
---
## Docker Method
  - ### [Docker: oneClick deployment](oneClickDeploy/README.md)


---
---
## Archived guides - For reference purposes only
   - #### [legacy manual script guide](docs/manual-script-deployment.md)
   - #### [node deployment 101 guide](docs/node_setup_101.md)