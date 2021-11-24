#!/bin/bash
tryCatch()
{
	FNARG=("$@")
	echo ${FNARG[@]}
	IFS=',' read -ra GO_array <<< "${FNARG[@]}"
	for i in "${GO_array[@]}"
	do
		CMD=`$i`
		CMD_check=$?
		if [ $CMD_check -eq 0 ]
		then
		        echo "$i: passed"
		else
		        echo "$i: failed"
		        echo "Fix the failure and restart the script"
		        echo "Plugin installation: Abort"
		        exit 1
		fi
	done
}

echo `date` >>time.txt
START=$(date +%s);
#########################################OS check
echo "Setting up your local Plugin Node"
OS=`lsb_release -d | cut -f 2 | cut -d ' ' -f 1| grep -i 'ubuntu'`
OS_STATUS=$?
OS_VERSION=`lsb_release -r|cut -f 2|cut -d '.' -f 1`
if [ $OS_VERSION -ge 18 ] && [ $OS_STATUS -eq 0 ]
then
	echo "OS Compatibilty check: passed"
else
	echo "Your OS $OS $OS_VERSION is not compatible for Plugin installation\nOS compatibility check: failed\nRefer the doc provided"
	exit 1
fi
#########################################
#########################################GO installation
	
GO=(
'curl -O https://go.dev/dl/go1.17.3.linux-amd64.tar.gz',
#'curl -O https://dl.google.com/go/go1.15.13.linux-amd64.tar.gz',
#'sha256sum go1.15.13.linux-amd64.tar.gz',
'sha256sum go1.17.3.linux-amd64.tar.gz',
'tar xvf go1.17.3.linux-amd64.tar.gz',
#'tar xvf go1.15.13.linux-amd64.tar.gz',
'sudo chown -R root:root ./go',
'sudo mv go /usr/local'
)
echo "<<<<<<<<<------------------Installing Go packages -- STEP 1/9 Started--------------------->>>>>>>>>"
tryCatch ${GO[@]}
echo "export GOROOT=/usr/local/go
export GOPATH=\$HOME/work
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" >> ~/.profile
GO_var_set=$?
if [ $GO_var_set -eq 0 ]
then
	echo "Go env var set: passed"
else
	echo "Go env var set: failed"
	echo "Fix the error"
	exit 1
fi
. ~/.profile
if [ $? -eq 0 ]
then
	echo "Profile run set: passed"
else
	echo "Profile run set: failed"
	echo "Fix the error"
	exit 1
fi
GO_VERSION=`go version`
echo "<<<<<<<<<------------------$GO_VERSION installed successfully -- STEP 1/9 Completed--------------------->>>>>>>>>"
#########################################
#########################################NodeJs installation

Nodejs=(
	'curl https://deb.nodesource.com/setup_15.x -o setup_15.x',
                'sudo chmod 775 setup_15.x',
                'sudo -E ./setup_15.x',
	'sudo apt-get install -y nodejs'
)
echo "Installing NodeJs -- STEP 2/9 Started"
tryCatch ${Nodejs[@]}
NODE_VERSION=`node -v`
NPM_VERSION=`npm -v`
echo "Node version $NODE_VERSION and Npm version $NPM_VERSION installed successfully -- STEP 2/9 Completed--------------------->>>>>>>>>"
#########################################

#########################################NVM installation
NVM=(
	'curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh -o install.sh',
                'sudo chmod 775 install.sh',
                './install.sh'
)
echo "<<<<<<<<<------------------Installing NVM -- STEP 3/9 Started"
tryCatch ${NVM[@]}
#Close and open fix and not taking from script
NVM_VERSION=`nvm -v`
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
echo "<<<<<<<<<------------------NVM version $NVM_VERSION installed successfully -- STEP 3/9 Completed--------------------->>>>>>>>>"
#########################################
#########################################Yarn installation
echo "<<<<<<<<<------------------Installing Yarn -- STEP 4/9 Started--------------------->>>>>>>>>"
YARN=`sudo npm install --global yarn`
if [ $? -eq 0 ]
then
	echo "Yarn installation: passed"
else
	echo "Yarn installation: failed"
	echo "Fix the error"
	exit 1
fi
YARN_VERSION=`yarn -v`
echo "<<<<<<<<<------------------Yarn version $YARN_VERSION installed successfully -- STEP 4/9 Completed--------------------->>>>>>>>>"
#########################################
#########################################Postgresql installation
PG=(
	'sudo apt-get install -y postgresql-12',
	'sudo systemctl start postgresql@12-main'
)
	echo "<<<<<<<<<------------------Installing Postgres -- STEP 5/9 Started--------------------->>>>>>>>>"
PG1=`sudo apt-get install -y postgresql-12`
if [ $? -eq 0 ]
then
	echo "postgresql-12: passed"
else
	echo "postgresql-12: failed"
	echo "Fix the error"
	exit 1
fi
PG2=`sudo systemctl start postgresql@12-main`
if [ $? -eq 0 ]
then
	echo "postgresql@12-main: passed"
else
	echo "postgresql@12-main: failed"
	echo "Fix the error"
	exit 1
fi

POSTGRES_VERSION=`psql -V`
echo "<<<<<<<<<------------------Postgres version $POSTGRES_VERSION installed successfully -- STEP 5/9 Completed--------------------->>>>>>>>>"
#########################################
#########################################Plugin installation
echo "<<<<<<<<<------------------Downloading Plugin and setting it up - STEP 6/9 Started--------------------->>>>>>>>>"
PLI=(
        'git clone https://github.com/GoPlugin/Plugin.git'
)
tryCatch ${PLI[@]}
cd Plugin
if [ $? -eq 0 ]
then
	echo "cd Plugin: passed"
else
	echo "cd Plugin: failed"
	echo "Fix the error"
	exit 1
fi
sudo apt install make
if [ $? -eq 0 ]
then
	echo "apt install make: passed"
else
	echo "apt install make: failed"
	echo "Fix the error"
	exit 1
fi
sudo apt-get install -y build-essential
if [ $? -eq 0 ]
then
	echo "build-essential: passed"
else
	echo "build-essential: failed"
	echo "Fix the error"
	exit 1
fi
make install
if [ $? -eq 0 ]
then
	echo "make install: passed"
else
	echo "make install: failed"
	echo "Fix the error"
	exit 1
fi

echo "<<<<<<<<<------------------Downloading Plugin and setting it up - STEP 7/9 Completed--------------------->>>>>>>>>"
#########################################
#########################################Database creation
echo "<<<<<<<<<------------------Creating database - STEP 8/9 Started--------------------->>>>>>>>>"
sudo -u postgres psql -c "create database plugin_mainnet_db"
if [ $? -eq 0 ]
then
	echo "plugin_db creation: passed"
else
	echo "plugin_de creation: failed"
	exit 1
fi
sudo -u postgres psql -c "alter user postgres PASSWORD 'postgres'"
if [ $? -eq 0 ]
then
	echo "Alter DB: passed"
else
	echo "Alter DB: failed"
	exit 1
fi
echo "<<<<<<<<<------------------Creating database - STEP 9/9 Completed--------------------->>>>>>>>>"
#########################################
#########################################Plugin Node kickstart
#cd Plugin
echo `date` >>time.txt
END=$(date +%s);
echo "Time taken for execution: $((END-START)) seconds"
#########################################
echo "<<<<<<<<<------------------SET UP COMPLETED--------------------->>>>>>>>>"
echo "
      ################################################################################
      # 			IMPORTANT MESSAGE                                    #
      ################################################################################
      # Make sure you have the below mentioned 2  files are available and populated  #
      # as given below. Then start 'pm2 start 3_nodeStart.sh' script to run your node#
      # in the background. To view your node log use 'pm2 logs 0'.                   #
      #                                                                              #
      # File 1: password.txt => contains your keystore password                      #
      #           *** KEYSTORE PASSWORD SHOULD FOLLOW THIS CONDITIONS ***	     #
      #                   “must be longer than 12 characters”,			     #
      #			  “must contain at least 3 lowercase characters”,	     #
      # 		  “must contain at least 3 uppercase characters”,	     #
      #			  “must contain at least 3 numbers”,			     #
      #			  “must contain at least 3 symbols”,			     #
      # 		  “must not contain more than 3 identical consecutive 	     #
      #     		   characters”.						     #
      # File 2: apicredentials.txt => first line of the file contians email id for UI#
      #                              second line of the file contains password for UI#
      #				     (This passwrod should be strong, but need not   #
      #				      follow keystore password condition).	     #
      #										     #	
      # NOTE: This 2 files have default contents, please change the mail & passwords #
      #	      before starting 'pm2 start 2_nodeStartPM2.sh'.			     #
      ################################################################################
      ################################################################################"
