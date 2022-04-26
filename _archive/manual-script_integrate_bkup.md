alpha stage development

# Enabling backup script for legacy manual deployment

This document and the steps therein are aimed at operators that have deployed their nodes using the legacy manual script deployment method. 

The legacy manual script deployment method is defined as having created & edited the following files; as part of the medium articles & subsequent community member tutorials that referenced these same articles.

   - apicredentials.txt
   - password.txt

#### Legacy medium articles

   - https://medium.com/@GoPlugin/setup-a-plugin-node-automated-way-using-shell-script-fbdec48a0dea

---

## How to integrate the automated scripts

In order to utilise the backup script so that you can quickly recover your node to either the same VPS or an entirely different VPS with another provider, you need to perform a number of steps which are set out below.

### Integration steps

   1. Clone down the scripts repositoty from github

            cd $HOME
            git clone https://github.com/inv4fee2020/pli_node_conf.git
            cd pli_node_conf
            chmod +x *.sh

---

   2. Create the new vars file for your node
   
            cd ~/pli_node_conf && cp sample.vars ~/"plinode_$(hostname -f)".vars
            chmod 600 ~/"plinode_$(hostname -f)".vars

---

   3. Update the new vars file with your nodes credentials

      This is the important piece. When updating the vars file, it is critically important that you maintain the accuracy of credentials otherwise when you come to restore the node, you may discover issues related to incorrect credentials

      The following credentials must be updated into the new vars file;

      - KeyStore Password _(sourced from the password.txt file)_
      - Postgres Password _(sourced from the_ _2\_nodeStartPM2.sh file)_
      - API Username & Password _(sourced from the apicredentials.txt file)_


      +  The following variables inside the new vars file are what require updating with your values from above. 
      
         **IMPORTANT: You must ensure that formatting of each variable field it maintained.**

           *    PASS_KEYSTORE='$oM3$tr*nGp4$$w0Rd$'
           *    DB_PWD_NEW="testdbpwd1234"
           *    API_EMAIL="user123@gmail.com"
           *    API_PASS='passW0rd123'

         You will notice the variation in types of quotations that the values are wrapped in. This format *MUST* be maintained.


      Below is an example of the values generated & stored by the autosetup script;

      - PASS_KEYSTORE='Xqe7.?2p+8Ox.hOWQs+IMJYy!7ZJW+tF'
      - DB_PWD_NEW="s8kZVmapDgkwAEa5cbdgFU9XqcuZ3z"
      - API_EMAIL="VyfKJSPcwS@plinode.local"
      - API_PASS='Vw5hps4SPIcN6dWRDH'

      **_NOTE : The above values are taken from a private development host which is regularly erased_**

   To edit your new vars file using the guidelines set out above, run the command; 

         nano ~/"plinode_$(hostname -f)".vars
   
   In this example I use `nano` but you can replace this with the editor that you are more comfortable with e.g. vim, vi etc.


---

   4. Copy the legacy credentials files to conform with the updated standard.
      
      The following table shows the transform path from legacy to updated;

      Legacy | Updated
      :---: | :---: 
      |apicredentials.txt | .env.apicred
      |password.txt | .env.password

      run the following commands to achieve the file standardisation;

            cd ~/plugin-deployment
            cp apicredentials.txt .env.apicred
            cp password.txt .env.password

---

   5. Setup the backup folder & permissions.
   
            cd ~/pli_node_conf &&  ./_plinode_setup_bkup.sh


   6. [Perform a Full Backup of your node](node_backup_restore.md#performing-a-backup)
   7. Validate your backup with a restore to a temporary test / sandbox VPS