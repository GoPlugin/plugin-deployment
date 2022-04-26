#!/bin/bash

# Set Colour Vars
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

    echo -e "${RED}#########################################################################"
    echo -e "${RED}#########################################################################"
    echo -e "${RED}"
    echo -e "${RED}        !!  WARNING  !!${NC} Plugin Node Reset Script ${RED}!!  WARNING  !!${NC}"
    echo -e "${RED}"
    echo -e "${RED}#########################################################################"
    echo -e "${RED}#########################################################################${NC}"
    echo
    echo
    echo



    # Ask the user acc for login details (comment out to disable)
    CHECK_PASSWD=false
        while true; do
            read -t10 -r -p ":: DESTRUCTIVE :: Confirm that you wish to RESET your Plugin node installation ? (Y/n) " _input
            if [ $? -gt 128 ]; then
                #clear
                echo
                echo "timed out waiting for user response - quitting..."
                exit 0
            fi
            case $_input in
                [Yy][Ee][Ss]|[Yy]* )
                    break
                    ;;
                [Nn][Oo]|[Nn]* ) 
                    exit 0
                    ;;
                * ) echo "Please answer (y)es or (n)o.";;
            esac
        done


# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

# Get local hostname and load the vars file
PLI_VARS_FILE="plinode_$(hostname -f).vars"
source ~/$PLI_VARS_FILE


echo -e "${GREEN} ~~ Performing fresh keys export ~~${NC}"
./pli_node_scripts.sh keys

##  Rough script to roll back installation for testing purposes...
## Use with caution !
#sudo su

# Stop & Delete all active PM2 processes
pm2 stop all && pm2 delete all

# Stop the POSTGRES service
sudo systemctl stop postgresql

# Delete folders for; Go install, plugin-deployment install, POSTGRES.
sudo rm -rf /usr/local/go
sudo rm -rf /$PLI_DEPLOY_PATH

sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && sudo rm -rf /etc/postgresql-common/

# Remove the POSTGRES packages & clean up linked packages
sudo apt --purge remove postgresql* -y && sudo apt purge postgresql* -y 
sudo apt --purge remove postgresql -y postgresql-doc -y postgresql-common -y
sudo apt autoremove -y

# Clean up any remaining folders 
sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /etc/postgresql/ && sudo rm -rf /etc/postgresql-common/

# Remove the POSTGRES install system account & group
sudo userdel -r postgres && sudo groupdel postgres

# Remove the group for local backups
sudo groupdel nodebackup

# Remove all plugin, nodejs linked folders for current user & root
cd ~/; sudo sh -c "rm -rf .cache/ && rm -rf .nvm && rm -rf .npm && rm -rf .plugin && rm -rf Plugin && rm -rf .pm2 && rm -rf work && rm -rf go && rm -rf .yarn*"
rm ~/.tmp_profile

# Remove logrotate file
sudo sh -c 'rm -f /etc/logrotate.d/plugin-logs'

echo
echo
echo
echo
echo -e "${RED} Be sure to manually update your '~/.profile' file for remaining variables...${NC}"
echo
echo
echo
