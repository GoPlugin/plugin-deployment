##Install Script for plugin nodes via Docker.

echo -e "\n\n## Plugin Docker Install -- https://goplugin.co -- made by nmzn (Twitter @itsnmzn) 01/2022\n"
echo -e "\n\n## Please make sure to read the readme.md after installing!!!"
echo -e "## Version 0.2 \n\n"
echo
echo -e "\n\n################# Updating System #################\n\n"

cd
sudo apt update && sudo apt upgrade -y

echo -e "\n\n################# Changing Directory #################\n\n"

sudo mkdir -p /opt/docker/goplugin
cd /opt/docker/goplugin

echo -e "\n\n################# getting git repositories #################\n\n"

sudo git clone -b docker_branch_v1 https://github.com/GoPlugin/plugin-deployment.git && cd plugin-deployment/
sudo git clone https://github.com/nmzn/pluginnode-docker.git && cd pluginnode-docker && sudo cp docker-compose.yaml /opt/docker/goplugin/plugin-deployment && cd ..

echo -e "\n\n################# installing latest docker compose #################\n\n"

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo -e "\n\n################# Changing Credentials #################\n\n"
echo
#### Node Login Credentials ###

     echo -e "Please type an Email adress to login to your node. Doesnt need to be related to the plugin login."
     echo
     until [[ "$mail" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]
     do
     echo
     read -p "Enter a valid Mail adress: " mail
     done
     echo
     echo "Mail adress is valid."
     echo
echo
while true; do
    echo "Please type a Password for your node login. (At least 7 characters with 2 upper case characters, 2 lower case characters, 2 digits and 1 special character."
    echo
    read -s -p "Enter Password: "  nodepw
    echo
    echo

    FAIL=no

    # 7 characters
    [[ ${#nodepw} -ge 7 ]] || FAIL=yes

    # 2 upper case letters
    echo $nodepw | grep -q "[A-Z].*[A-Z]" || FAIL=yes

    # 2 lower case letters
    echo $nodepw | grep -q "[a-z].*[a-z]" || FAIL=yes

    # 2 digits
    echo $nodepw | grep -q "[0-9].*[0-9]" || FAIL=yes

    # 1 non-alphanumeric character (no spaces)
    echo $nodepw | grep -q "[^a-zA-Z0-9]" || FAIL=yes

    [[ ${FAIL} == "no" ]] && break

    echo "Password invalid"
    echo
done

echo "Node Password is valid"
echo

### Postgres Password ###
echo
while true; do
    echo "Please type a Password for your Postgres Database. At least 4 characters with 1 Upper case, 1 lower case character and 1 digit. No Special Characters!"
    echo
    read -s -p "Enter Password: " pgrspw
    echo
    echo

    FAIL=no

    # 4 characters
    [[ ${#pgrspw} -ge 4 ]] || FAIL=yes

    # 1 upper case letters
    echo $pgrspw | grep -q "[A-Z]" || FAIL=yes

    # 1 lower case letters
    echo $pgrspw | grep -q "[a-z]" || FAIL=yes

    # 1 digits
    echo $pgrspw | grep -q "[0-9]" || FAIL=yes

    [[ ${FAIL} == "no" ]] && break

    echo "Postgres Password invalid"
    echo
done

echo "Postgres Password is valid"
echo

### Keystore Password ###
echo
while true; do
    echo "Please type your Keystore Password."
    echo "Password must be LONGER than 12 characters contain at least 3 upper case characters, 3 lower case characters, 3 numbers and 3 special characters (no spaces)"
    echo
    read -s -p "Enter Password: " kstpw
    echo
    echo

    FAIL=no

    # 12 characters
    [[ ${#kstpw} -ge 13 ]] || FAIL=yes

    # 3 upper case letters
    echo $kstpw | grep -q "[A-Z].*[A-Z].*[A-Z]" || FAIL=yes

    # 3 lower case letters
    echo $kstpw | grep -q "[a-z].*[a-z].*[a-z]" || FAIL=yes

    # 3 digits
    echo $kstpw | grep -q "[0-9].*[0-9].*[0-9]" || FAIL=yes

    # 3 non-alphanumeric character (no spaces)
    echo $kstpw | grep -q "[^a-zA-Z0-9].*[^a-zA-Z0-9].*[^a-zA-Z0-9]" || FAIL=yes

    [[ ${FAIL} == "no" ]] && break

    echo "Password invalid"
    echo
done

echo "Keystore Password is valid"
echo

echo -e "\nSetting Postgres Password"

sudo sed -i "s/plugin1234/$pgrspw/g"  plugin.env ei.env
sudo sed -i "s/plugin1234/$pgrspw/g"  docker-compose.yaml
sudo sed -i "s/\postgres\b/dbuser/g" plugin.env
sudo sed -i "s/\postgres\b/dbuser/g" ei.env
sudo sed -i "s|"172.17.0.1"|psql_node|g" plugin.env
sudo sed -i "s|"172.17.0.1"|psql_ei|g" ei.env

echo
echo -e "Done..."

echo -e "\nSetting api Credentials"

sudo sed -i d .env.apicred
sudo sh -c 'echo "mail@mail.com" > .env.apicred'
sudo sh -c 'echo "mailpw" >> .env.apicred'
sudo sed -i "s/mail\@mail.com/$mail/g" .env.apicred
sudo sed -i "s/mailpw/$nodepw/g" .env.apicred
echo
echo -e "Done..."

echo -e "\nSetting Keystore Password"

sudo sed -i d .env.password
sudo sh -c 'echo "keystore" > .env.password'
sudo sed -i "s/keystore/$kstpw/g" .env.password
echo
echo -e "Done..."

echo -e "\n\n################# Bringing up node & database #################\n\n"

sudo docker-compose up -d

echo -e "\n\n################# Starting Node #################\n\n"

sudo docker exec -it plinode /bin/bash -c ". ~/.profile && pm2 start /pluginAdm/startNode.sh"
echo
echo -e "Waiting for Node to come up... (10 Seconds)"
sleep 10
echo
echo -e "\n\n################# Installing External Initiators #################\n\n"

sudo docker exec -it plinode /bin/bash -c ". ~/.profile && plugin admin login -f /pluginAdm/.env.apicred"

JOBKEYS=$(sudo docker exec -it plinode /bin/bash -c ". ~/.profile && plugin initiators create pluginei http://localhost:8080/jobs" | grep pluginei)
sudo sh -c "echo $JOBKEYS > eivar.env"

ICACCESSKEY=$(echo $JOBKEYS | sed 's/\ //g' | awk -F"║" '{print $4};')
ICSECRET=$(echo $JOBKEYS | sed 's/\ //g' | awk -F"║" '{print $5};')
CIACCESSKEY=$(echo $JOBKEYS | sed 's/\ //g' | awk -F"║" '{print $6};')
CISECRET=$(echo $JOBKEYS | sed 's/\ //g' | awk -F"║" '{print $7};')

sudo sed -i "s|"cc763c8ca9fe48508883f6d39f818ccf"|$ICACCESSKEY|g" ei.env
sudo sed -i "s|"jEG8wzejfexfjAeZWBy8SzS7XV+SfV22j0eq7CEnyc6SSsd35PtQlESP2RhYs1am"|$ICSECRET|g" ei.env
sudo sed -i "s|"pKgKE+XNYbU2FRX207LObetsCx56bGPXenU3XpUelAdRb73bXBE22tSLjPviRUav"|$CIACCESSKEY|g" ei.env
sudo sed -i "s|"FXllNVlkD8ADVjFr46teIGRaeWEZXsYVQRMdfmu+UmRV4aysZ30E/OkNadysLZsA"|$CISECRET|g" ei.env

sudo docker exec --env-file ei.env -it plinode /bin/bash -c ". ~/.profile && pm2 start /pluginAdm/startEI.sh"


echo -e "\n\n################# Node Setup completed. Oracle Deployment Part has to be done manually. Please see: https://docs.goplugin.co for further information #################\n\n"
