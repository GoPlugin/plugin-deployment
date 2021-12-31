#!/bin/bash

echo "<<<<<<<<<------------------Installing Postgres -- STEP 1/2 Started--------------------->>>>>>>>>"
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get update
if [ $? -eq 0 ]
then
       echo "apt-get update: passed"
else
       echo "apt-get update: failed"
       echo "Fix the error"
       exit 1
fi
sudo apt-get install postgresql-12 -y -q
if [ $? -eq 0 ]
then
       echo "postgresql-12: passed"
else
       echo "postgresql-12: failed"
       echo "Fix the error"
       exit 1
fi
sudo systemctl start postgresql@12-main
#PG2=`pg_ctlcluster 12 main start`
if [ $? -eq 0 ]
then
       echo "postgresql@12-main: passed"
else
       echo "postgresql@12-main: failed"
       echo "Fix the error"
       exit 1
fi

POSTGRES_VERSION=`psql -V`
echo "<<<<<<<<<------------------Postgres version $POSTGRES_VERSION installed successfully -- STEP 1/9 Completed--------------------->>>>>>>>>"
#########################################Database creation
echo "<<<<<<<<<------------------Creating database - STEP 2/2 Started--------------------->>>>>>>>>"
sudo -u postgres psql -c "create database plugin_mainnet_db"
if [ $? -eq 0 ]
then
       echo "plugin_db creation: passed"
else
       echo "plugin_db creation: failed"
       exit 1
fi
sudo -u postgres psql -c "create database plugin_mainnet_ei"
if [ $? -eq 0 ]
then
       echo "plugin_ei creation: passed"
else
       echo "plugin_ei creation: failed"
       exit 1
fi
sudo -u postgres psql -c "alter user postgres PASSWORD 'plugin1234'"
if [ $? -eq 0 ]
then
       echo "Alter DB: passed"
else
       echo "Alter DB: failed"
       exit 1
fi
echo "<<<<<<<<<------------------Creating database - STEP 2/2 Completed--------------------->>>>>>>>>"
