Running the node through docker container minimize the hassles to install the required utilities to run the node.
In this method, we advocate the user to install the database(postgresql) in a host machine, and the containerised image
is connected with the postgresql in the host. So, when the user accidentlaly kills/stops the container, their database will remain unaffected.



System Requirements :

The docker method of running the node is tried and tested in below mentioned environment.

User should have sudo access to the host OS

Standalone host OS: Ubuntu linux OS - 20.04

RAM:   2GB (minimum) — More the better

Storage Space:   50GB(minimum) — More the better

Cloud host: Aws Ec2 ubuntu linux OS - 20.04



##############################################################
POSTGRESQL SET UP SECTION
##############################################################
STEP:1
======
If you want to execute Apothem test net node follow the steps mentioned below:
==============================================================================
1) perl -i -p -e 's/\<PWD\>/password/g' postgresInstall.bash pluginApothem.env
   Change the 'password' word to your own custom password
   
2) perl -i -p -e 's/\<NET\>/test/g' postgresInstall.bash pluginApothem.env


If you want to execute Mainnet node follow the steps mentioned below:
==============================================================================
1) perl -i -p -e 's/\<PWD\>/password/g' postgresInstall.bash pluginMainnet.env
   Change the 'password' word to your own custom password
   
2) perl -i -p -e 's/\<NET\>/main/g' postgresInstall.bash pluginMainnet.env

STEP:2
======
Install postgresql & Config postgresql:
=======================================
1) /bin/bash postgresInstall.bash

2) sudo perl -i -p -e "s/^\#listen_addresses.*$/listen_addresses = \'\*\'/" /etc/postgresql/12/main/postgresql.conf

3) sudo chmod 666 /etc/postgresql/12/main/pg_hba.conf

4) sudo echo "host    all     all             172.17.0.1/16                 md5" >>/etc/postgresql/12/main/pg_hba.conf

5) sudo pg_ctlcluster 12 main start


##############################################################
DOCKER SET UP SECTION
##############################################################


If your Host System doesn't have docker installed, then follow the steps mentioned below:

STEP:1
======
1) sudo apt update

2) sudo apt install apt-transport-https ca-certificates curl software-properties-common

3) curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

4) sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

5) apt-cache policy docker-ce
   
   You’ll see output like this, although the version number for Docker may be different:
   docker-ce:
   Installed: (none)
   Candidate: 5:20.10.11~3-0~ubuntu-focal
   Version table:
      5:20.10.11~3-0~ubuntu-focal 500
         500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages
   Notice that docker-ce is not installed, but the candidate for installation is from the Docker repository for Ubuntu 20.04 (focal).
         
Finally, install Docker:

6) sudo apt install docker-ce
         
7) sudo systemctl status docker
   The output should be similar to the following, showing that the service is active and running:
      Output
     ● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2020-05-18 13:00:41 UTC; 19s ago
     TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
     Main PID: 24358 (dockerd)
      Tasks: 8
     Memory: 46.4M
     CGroup: /system.slice/docker.service
             └─24358 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
Before installing Docker, execute this command 'sudo apt update'

Steps to run docker Image:
==========================

1) sudo docker pull pluginode:latest

2) sudo docker images => get the IMAGE_ID

3) sudo docker run --env-file pluginApothem.env|pluginMainet.env -it -d -p 6688:6688 -v <ABSOLUT PATH OF CURRENT WORKING DIR>:/pluginAdm --add-host=host:192.168.0.1 <IMAGE_ID>

4) sudo docker ps -a => Get the <container_ID> 

      ################################################################################
      #                         IMPORTANT MESSAGE                                    #
      ################################################################################
      # Make sure you have the below mentioned 2  files are available and populated  #
      # as given below.                                                              #
      #                                                                              #
      # File 1: password.txt => contains your keystore password                      #
      #           *** KEYSTORE PASSWORD SHOULD FOLLOW THIS CONDITIONS ***            #
      #                   “must be longer than 12 characters”,                       #
      #                   “must contain at least 3 lowercase characters”,            #
      #                   “must contain at least 3 uppercase characters”,            #
      #                   “must contain at least 3 numbers”,                         #
      #                   “must contain at least 3 symbols”,                         #
      #                   “must not contain more than 3 identical consecutive        #
      #                    characters”.                                              #
      # File 2: apicredentials.txt => first line of the file contians email id for UI#
      #                              second line of the file contains password for UI#
      #                              (This passwrod should be strong, but need not   #
      #                               follow keystore password condition).           #
      #                                                                              #  
      # NOTE: This 2 files have default contents, please change the mail & passwords #
      #       before starting he next comand                                         #
      ################################################################################
      ################################################################################


5) sudo docker exec -it <container_ID> /bin/bash -c ". ~/.profile && pm2 start /pluginAdm/startNode.sh"

