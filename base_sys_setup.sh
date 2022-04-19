#!/bin/bash

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

# Set Colour Vars
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


FUNC_VARS(){
## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #source sample.vars
    source ~/"plinode_$(hostname -f)".vars
}

FUNC_VALUE_CHECK(){
    
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}     Script Deployment menthod"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"



    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CONFIRM SCRIPTS VARIABLE DEFINITIONS HAVE BEEN UPDATED...${NC}"
    echo 
    # Ask the user acc for login details (comment out to disable)
    
        while true; do
            read -r -p "please confirm that you have updated this script with your values ? (y/n) " _input
            case $_input in
                [Yy][Ee][Ss]|[Yy]* ) 
                    #FUNC_BASE_SETUP
                    break
                    ;;
                [Nn][Oo]|[Nn]* ) 
                    FUNC_EXIT
                    ;;
                * ) echo "Please answer (y)es or (n)o.";;
            esac
        done
}    



FUNC_PKG_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CHECK NECESSARY PACKAGES HAVE BEEN INSTALLED...${NC}"
    echo     

    for i in "${BASE_SYS_PACKAGES[@]}"
    do
        hash $i &> /dev/null
        if [ $? -eq 1 ]; then
           echo >&2 "package "$i" not found. installing...."
           sudo apt install -y "$i"
        fi
        echo "packages "$i" exist. proceeding...."
    done
}



FUNC_SETUP_OS(){
    #FUNC_VARS;
    
    #echo -e "${GREEN}#########################################################################"
    #echo -e "${GREEN}#########################################################################"
    #echo -e "${GREEN}"
    #echo -e "${GREEN}     Script Deployment menthod"
    #echo -e "${GREEN}"
    #echo -e "${GREEN}#########################################################################"
    #echo -e "${GREEN}#########################################################################${NC}"


    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: System updates...${NC}"
    echo 
    sudo apt update -y && sudo apt upgrade -y

    #echo -e "${GREEN}#########################################################################"
    #echo
    #echo -e "${GREEN}## Setup: Install necessary apps...${NC}"
    #echo 
    #sudo apt install net-tools git curl locate ufw whois -y 
    #FUNC_PKG_CHECK;
    #sudo updatedb
    sleep 1s
}



FUNC_SETUP_USER(){

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: Add new local admin account with sudo access...${NC}"
    echo 
    #   Generate the encrypted password to be passed as follows;
    #   root@plitest:/# mkpasswd -m sha256crypt testpassword
    #   $5$HFpQR/kzgOONS$Uf6BwLbssmhByLLJFje/WV/vMT1TeGwH8CnLnoQV4XD
    #   root@plitest:/#

    sleep 1s
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Provide user details...${NC}"
    echo 
    # Ask the user acc for login details (comment out to disable - See Definitions section to hard code)
    read -p 'Enter Username: ' VAR_USERNAME
    read -sp 'Enter Password: ' VAR_PASSWORD

    encVAR_PASSWORD=$(mkpasswd -m sha256crypt $VAR_PASSWORD)

    sleep 2s
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: Creating the new acc user & group & adds to sudoers...${NC}"
    echo 
    sudo groupadd $VAR_USERNAME
    sudo useradd -p "$encVAR_PASSWORD" "$VAR_USERNAME" -m -s /bin/bash -g "$VAR_USERNAME" -G sudo

    echo -e "${GREEN}## Verify user account...${NC}"
    echo 
    sudo cat /etc/passwd | grep $VAR_USERNAME
    
    echo 
    echo 
    echo -e "${GREEN}## Verify user group...${NC}"
    echo 
    sudo cat /etc/group | grep $VAR_USERNAME

    sleep 1s

    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: Creating SSH keys for new acc user ${NC}"
    echo 

    cd /home/$VAR_USERNAME
    sudo mkdir -p .ssh 
    sudo touch .ssh/authorized_keys && sudo chmod 777 .ssh/authorized_keys

    # create private & public keys -- no user interaction -- comment added
    # to aid in identifying key usage/purpose. To add as password to private
    # key, simply remote the '-P ""' at the end of the command.
    # su $VAR_USERNAME
    
    sudo ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa_$VAR_USERNAME -C "pli_node $VAR_USERNAME" -q -P ""
    sudo cat .ssh/id_rsa_$VAR_USERNAME.pub >> .ssh/authorized_keys
    sudo chown $VAR_USERNAME:$VAR_USERNAME -R .ssh && sudo chmod 700 .ssh
    sudo chmod 600 .ssh/authorized_keys

    echo 
    echo -e "${RED}## IMPORTANT: Be sure to copy the private key to your local machine${NC}"
    echo -e "${RED}## IMPORTANT: where you will admin the node from & delete the private${NC}"
    echo -e "${RED}## IMPORTANT: key file from the PLI node${NC}"
    echo 

    # The ssh keys should ideally be generated on your local linux/mac workstation and then the 
    # public key file uploaded to the PLI node. The following code has been tested on this basis;
    # change the below values to suit your requirements - the publiy key is for the account you are
    # logging in with - in this case testuser123
    #
    # NOTE: This method depends on the ability to logon with Password Authentication enabled
    #
    ###  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_testuser123 -C "pli_node testuser123" -q -P ""
    ###  cat id_rsa_testuser123.pub | ssh testuser123@198.51.100.0 "mkdir -p ~/.ssh && chmod \
    ###  700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    ###

    sleep 3s
}



FUNC_SETUP_UFW_PORTS(){
    echo 
    echo 
    echo -e "${GREEN}#########################################################################" 
    echo 
    echo -e "${GREEN}## Base Setup: Configure Firewall...${NC}"
    echo 

    # Get current SSH port number 
    CPORT=$(sudo ss -tlpn | grep sshd | awk '{print$4}' | cut -d ':' -f 2 -s)
    #echo $CPORT
    sudo ufw allow $CPORT/tcp
    
    ## default ssh & non-standard ssh port
    #sudo ufw allow $PLI_SSH_DEF_PORT/tcp

    ## node local job server http/https ports
    sudo ufw allow $PLI_HTTP_PORT/tcp && sudo ufw allow $PLI_HTTPS_PORT/tcp
    sudo ufw status verbose
    sleep 2s
}



FUNC_ENABLE_UFW(){

    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo 
    echo -e "${GREEN}## Base Setup: Change UFW logging to ufw.log only${NC}"
    echo 
    # source: https://handyman.dulare.com/ufw-block-messages-in-syslog-how-to-get-rid-of-them/
    sudo sed -i -e 's/\#& stop/\& stop/g' /etc/rsyslog.d/20-ufw.conf
    sudo cat /etc/rsyslog.d/20-ufw.conf | grep '& stop'

    echo 
    echo 
    echo -e "${GREEN}#########################################################################" 
    echo 
    echo -e "${GREEN}## Setup: Enable Firewall...${NC}"
    echo 
    sudo systemctl start ufw && sudo systemctl status ufw
    sleep 2s
    echo "y" | sudo ufw enable
    #sudo ufw enable
    sudo ufw status verbose
}



FUNC_SETUP_SECURE_SSH(){
    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: Change SSH port & Secure Authentication methods...${NC}"
    echo 
    echo -e "${RED}# !! IMPORTANT: DO NOT close your existing ssh session..."
    echo -e "${RED}# !! Open a second connection to the new port with your existing ADMIN "
    echo -e "${RED}# !! or ROOT account - PASSWORD AUTH will be disabled from this point. ${NC}"
    
    sleep 3
    #read -p 'Enter New SSH Port to use: ' vNEW_SSH_PORT
    sudo sed -i.bak 's/#Port '"$PLI_SSH_DEF_PORT"'/Port '"$PLI_SSH_NEW_PORT"'/g' $SSH_CONFIG_PATH
    sudo sed -i.bak -e 's/\#PasswordAuthentication yes/PasswordAuthentication no/g' $SSH_CONFIG_PATH
    sudo sed -i.bak -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' $SSH_CONFIG_PATH
    sudo sed -i.bak -e 's/UsePAM yes/UsePAM no/g' $SSH_CONFIG_PATH
    
    

    echo 
    echo 
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: Add new SSH port to firewall...${NC}"
    echo
    sudo ufw allow $PLI_SSH_NEW_PORT/tcp

    echo
    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Base Setup: Restart SSH service for port change to take effect...${NC}"
    echo 
    sudo systemctl restart sshd && sudo systemctl status sshd
    sudo netstat -tpln | grep $PLI_SSH_NEW_PORT
    
    echo
    echo -e "${GREEN}#### Base System Setup Finished ####${NC}"
}



FUNC_EXIT(){
	exit 0
	}



FUNC_BASE_SETUP(){
    #FUNC_VALUE_CHECK;
    FUNC_SETUP_OS;
    FUNC_PKG_CHECK;
    FUNC_SETUP_UFW_PORTS;
    FUNC_ENABLE_UFW;
    FUNC_EXIT;
}  


FUNC_VARS;
case "$1" in
        -D)
                FUNC_BASE_SETUP
                ;;
        -os)
                FUNC_SETUP_OS
                ;;
        -user)
                FUNC_SETUP_USER
                ;;
        -ports)
                FUNC_SETUP_UFW_PORTS
                ;;
        -ufw)
                FUNC_ENABLE_UFW
                ;;
        -S)
                FUNC_SETUP_SECURE_SSH
                ;;
        *)

                echo 
                echo "Usage: $0 {function}"
                echo 
                echo "where {function} is one of the following;"
                echo 
                echo "      -D      ==  performs a normal base setup (excludes User acc & Securing SSH)"
                echo "                  -- this assumes you are installing under your current admin session (preferable not root)"
                echo
                echo "      -os     ==  perform OS updates & installs required packages (see sample.vars 'BASE_SYS_PACKAGES')"
                echo "      -user   ==  Adds a new admin account (to install the plugin node under) & SSH keys"
                echo "      -ports  ==  Adds required ports to UFW config (see sample.vars for 'PORT' variables )"
                echo "      -ufw    ==  Starts the UFW process, sets the logging to 'ufw.log' only & enables UFW service"
                echo 
                echo "      -S      ==  Secures the SSH service: "
                echo "                  -- sets SSH to use port number '$PLI_SSH_NEW_PORT' "
                echo "                  -- sets authentication method to SSH keys ONLY (Password Auth is disabled)"
                echo "                  -- adds port number '$PLI_SSH_NEW_PORT' to UFW ruleset"
                echo "                  -- restarts the SSH service to activate new settings (NOTE: Current session is unaffected)"
                echo 
                echo 
                echo 
esac