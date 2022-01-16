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
    # Get current user id and store as var
    USER_ID=$(getent passwd $EUID | cut -d: -f1)


    PLI_VARS_FILE="plinode_$(hostname -f)".vars
    if [ ! -e ~/$PLI_VARS_FILE ]; then
        clear
        echo
        echo
        echo -e "${RED} #### ERROR: No VARIABLES file found. ####${NC}"
        echo
        echo -e "${RED} ..creating local vars file '$HOME/$PLI_VARS_FILE' ${NC}"
        cp sample.vars ~/$PLI_VARS_FILE
        echo
        echo -e "${GREEN} please update the vars file with your specific values.. ${NC}"
        echo -e "${GREEN} copy command to edit: ${NC}"
        echo
        echo -e "${GREEN}nano ~/$PLI_VARS_FILE ${NC}"
        echo
        echo
        #sleep 2s
        exit 1
    fi
    source ~/$PLI_VARS_FILE

}



FUNC_PKG_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CHECK NECESSARY PACKAGES HAVE BEEN INSTALLED...${NC}"
    echo     

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
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}     Script Deployment menthod"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"



    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CONFIRM SCRIPTS VARIABLES FILE HAS BEEN UPDATED...${NC}"
    echo 
    # Ask the user acc for login details (comment out to disable)
    
        while true; do
            read -t7 -r -p "please confirm that you have updated the vars file with your values ? (Y/n) " _input
            if [ $? -gt 128 ]; then
                clear
                echo
                echo "timed out waiting for user response - proceeding as normal..."
                FUNC_NODE_DEPLOY;
            fi
            case $_input in
                [Yy][Ee][Ss]|[Yy]* ) 
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



FUNC_NODE_DEPLOY(){
    FUNC_VARS;
    
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}"
    echo -e "${GREEN}     Script Deployment menthod"
    echo -e "${GREEN}"
    echo -e "${GREEN}#########################################################################"
    echo -e "${GREEN}#########################################################################${NC}"
    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: Credentials files prep...${NC}"
    echo 
    
    touch {$FILE_KEYSTORE,$FILE_API}
    chmod 666 {$FILE_KEYSTORE,$FILE_API}

    echo $API_EMAIL > $FILE_API
    echo $API_PASS >> $FILE_API
    echo $PASS_KEYSTORE > $FILE_KEYSTORE

    chmod 600 {$FILE_KEYSTORE,$FILE_API}

    # Remove the file if necessary; sudo rm -f {.env.apicred,.env.password}



    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: UPDATE bash file $BASH_FILE1 with user values...${NC}"
    echo 

    sed -i.bak "s/$DB_PWD_FIND/'$DB_PWD_NEW'/g" $BASH_FILE1
    #cat $BASH_FILE1 | grep 'postgres PASSWORD'
    #sleep 1s


    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: PRE-CHECKS for bash file $BASH_FILE1...${NC}"
    echo 

    sudo apt remove --autoremove golang -y
    sudo rm -rf /usr/local/go


    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: EXECUTE bash file $BASH_FILE1...${NC}"
    echo 

    bash $BASH_FILE1

    echo 
    echo 

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user CREDENTIALS values...${NC}"
    echo 

    sed -i.bak "s/password.txt/$FILE_KEYSTORE/g" $BASH_FILE2
    sed -i.bak "s/apicredentials.txt/$FILE_API/g" $BASH_FILE2
    sed -i.bak "s/:postgres/:$DB_PWD_NEW/g" $BASH_FILE2
    sed -i.bak '/SECURE_COOKIES=false/d' $BASH_FILE2
    cat $BASH_FILE2 | grep node
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with user TLS values...${NC}"
    echo 

    sed -i.bak "s/PLUGIN_TLS_PORT=0/PLUGIN_TLS_PORT=$PLI_HTTPS_PORT/g" $BASH_FILE2
    sed -i.bak "/^export PLUGIN_TLS_PORT=.*/a export TLS_CERT_PATH=$TLS_CERT_PATH/server.crt\nexport TLS_KEY_PATH=$TLS_CERT_PATH/server.key" $BASH_FILE2
    cat $BASH_FILE2 | grep TLS
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}## Install: Create loca Certificate Authority / TLS Certificate & files / folders...${NC}"
    echo 

    
    mkdir $TLS_CERT_PATH && cd $TLS_CERT_PATH
    openssl req -x509 -out server.crt -keyout server.key -newkey rsa:4096 \
-sha256 -days 3650 -nodes -extensions EXT -config \
<(echo "[dn]"; echo CN=localhost; echo "[req]"; echo distinguished_name=dn; echo "[EXT]"; echo subjectAltName=DNS:localhost; echo keyUsage=digitalSignature; echo \
extendedKeyUsage=serverAuth) -subj "/CN=localhost"
    sleep 1s



    echo 
    echo 
    echo -e "${GREEN}## Install: Update bash file $BASH_FILE2 with INITIATORS values...${NC}"
    echo 
    sed -i.bak "/^ export DATABASE_TIMEOUT=.*/a export FEATURE_EXTERNAL_INITIATORS=true" $BASH_FILE2
    cat $BASH_FILE2 | grep INITIATORS
    sleep 1s


    echo -e "${GREEN}## Install: Check Golang version & bash profile path...${NC}"
    echo 
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
            echo
            source ~/.profile;
            sudo sh -c 'echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile'
            echo "cat "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile"
            echo
            echo -e "${RED}## Check GO Version manually...${NC}"
            sleep 2s
            #FUNC_EXIT_ERROR
            #exit 1
            ;;
        *) echo -e "${RED}## Command exited with OTHER ERROR...${NC}"
            echo -e "${RED}## 'go version' returned : $GO_EC ${NC}"
            echo
            FUNC_EXIT_ERROR
            #exit 1
            ;;
    esac

    sleep 1s


    echo -e "${GREEN}## Install: Start PM2 $BASH_FILE2 & set auto start on reboot...${NC}"
    echo 
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
    FUNC_INITIATOR;
    }








FUNC_INITIATOR(){
    FUNC_VARS;


    
    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CLONE & INSTALL LOCAL INITIATOR...${NC}"
    echo 

    # Added to resolve error running 'plugin help'
    source ~/.profile
    
    cd /$PLI_DEPLOY_PATH
    git clone https://github.com/GoPlugin/external-Initiator
    cd $PLI_INITOR_DIR
    git checkout main
    go install



    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CREATE LOCAL INITIATOR...${NC}"
    echo 
    export FEATURE_EXTERNAL_INITIATORS=true
    plugin admin login -f "../$FILE_API"
    sleep 0.5s
    plugin initiators create $PLI_L_INIT_NAME http://localhost:8080/jobs > $PLI_INIT_RAWFILE

    # plugin initiators create xdc http://localhost:8080/jobs
    # plugin initiators destroy xdc http://localhost:8080/jobs
    # plugin initiators create xdc http://localhost:8080/jobs > $PLI_INIT_RAWFILE


    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CAPTURE INITIATOR CREDENTIALS & FILE MANIPULATION...${NC}"
    echo 
    sed -i 's/ ║ /,/g;s/╬//g;s/═//g;s/║//g' $PLI_INIT_RAWFILE
    sed -n '/'"$PLI_L_INIT_NAME"'/,//p' $PLI_INIT_RAWFILE > $PLI_INIT_DATFILE
    sed -i 's/,/\n/g;s/^.'"$PLI_L_INIT_NAME"'//g' $PLI_INIT_DATFILE
    sed -i 's/^http.*//g' $PLI_INIT_DATFILE
    sed -i.bak '/^$/d;/^\s*$/d;s/[ \t]\+$//' $PLI_INIT_DATFILE
    cp $PLI_INIT_DATFILE ~/$PLI_INIT_DATFILE.bak  && chmod 600 ~/$PLI_INIT_DATFILE.bak
    cat $PLI_INIT_DATFILE
    sleep 1s


    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## READ INITIATOR CREDENTIALS AS VARIABLES...${NC}"
    echo 
    read -r -d '' EXT_ACCESSKEY EXT_SECRET EXT_OUTGOINGTOKEN EXT_OUTGOINGSECRET <$PLI_INIT_DATFILE
    echo
    #echo "$EXT_ACCESSKEY"
    #echo "$EXT_SECRET"
    #echo "$EXT_OUTGOINGTOKEN"
    #echo "$EXT_OUTGOINGSECRET"
    sleep 1s


    echo
    echo
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## CREATE INITIATOR PM2 SERVICE FILE: $BASH_FILE3 & file perms ${NC}"
    echo
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
external-initiator "{\"name\":\"$PLI_E_INIT_NAME\",\"type\":\"xinfin\",\"url\":\"https://pluginrpc.blocksscan.io\"}" --chainlinkurl "http://localhost:6688/"
EOF
    sleep 1s
    cat $BASH_FILE3
    chmod u+x $BASH_FILE3


    echo 
    echo 
    echo -e "${GREEN}#########################################################################${NC}"
    echo
    echo -e "${GREEN}## START INITIATOR PM2 SERVICE $BASH_FILE3 ${NC}"
    echo    
    pm2 start $BASH_FILE3
    sleep 1s
    pm2 status
    sleep 3s
    pm2 startup systemd
    sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER_ID --hp /home/$USER_ID
    pm2 save

    FUNC_EXIT;
}






FUNC_DO_INIT_CHECK(){

    echo -e "${GREEN}#########################################################################"
    echo
    echo -e "${GREEN}## CONFIRM SCRIPTS EXPORT VALUES HAVE BEEN UPDATED...${NC}"
    echo 
    
        while true; do
            read -t10 -r -p "Do you wish to proceed to INITIATOR SETUP ? (Y/n) " _input
            if [ $? -gt 128 ]; then
                #clear
                echo
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




FUNC_EXIT(){
	exit 0
	}



FUNC_EXIT_ERROR(){
	exit 1
	}
  
#FUNC_VALUE_CHECK;

clear
case "$1" in
        fullnode)
                FUNC_VALUE_CHECK
                ;;
        initiator)
                FUNC_INITIATOR
                ;;
        *)
                
                echo 
                echo 
                echo "Usage: $0 {fullnode|initiator}"
                echo 
                echo "please provide one of the above values to run the scripts"
                echo "    example: " $0 fullnode""
                echo 
                echo 
esac