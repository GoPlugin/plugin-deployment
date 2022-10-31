#!/bin/bash


# Get current user id and store as var
USER_ID=$(getent passwd $EUID | cut -d: -f1)

# Authenticate sudo perms before script execution to avoid timeouts or errors
sudo -l > /dev/null 2>&1

# Set the sudo timeout for USER_ID to expire on reboot instead of default 5mins
echo "Defaults:$USER_ID timestamp_timeout=-1" > /tmp/plisudotmp
sudo sh -c 'cat /tmp/plisudotmp > /etc/sudoers.d/plinode_deploy'

# Set Colour Vars
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

FDATE=$(date +"%Y_%m_%d_%H_%M")



FUNC_VARS(){
## VARIABLE / PARAMETER DEFINITIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    PLI_VARS_FILE="plinode_$(hostname -f)".vars
    if [ ! -e ~/$PLI_VARS_FILE ]; then
        #clear
        echo
        echo -e "${RED} #### NOTICE: No VARIABLES file found. ####${NC}"
        echo -e "${RED} ..creating local vars file '$HOME/$PLI_VARS_FILE' ${NC}"

        cp sample.vars ~/$PLI_VARS_FILE
        chmod 600 ~/$PLI_VARS_FILE

        echo
        echo -e "${GREEN}nano ~/$PLI_VARS_FILE ${NC}"
        #sleep 2s
    fi

    source ~/$PLI_VARS_FILE

    if [[ "$CHECK_PASSWD" == "true" ]]; then
        FUNC_PASSWD_CHECKS
    fi

}



FUNC_PKG_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## CHECK NECESSARY PACKAGES HAVE BEEN INSTALLED...${NC}"

    for i in "${REQ_PACKAGES[@]}"
    do
        hash $i &> /dev/null
        if [ $? -eq 1 ]; then
           echo >&2 "package "$i" not found. installing...."
           sudo apt install -y "$i"
        fi
        echo "packages "$i" exist. proceeding...."
    done

}



FUNC_VALUE_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## CONFIRM SCRIPTS VARIABLES FILE HAS BEEN UPDATED...${NC}"

    # Ask the user acc for login details (comment out to disable)
    CHECK_PASSWD=false
        while true; do
            read -t7 -r -p "please confirm that you have updated the vars file with your values ? (Y/n) " _input
            if [ $? -gt 128 ]; then
                #clear
                echo
                echo "timed out waiting for user response - proceeding as normal..."
                CHECK_PASSWD=true
                FUNC_NODE_DEPLOY;
            fi
            case $_input in
                [Yy][Ee][Ss]|[Yy]* ) 
                    CHECK_PASSWD=true
                    FUNC_NODE_DEPLOY
                    break
                    ;;
                [Nn][Oo]|[Nn]* ) 
                    FUNC_EXIT
                    ;;
                * ) echo "Please answer (y)es or (n)o.";;
            esac
        done
}




FUNC_PASSWD_CHECKS(){
    # check all credentials has been updated - if not auto gen
    
    SAMPLE_KEYSTORE='$oM3$tr*nGp4$$w0Rd$'
    # PASS_KEYSTORE value to compare against

    SAMPLE_DB_PWD="testdbpwd1234"
    # DB_PWD_NEW value to compare against
    
    
    SAMPLE_API_EMAIL="user123@gmail.com"
    # API EMAIL value to compare against
    
    SAMPLE_API_PASS='passW0rd123'
    # API PASSWORD value to compare against

    if ([ -z "$PASS_KEYSTORE" ] || [ "$PASS_KEYSTORE" == "$SAMPLE_KEYSTORE" ]); then
    
    echo 
    echo -e "${GREEN}     VARIABLE 'PASS_KEYSTORE' NOT UPDATED MANUALLY - AUTO GENERATING VALUE NOW"
    #echo -e "${GREEN}     YOUR NODE VARS FILE WILL BE UPDATED WITH THE GENERATED CREDENTIALS${NC}"
    sleep 2s

    #_AUTOGEN_KEYSTORE="'$(cat /dev/urandom | tr -dc 'a-zA-Z0-9%:+*!;.?=' | head -c32)'"
    _AUTOGEN_KEYSTORE="'$(./gen_passwd.sh -keys)'"
    sed -i 's/^PASS_KEYSTORE.*/PASS_KEYSTORE='"$_AUTOGEN_KEYSTORE"'/g' ~/"plinode_$(hostname -f)".vars
    PASS_KEYSTORE=$_AUTOGEN_KEYSTORE
    fi


    if ([ -z "$DB_PWD_NEW" ] || [ "$DB_PWD_NEW" == "$SAMPLE_DB_PWD" ]); then
    echo 
    echo -e "${GREEN}     VARIABLE 'DB_PWD_NEW' NOT UPDATED MANUALLY - AUTO GENERATING VALUE NOW"
    #echo -e "${GREEN}     YOUR NODE VARS FILE WILL BE UPDATED WITH THE GENERATED CREDENTIALS${NC}"
    sleep 2s

    #_AUTOGEN_DB_PWD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1)
    _AUTOGEN_DB_PWD="$(./gen_passwd.sh -db)"
    sed -i 's/^DB_PWD_NEW.*/DB_PWD_NEW=\"'"${_AUTOGEN_DB_PWD}"'\"/g' ~/"plinode_$(hostname -f)".vars
    DB_PWD_NEW=$_AUTOGEN_DB_PWD
    fi


    if ([ -z "$API_EMAIL" ] || [ "$API_EMAIL" == "$SAMPLE_API_EMAIL" ]); then
    
    echo 
    echo -e "${GREEN}     VARIABLE 'API_EMAIL' NOT UPDATED MANUALLY - AUTO GENERATING VALUE NOW"
    #echo -e "${GREEN}     YOUR NODE VARS FILE WILL BE UPDATED WITH THE GENERATED CREDENTIALS${NC}"
    sleep 2s

    _AUTOGEN_API_USER=$(tr -cd A-Za-z < /dev/urandom | fold -w10 | head -n1)
    API_EMAIL_NEW="$_AUTOGEN_API_USER@plinode.local"
    sed -i 's/^API_EMAIL.*/API_EMAIL=\"'"${API_EMAIL_NEW}"'\"/g' ~/"plinode_$(hostname -f)".vars
    API_EMAIL=$API_EMAIL_NEW
    fi



    if ([ -z "$API_PASS" ] || [ "$API_PASS" == "$SAMPLE_API_PASS" ]); then

    echo 
    echo -e "${GREEN}     VARIABLE 'API_PASS' NOT UPDATED MANUALLY - AUTO GENERATING VALUE NOW"
    #echo -e "${GREEN}     YOUR NODE VARS FILE WILL BE UPDATED WITH THE GENERATED CREDENTIALS${NC}"
    echo
    sleep 2s

    #_AUTOGEN_API_PWD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w18 | head -n1)
    _AUTOGEN_API_PWD="'$(./gen_passwd.sh -api)'"
    sed -i 's/^API_PASS.*/API_PASS='"${_AUTOGEN_API_PWD}"'/g' ~/"plinode_$(hostname -f)".vars
    API_PASS=$_AUTOGEN_DB_PWD
    fi

    # Update the system memory with the newly updated variables
    source ~/"plinode_$(hostname -f)".vars

}



FUNC_NODE_DEPLOY(){
    
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}                  Modular Deployment Script Method"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"
    
    # loads variables 
    FUNC_VARS;

    # call base_sys_setup script to perform basic system updates etc.
    bash base_sys_setup.sh -D

    echo
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## Install: check credentials are updated against default sample values...${NC}"
    FUNC_PASSWD_CHECKS;

    # installs default packages listed in vars file
    FUNC_PKG_CHECK;

    echo
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## Install: Clone repo to local install folder...${NC}"
     
    
    #if [ ! -d "/$PLI_BASE_DIR" ]; then
    #    sudo mkdir "/$PLI_BASE_DIR"
    #    #USER_ID=$(getent passwd $EUID | cut -d: -f1)
    #    sudo chown $USER_ID\:$USER_ID -R "/$PLI_BASE_DIR"
    #fi
    #cd /$PLI_BASE_DIR
    #git clone https://github.com/GoPlugin/plugin-deployment.git && cd plugin-deployment
    #rm -f {apicredentials.txt,password.txt}
    sleep 2s
    cd ~/$PLI_DEPLOY_DIR
    
    touch {$FILE_KEYSTORE,$FILE_API}
    chmod 666 {$FILE_KEYSTORE,$FILE_API}

    echo $API_EMAIL > $FILE_API
    echo $API_PASS >> $FILE_API
    echo $PASS_KEYSTORE > $FILE_KEYSTORE

    chmod 600 {$FILE_KEYSTORE,$FILE_API}

    # Remove the file if necessary; sudo rm -f {.env.apicred,.env.password}
    
    echo 
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## Install: UPDATE bash file $BASH_FILE1 with user values...${NC}"
    sed -i "s/$DB_PWD_FIND/'$DB_PWD_NEW'/g" ~/$PLI_DEPLOY_DIR/$BASH_FILE1
    #cat $BASH_FILE1 | grep 'postgres PASSWORD'
    sleep 3s
    
    echo 
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## Install: PRE-CHECKS for bash file $BASH_FILE1...${NC}"

    sudo apt remove --autoremove golang -y
    sudo rm -rf /usr/local/go

    echo 
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## Install: EXECUTE bash file $BASH_FILE1...${NC}"

    bash /$PLI_BASE_DIR/$PLI_DEPLOY_DIR/$BASH_FILE1

    echo 
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user CREDENTIALS values...${NC}"
    #cd ~/$PLI_DEPLOY_DIR/
    sed -i.bak "s/password.txt/$FILE_KEYSTORE/g" $BASH_FILE2
    sed -i.bak "s/apicredentials.txt/$FILE_API/g" $BASH_FILE2
    sed -i.bak "s/:postgres/:$DB_PWD_NEW/g" $BASH_FILE2
    sed -i.bak '/SECURE_COOKIES=false/d' $BASH_FILE2
    cat $BASH_FILE2 | grep node
    sleep 1s

     
    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user TLS values...${NC}"

    sed -i.bak "s/PLUGIN_TLS_PORT=0/PLUGIN_TLS_PORT=$PLI_HTTPS_PORT/g" $BASH_FILE2
    sed -i.bak "/^export PLUGIN_TLS_PORT=.*/a export TLS_CERT_PATH=$TLS_CERT_PATH/server.crt\nexport TLS_KEY_PATH=$TLS_CERT_PATH/server.key" $BASH_FILE2
    cat $BASH_FILE2 | grep TLS
    sleep 1s

    echo 
    echo -e "${GREEN}## Install: Create TLS CA / Certificate & files / folders...${NC}"

    mkdir $TLS_CERT_PATH && cd $TLS_CERT_PATH
    openssl req -x509 -out server.crt -keyout server.key -newkey rsa:4096 \
-sha256 -days 3650 -nodes -extensions EXT -config \
<(echo "[dn]"; echo CN=localhost; echo "[req]"; echo distinguished_name=dn; echo "[EXT]"; echo subjectAltName=DNS:localhost; echo keyUsage=digitalSignature; echo \
extendedKeyUsage=serverAuth) -subj "/CN=localhost"
    sleep 1s


    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with INITIATORS values...${NC}"

    sed -i.bak "/^ export DATABASE_TIMEOUT=.*/a export FEATURE_EXTERNAL_INITIATORS=true" $BASH_FILE2
    cat $BASH_FILE2 | grep INITIATORS
    sleep 1s


    echo 
    echo -e "${GREEN}## Install: Update '.profile' with string 'FEATURE_EXTERNAL_INITIATORS'...${NC}"

    isInFile=$(cat ~/.profile | grep -c "FEATURE_EXTERNAL_INITIATORS")
    if [ $isInFile -eq 0 ]; then
        echo "export FEATURE_EXTERNAL_INITIATORS=true" >> ~/.profile
        echo -e "${GREEN}## Success: '.profile' updated with string 'FEATURE_EXTERNAL_INITIATORS'...${NC}"
    else
        echo -e "${GREEN}## Skipping: '.profile' contains string 'FEATURE_EXTERNAL_INITIATORS'...${NC}"
    fi


    echo -e "${GREEN}## Install: Check Golang version & bash profile path...${NC}"

    source ~/.profile
    GO_VER=$(go version)
    go version; GO_EC=$?
    case $GO_EC in
        0) echo -e "${GREEN}## Command exited with NO error...${NC}"
            echo $GO_VER
            echo
            echo -e "${GREEN}## Install proceeding as normal...${NC}"
            ;;
        1) echo -e "${RED}## Command exited with ERROR - updating bash profile...${NC}"
            source ~/.profile;
            sudo sh -c 'echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile'
            echo "cat "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile"
            echo -e "${RED}## Check GO Version manually...${NC}"
            sleep 2s
            #FUNC_EXIT_ERROR
            #exit 1
            ;;
        *) echo -e "${RED}## Command exited with OTHER ERROR...${NC}"
            echo -e "${RED}## 'go version' returned : $GO_EC ${NC}"
            FUNC_EXIT_ERROR
            #exit 1
            ;;
    esac

    sleep 1s

    echo -e "${GREEN}## Install: Start PM2 $BASH_FILE2 & set auto start on reboot...${NC}"

    cd /$PLI_DEPLOY_PATH
    pm2 start $BASH_FILE2
    sleep 1s
    pm2 list 
    
    sleep 2s
    pm2 list
    pm2 startup systemd
    sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER_ID --hp /home/$USER_ID
    pm2 save

    # INTERACTIVE: Calls function to check if user wants to proceed to next stage of setup.
    #FUNC_DO_INIT_CHECK;

    # NON-INTERACTIVE: Proceed with next stage of setup.
    FUNC_EXPORT_NODE_KEYS;
    FUNC_INITIATOR;
    }


FUNC_EXPORT_NODE_KEYS(){

echo 
echo -e "${GREEN}#########################################################################${NC}"
echo -e "${GREEN}   export node keys - add current user to 'postgres' group"

sudo usermod -aG postgres $(getent passwd $EUID | cut -d: -f1)
sleep 2s
#echo 
#echo -e "${GREEN}#########################################################################${NC}"
echo 
echo -e   "${RED}######    IMPORTANT FILE - NODE ADDRESS EXPORT FOR WALLET ACCESS    #####${NC}"
echo -e   "${RED}######    IMPORTANT FILE - PLEASE SECURE APPROPRIATELY               #####${NC}"
echo 
echo -e "${GREEN}   export node keys - exporting keys to file: ~/"plinode_$(hostname -f)_keys_${FDATE}".json${NC}"
echo $(sudo -u postgres -i psql -d plugin_mainnet_db -t -c"select json from keys where id=1;")  > ~/"plinode_$(hostname -f)_keys_${FDATE}".json
 
echo -e "${GREEN}   export node keys - securing file permissions${NC}"

chmod 400 ~/"plinode_$(hostname -f)_keys_${FDATE}".json
sleep 4s
}






FUNC_INITIATOR(){
    FUNC_VARS;

    source ~/.profile

    if [ ! -d "/$PLI_DEPLOY_PATH/$PLI_INITOR_DIR" ]; then
        echo 
        echo -e "${GREEN}#########################################################################${NC}"
        echo -e "${GREEN}## CLONE & INSTALL LOCAL INITIATOR...${NC}"
        echo 

        # Added to resolve error running 'plugin help'
        source ~/.profile
    
        cd /$PLI_DEPLOY_PATH
        git clone https://github.com/GoPlugin/external-Initiator
        cd $PLI_INITOR_DIR
        git checkout main
        go install
    fi


    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}## CREATE / REPAIR  EXTERNAL INITIATOR...${NC}"
    
    sleep 3s
    export FEATURE_EXTERNAL_INITIATORS=true
    plugin admin login -f "/$PLI_DEPLOY_PATH/$FILE_API"
    if [ $? != 0 ]; then
      echo
      echo "ERROR :: Unable to Authenticate to Initiator API"
      echo "ERROR :: Re-run initiators function to resole - continuting deployment"
      sleep 5s
      #FUNC_EXIT_ERROR;
    else
      echo "INFO :: Successfully Authenticated to Initiator API"
    fi

    ### Check if intitator with name xdc already exists

    sleep 0.5s

    plugin initiators create $PLI_L_INIT_NAME http://localhost:8080/jobs > $PLI_INIT_RAWFILE 
    #&> /dev/null 2>&1
    if [ $? != 0 ]; then
      echo "ERROR :: Name $PLI_L_INIT_NAME already exists"
      plugin initiators destroy $PLI_L_INIT_NAME

      EI_FILE=$(echo "$BASH_FILE3" | sed -e 's/\.[^.]*$//')                       # cuts the file extension to get the namespace for pm2
      pm2 stop $EI_FILE && pm2 delete $EI_FILE && pm2 reset all && pm2 save       # deletes existing EI process 
      
      sleep 1s
      plugin initiators create $PLI_L_INIT_NAME http://localhost:8080/jobs > $PLI_INIT_RAWFILE 
    else
      echo "INFO :: Successfully created Initiator"
    fi


    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}## CAPTURE INITIATOR CREDENTIALS & FILE MANIPULATION...${NC}"

    sed -i 's/ ║ /,/g;s/╬//g;s/═//g;s/║//g' $PLI_INIT_RAWFILE
    sed -n '/'"$PLI_L_INIT_NAME"'/,//p' $PLI_INIT_RAWFILE > $PLI_INIT_DATFILE
    sed -i 's/,/\n/g;s/^.'"$PLI_L_INIT_NAME"'//g' $PLI_INIT_DATFILE
    sed -i 's/^http.*//g' $PLI_INIT_DATFILE
    sed -i.bak '/^$/d;/^\s*$/d;s/[ \t]\+$//' $PLI_INIT_DATFILE
    cp -n $PLI_INIT_DATFILE ~/$PLI_INIT_DATFILE.bak  && chmod 600 ~/$PLI_INIT_DATFILE.bak
    cat $PLI_INIT_DATFILE
    sleep 1s


    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}## READ INITIATOR CREDENTIALS AS VARIABLES...${NC}"
    echo 
    read -r -d '' EXT_ACCESSKEY EXT_SECRET EXT_OUTGOINGTOKEN EXT_OUTGOINGSECRET <$PLI_INIT_DATFILE

    sleep 2s

    echo
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}## CREATE INITIATOR PM2 SERVICE FILE: $BASH_FILE3 & file perms ${NC}"

    cd /$PLI_DEPLOY_PATH
    cat <<EOF > $BASH_FILE3
#!/bin/bash
export EI_DATABASEURL=postgresql://postgres:${DB_PWD_NEW}@127.0.0.1:5432/plugin_mainnet_db?sslmode=disable
export EI_CHAINLINKURL=http://localhost:6688
export EI_IC_ACCESSKEY=${EXT_ACCESSKEY}
export EI_IC_SECRET=${EXT_SECRET}
export EI_CI_ACCESSKEY=${EXT_OUTGOINGTOKEN}
export EI_CI_SECRET=${EXT_OUTGOINGSECRET}
echo *** Starting EXTERNAL INITIATOR ***
external-initiator "{\"name\":\"$PLI_E_INIT_NAME\",\"type\":\"xinfin\",\"url\":\"https://plixdcrpc.icotokens.net\"}" --chainlinkurl "http://localhost:6688/"
EOF
    #sleep 1s
    #cat $BASH_FILE3
    chmod u+x $BASH_FILE3


    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}## START INITIATOR PM2 SERVICE $BASH_FILE3 ${NC}"
    
    pm2 start $BASH_FILE3
    sleep 1s
    pm2 status
    sleep 3s
    pm2 startup systemd
    sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER_ID --hp /home/$USER_ID
    pm2 save

    if [ "$_OPTION" == "initiator" ]; then
        echo "CREATE / REPAIR  EXTERNAL INITIATOR COMPLETED"
        FUNC_EXIT;
    fi

    
    FUNC_LOGROTATE;
    

    if [ "$_OPTION" == "fullnode" ]; then
        echo "...INITIAL SETUP FOR BACKUP FOLDER & PERMS"
        bash ~/$PLI_DEPLOY_DIR/_plinode_setup_bkup.sh
    fi

    echo
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${RED}##  IMPORTANT INFORMATION - PLEASE RECORD TO YOUR PASSWORD SAFE${NC}"
    echo
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo
    echo -e "${RED}##  KEY STORE SECRET:        $PASS_KEYSTORE${NC}"
    echo
    echo -e "${RED}##  POSTGRES DB PASSWORD:    $DB_PWD_NEW${NC}"
    echo
    echo -e "${RED}##  API USERNAME:    $API_EMAIL${NC}"
    echo -e "${RED}##  API PASSWORD:    $API_PASS${NC}"
    echo
    echo -e "${GREEN}#########################################################################${NC}"
    echo -e "${GREEN}#########################################################################${NC}"
    
    #source ~/.profile
    #set -x
    source ~/.profile
    export GOROOT=/usr/local/go
    export GOPATH=$HOME/work
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    export FEATURE_EXTERNAL_INITIATORS=true
    . ~/.profile

    FUNC_NODE_ADDR;
    FUNC_NODE_GUI_IPADDR;
    FUNC_EXIT;
}




FUNC_DO_INIT_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## CONFIRM SCRIPTS EXPORT VALUES HAVE BEEN UPDATED...${NC}"
    
        while true; do
            read -t10 -r -p "Do you wish to proceed to INITIATOR SETUP ? (Y/n) " _input
            if [ $? -gt 128 ]; then
                echo "timed out waiting for user response - proceeding as normal..."
                FUNC_INITIATOR;
            fi
            case $_input in
                [Yy][Ee][Ss]|[Yy]* ) 
                    FUNC_INITIATOR
                    break
                    ;;
                [Nn][Oo]|[Nn]* ) 
                    FUNC_EXIT
                    ;;
                * ) echo "Please answer (y)es or (n)o."
                    echo "NOTE: timeout value is (y)es";;
            esac
        done
}


FUNC_LOGROTATE(){
    # add the logrotate conf file
    # check logrotate status = cat /var/lib/logrotate/status

    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}## ADDING LOGROTATE CONF FILE...${NC}"
    sleep 2s

    USER_ID=$(getent passwd $EUID | cut -d: -f1)

    if [ "$USER_ID" == "root" ]; then
        cat <<EOF > /tmp/tmpplugin-logs
/$USER_ID/.pm2/logs/*.log
/$USER_ID/.plugin/*.jsonl
/$USER_ID/.cache/*.logf
        {
            su $USER_ID $USER_ID
            rotate 10
            copytruncate
            daily
            missingok
            notifempty
            compress
            delaycompress
            sharedscripts
            postrotate
                    invoke-rc.d rsyslog rotate >/dev/null 2>&1 || true
            endscript
        }    
EOF
    else
        cat <<EOF > /tmp/tmpplugin-logs
/home/$USER_ID/.pm2/logs/*.log
/home/$USER_ID/.plugin/*.jsonl
/home/$USER_ID/.cache/*.logf
        {
            su $USER_ID $USER_ID
            rotate 10
            copytruncate
            daily
            missingok
            notifempty
            compress
            delaycompress
            sharedscripts
            postrotate
                    invoke-rc.d rsyslog rotate >/dev/null 2>&1 || true
            endscript
        }    
EOF
    fi

    sudo sh -c 'cat /tmp/tmpplugin-logs > /etc/logrotate.d/plugin-logs'

}


FUNC_NODE_ADDR(){
    cd ~/plugin-deployment
    plugin admin login -f .env.apicred
    node_keys_arr=()
    IFS=$'\n' read -r -d '' -a node_keys_arr < <( plugin keys eth list | grep Address && printf '\0' )
    node_key_primary=$(echo ${node_keys_arr[0]} | sed s/Address:[[:space:]]/''/)
    echo
    echo -e "${GREEN}Your Plugin node regular address is:${NC} ${RED}$node_key_primary ${NC}"
    echo
    echo -e "${GREEN}#########################################################################${NC}"
}


FUNC_NODE_GUI_IPADDR(){

    echo
    echo -e "${GREEN}Your Plugin node GUI IP address is as follows:${NC}"
    echo
    echo -e "            ${RED}https://$(hostname -I | awk '{print $1}'):6689${NC}"
    echo
    echo -e "${GREEN}#########################################################################${NC}"
}



FUNC_EXIT(){
    # remove the sudo timeout for USER_ID
    sudo sh -c 'rm -f /etc/sudoers.d/plinode_deploy'
    source ~/.profile
	exit 0
	}


FUNC_EXIT_ERROR(){
	exit 1
	}
  

#clear
case "$1" in
        fullnode)
                _OPTION="fullnode"
                FUNC_NODE_DEPLOY
                #FUNC_VALUE_CHECK
                ;;
        initiator)
                _OPTION="initiator"
                FUNC_INITIATOR
                ;;
        keys)
                FUNC_EXPORT_NODE_KEYS
                ;;
        logrotate)
                FUNC_LOGROTATE
                ;;
        address)
                FUNC_NODE_ADDR
                ;;
        node-gui)
                FUNC_NODE_GUI_IPADDR
                ;;
        *)
                
                echo 
                echo 
                echo "Usage: $0 {function}"
                echo 
                echo "    example: " $0 fullnode""
                echo 
                echo 
                echo "where {function} is one of the following;"
                echo 
                echo "      fullnode      ==  deploys the full node incl. external initiator & exports the node keys"
                echo 
                echo "      initiator     ==  creates / rebuilds the external initiator only"
                echo
                echo "      keys          ==  extracts the node keys from DB and exports to json file for import to MetaMask"
                echo
                echo "      logrotate     ==  implements the logrotate conf file "
                echo
                echo "      address       ==  displays the local nodes address (after fullnode deploy) - required for the 'Fulfillment Request' remix step"
                echo
                echo "      node-gui      ==  displays the local nodes full GUI URL to copy and paste to browser"
                echo
esac