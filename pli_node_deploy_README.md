Full node deployment script for GoPlugin $PLI - SCRIPT METHOD.
===
> **NOTE: All values used in this code are for test purposes only & deployed to a test environment that is regularly deleted.**

> **NOTE: Please ensure that you update with your own values as necessary.**

---

# TL:DR

clone the repo to your local '$HOME' folder **Preferably as a normal user & _not as root_**

        cd $HOME
        git clone https://github.com/GoPlugin/plugin-deployment.git
        cd plugin-deployment
        chmod +x {1_prerequisite.bash,2_nodeStartPM2.sh,pli_node_deploy.sh}
        cp sample.vars ~/plinode_$(hostname -f).vars && chmod 600 ~/plinode_$(hostname -f).vars
        nano ~/plinode_$(hostname -f).vars

Update the the minimum variables (as per VARIABLES section below) 

Run the main script to do a full node deployment

        ./pli_node_deploy.sh fullnode



---
---
## VARIABLES file

A sample vars file is included 'sample.vars'.

This should be copied to your user $HOME folder using the following command;

>>>     cp sample.vars ~/"plinode_$(hostname -f).vars"

The scripts check that the local node variables file exists. If not then the code prompts the user and exists.
By using a dedicated variables file, any updates to the main script should not involve any changes to the node specific settings.

---

The following VARIABLES should be updated at a minimum for your individual implementation;

| VARIABLE |  NOTE |
|----------|-------|
|API_EMAIL="user123@gmail.com"||
|API_PASS="passW0rd123"|Must be 8 - 50 characters & NO special characters. (error creating api initializer)|
|PASS_KEYSTORE="Som3$tr*nGp4$$w0Rd"| Min. 12 characters, 3 lower, 3 upper, 3 numbers, 3 symbols & no more than 3 identical consecutive characters|
|DB_PWD_NEW="testdbpwd1234"|This is your new secure Postgres DB password & NO special characters|
|PLI_SSH_NEW_PORT="6222"| Change to suit your preference - should be a single value in the high range above 1025 & below 65535 e.g. 34022|

You can reveiw the 'sample.vars' file for the full list of VARIABLES.




---
---


## _pli_node_deploy.sh

This script performs file manipulations & executes the various plugin bash scripts in order 
to successfully deploy the node. 

The scripts has 2 main functions, one of which must be passed as an argument to run the script

>>>     fullnode
>>>     initiators

### Function: fullnode
As the name suggest, this executes all code to provision a full working node ready for the contract & jobs creation on remix.
This function calls the 'initiator' function as part of executing all code.


### Function: initiator
This function performs just the external initiator section and skips the main node deployment (assuming you have a base BASH_FILE2 process running ). 
The key aspect to this function is the API interaction & file manipulation to extract the access secrets/tokens and complete the registration process, vastly reducing the chances of any errors.



The script performs the following actions;

- Updates POSTGRES DB password using 'sed' find/replace on BASH_FILE1
- Removes existing Golang install as part of pre-requisite for BASH_FILE1
- Updates BASH_FILE2 to use new '.env' file structure & changes the POSTGRES password to that set in the VARS file
- Updates BASH_FILE2 with TLS certificate files & TLS Port
- Creates local certificate authority & TLS certificate for use with the local job server
- Updates BASH_FILE2 with EXTERNAL_INITIATORS parameter
- Checks for the Golang path & updates bash profile as necessary
- Initialises the BASH_FILE2 PM2 service & sets PM2 to auto start on boot
- External Initiators install & setup
- Performs authentication to the plugin module & generates the initiator keys which are output to file 
    - 2 files are created as part of this process 'pli_init.raw' & 'pli_init.dat' 
- Manipulates the stored keys file & transfers to VARIABLES
    - 'pli_init.dat' is the resulting data file which passes values to the VARS
    - this data file is also copied to the users home folder as a backup in case required later (& chmod 600)
- Generates the BASH_FILE3 file required to run the Initiator process
- Initialises the BASH_FILE3 PM2 service & updates PM2 to auto start on boot
