# pli_node_conf
Modular scripts for @GoPlugin ($PLI) node setup & maintenance.

### contributers: 
A very special thanks & shout out to the following discord members for their input & testing;
- @samsam
- @go140point6
---

> **NOTE: All values used in this code are for test purposes only & deployed to a test environment that is regularly deleted.**

> **NOTE: Please ensure that you update with your own values as necessary.**

---

# TL;DR - Fully Automated Installation

*_Update 28.03.22 : code moved to performing automated installation by default. Operators that wish to use their own credentials should still continue to update the vars file manually before excuting the main script._*

...

The [node automated setup](node_autosetup.md) builds upon the previous 'node setup 101' guide in terms of the base linux system setup but removes the need for any vars file updates or seperate commands and prompts.


Simply follow the steps in the [node automated setup](node_autosetup.md) & have a working node in approx 20-30mins _(depending on system specs)_ ready for you to perform your REMIX contract & jobs config steps.

---
|**NOTE : !! Be sure to perform a [Full Backup](node_backup_restore.md) of your system once it has been approved !!**|
|---|
---


The following youtube shows the entire process from a fresh VPS installation to a running node based on the above setup steps;
 - [pli node deployment - automated script method](https://youtu.be/wOKA24sLmPM)



...
...

_NOTE: The above replaces most of the steps set out in the [node setup 101 steps](node_setup_101.md). This link is included for completeness and reference on base setup steps etc. Further updates to the steps will be added._

---

> When connecting to your nodes plugin GUI as outlined in ['fund your node'](https://docs.goplugin.co/plugin-installations/fund-your-node), you must use *_'https://your_node_ip:6689'_* instead due to the configuration applied by the [main script](#main-script-actions)


Accompanying youtube of the 'node setup 101' process for specific VPS providers;


 - ['Ethernetservers VPS 1x vCPU + 2.5GBRAM + 70GB SSD - setup using node setup 101'](https://www.youtube.com/watch?v=IubKHAVoNTo)


---
---
## VARIABLES file

A sample vars file is included 'sample.vars'. This file will be copied to your user $HOME folder as part of the main script and the permissions to the file updated to restrict access to the owner of the $HOME folder.

The scripts check that the local node variables file exists.

By using a dedicated variables file, any updates to the main script should not involve any changes to the node specific settings.

---

The following VARIABLES should be updated at a minimum for your individual implementation;

| VARIABLE |  NOTE |
|----------|-------|
|API_EMAIL="user123@gmail.com"||
|API_PASS='passW0rd123'|Must be 8 - 50 characters & NO special characters. (error creating api initializer)|
|PASS_KEYSTORE="$oM3$tr*nGp4$$w0Rd$"| Min. 12 characters, 3 lower, 3 upper, 3 numbers, 3 symbols & no more than 3 identical consecutive characters|
|DB_PWD_NEW="testdbpwd1234"|This is your new secure Postgres DB password & NO special characters|

You can reveiw the 'sample.vars' file for the full list of VARIABLES.




---
---
## pli_node_scripts.sh (main script)

This script performs file manipulations & executes the various plugin bash scripts in order 
to successfully deploy the node. 

The scripts has a number of functions, one of which must be passed to run the scripts

>     fullnode
>     initiators
>     keys
>     logrotate
>     address

### Usage

        Usage: ./pli_node_scripts.sh {function}
            example:  ./pli_node_scripts.sh fullnode

        where {function} is one of the following;

              fullnode      ==  deploys the full node incl. external initiator & exports the node keys
              initiator     ==  Create / Rebuild the external initiator only
              keys          ==  extracts the node keys from DB and exports to json file
              logrotate     ==  implements the logrotate conf file
              address       ==  displays the local nodes address (after fullnode deploy) - required for the 'Fulfillment Request' remix step

### Function: fullnode

As the name suggest, this executes all code to provision a full working node ready for the contract & jobs creation on remix.
This function calls all other function as part of deploying the full node.


### Function: initiator
This function performs just the external initiator section and skips the main node deployment. 

The key aspect to this function is the file manipulation to extract the access secrets/tokens and complete the registration process vastly reducing the chances of any errors.

This function has also been enhanced to accommodate scenarios where the initiator does not deploy correctly.  Running this command with perform necessary checks & rebuild the external initiator.  

Testing the external initiator after a rebuild should be performed using the test alarm clock job with a dummy OCA eg 'xdcthisisadummyoca';

        ./job_alarmclock_test.sh


This test should return a job id to the terminal screen as follows;  

        Local node Alarm Clock Sample job id - Copy to your Solidity script
        =================================================================
       
        Your Oracle Contract Address is   : 0xthisisadummyoca
        Your Alarm Clock Sample Job ID is : 735e293770ce462eb010ec10dff8e5c6   <<<<<<<<<<<



### Function: keys

This function exports the node address keys to allow you to access any funds that have been added to the node. This is important in scenarios where an operator wishes to rebuild a node or where they may have simply added too much funds to the node address.

The output json file (example below) is then imported to MM as per step 5 of ['Withdraw PLI from Plugin Node'](https://docs.goplugin.co/node-operators/withdraw-pli-from-plugin-node#step-5-now-choose-import-account-and-select-json-file-as-type.-pass-word-should-be-same-as-your-keys) of the offical docs.


### Function: logrotate

This function implements the necessary logrotate configuration to aid with the management of the nodes PM2 logs. By default the logging level is DEBUGGING and so if left un-checked, these logs will eventually consume all available disk space.

**NOTE: logs are set to rotate every 10 days.**

to check the state of the logrotate config, issue the following cmd;
        
        sudo cat /var/lib/logrotate/status | grep -i pm2 


### Function: Address

This function obtains the local nodes primary address. This is necessary for remix fulfillment & node submissions tasks.

        nmadmin@plitest:~/pli_node_conf$ ./pli_node_scripts.sh address

        Your Plugin node regular address is: 0x160C2b4b7ea040c58D733feec394774A915D0cb5

        #########################################################################


**_NOTE: The script uses a base install folder is your linux users $HOME folder - which is now set as a VARIABLE._**
#### Main script actions
The script performs the following actions;

- Updates Postgres DB password 'sed' find/replace on BASH_FILE1
- Removes existing Golang install as part of pre-requisite for BASH_FILE1
- Updates BASH_FILE2 to use new '.env' files & Postgres password
- Updates BASH_FILE2 with TLS certificate files & TLS Port
- Creates local certificate authority & TLS certificate for use with local job server (enabling HTTPS)
- Updates BASH_FILE2 with EXTERNAL_INITIATORS parameter
- Checks for the Golang path & updates bash profile as necessary
- Initialises the BASH_FILE2 PM2 service & sets PM2 to auto start on boot
- External Initiators install & setup
- Performs authentication the plugin module & generates the initiator keys & output to file
- Manipulates the stored keys file & transfers to VARIABLES
- Auto generates the BASH_FILE3 file required to run the Initiator process
- Initialises the BASH_FILE3 PM2 service & updates PM2 to auto start on boot


---
---


## reset_pli.sh

**WARNING:: USE WITH CAUTION**

As the name suggests this script does a full reset of you local Plugin installation.

User account deletion: The script does _NOT_ delete any other user or system accounts beyond that of _'postgres'_.

Basic function is to;

- stop & delete all PM2 processes
- stop all postgress services
- uninstall all postgres related components
- delete all postgres related system folders
- remove the postgres user & group
- delete all plugin installaton folders under the users $HOME folder

This script resets your VPS to a pre-deployment state, allowing you to re-install the node software without reseting the VPS system.


---
---


## base_sys_setup.sh (_Optional - Recommended_)

Updated to use modular functions allowing for individial functions to be run or 
You can reveiw the 'sample.vars' file for the full list of VARIABLES.

This script performs OS level commands as follows;

- Apply ubuntu updates
- Install misc. services & apps e.g. UFW, Curl, Git, locate 
- New Local Admin user & group (Choice of interactive user input OR hardcode in VARS definition)
- SSH keys for the above 
- Applies UFW firewall minimum configuration & starts/enables service
- Modifies UFW firewall logging to use only the ufw.log file
- Modify SSH service to use alternate service port, update UFW & restart SSH

_You can reveiw the 'sample.vars' file for the full list of VARIABLES._
### Usage

        Usage: ./base_sys_setup.sh {function}

        where {function} is one of the following;

              -D      ==  performs a normal base setup (excludes User acc & Securing SSH)"
                          -- this assumes you are installing under your current admin session (preferable not root)"

              -os     ==  perform OS updates & installs required packages (see sample.vars 'BASE_SYS_PACKAGES')
              
              -user   ==  Adds a new admin account (to install the plugin node under) & SSH keys

              -ports  ==  Adds required ports to UFW config (see sample.vars for 'PORT' variables )
                          -- Dynamically finds current active ssh port & adds to UFW ruleset

              -ufw    ==  Starts the UFW process, sets the logging to 'ufw.log' only & enables UFW service

              -S      ==  Secures the SSH service:
                          -- sets SSH to use port number 'your_defined_new_port'
                          -- sets authentication method to SSH keys ONLY (Password Auth is disabled)
                          -- adds port number 'your_defined_new_port' to UFW ruleset
                          -- restarts the SSH service to activate new settings (NOTE: Current session is unaffected)

*_NOTE: The script does read the local node specific vars file._*

---
---

## Refreshing your local repo

As the code is updated it will be necessary to update your local repo from time to time. To do this you have two options;

1. Force git to update the local repo by overwriting the local changes, which in this case are the file permission changes. Copy and paste the following code;
        
        cd ~/pli_node_conf
        git fetch
        git reset --hard HEAD
        git merge '@{u}'
        chmod +x *.sh



   _source: https://www.freecodecamp.org/news/git-pull-force-how-to-overwrite-local-changes-with-git/_


2. Manually delete the folder and re-run the clone & permissions commands. Copy and paste the following code;
        
        cd $HOME
        rm -rf pli_node_conf
        git clone https://github.com/inv4fee2020/pli_node_conf.git
        cd pli_node_conf
        chmod +x *.sh
        




*_NOTE: None of the above steps will overwrite your local nodes variables file as it is stored in your $HOME folder._*

---
## Testing

The scripts have been developed on ubuntu 20.x linux distros deployed within both a vmware esxi environment & racknerd VPS.

Full deployment of the base node & external initiators was recorded at 15mins on racknerd with no user interaction. 