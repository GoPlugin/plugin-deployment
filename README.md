<br/>
<p align="center">
<a href="https://goplugin.co" target="_blank">
<img src="https://github.com/GoPlugin/Plugin/blob/main/docs/plugin.png" width="225" alt="Plugin logo">
</a>
</p>
<br/>
This repo contians steps for running the node using docker image.
Running the node through docker container minimize the hassles to install the required utilities to run the node.
In this method, we advocate the user to install the database(postgresql) in a host machine, and the containerised image
is connected with the postgresql in the host. So, when the user accidentlaly kills/stops the container, their database will remain unaffected.


System Requirements :
=====================

Standalone host OS: Ubuntu linux OS - 20.04

RAM:   2GB (minimum) — More the better

Storage Space:   50GB(minimum) — More the better
############################################################################################
IMPORTANT: The docker method of running the node is tried and tested in below mentioned environment.
	    1. Standalone host OS: Ubuntu linux - 20.04
	    2. AWS EC2 hosted OS:Ubuntu linux - 20.04

	    User should have sudo access to the host OS
############################################################################################

Download the Plugin Installation:
```
git clone -b docker_branch https://github.com/GoPlugin/plugin-deployment.git && cd plugin-deployment
```



################################################

POSTGRESQL SET UP SECTION
=========================

To set up custom password for postgresql database execute the below mentioned command in plugin-deployment directory. The user needs to change the word 'password' to their own password for the database.

```
perl -i -p -e 's/\<PWD\>/password/g' postgresInstall.bash plugin.env
```   

Install postgresql & Config postgresql:
=======================================

```
1) /bin/bash postgresInstall.bash

2) sudo perl -i -p -e "s/^\#listen_addresses.*$/listen_addresses = \'\*\'/" /etc/postgresql/12/main/postgresql.conf

3) sudo chmod 666 /etc/postgresql/12/main/pg_hba.conf

4) sudo echo "host    all     all             172.17.0.1/16                 md5" >>/etc/postgresql/12/main/pg_hba.conf

5) sudo pg_ctlcluster 12 main start
```

###############################################

DOCKER SET UP SECTION
======================

If your Host System doesn't have docker installed, then follow the steps mentioned in STEP:1, else you can go to STEP:2

```
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
```         
Finally, install Docker:
```
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
```

##############################################################

STEP:2
====
Steps to run dockerized Plugin node:
===================
```
1) sudo docker pull pluginnode:latest

2) sudo docker images => get the IMAGE_ID

3) sudo docker run --env-file plugin.env -it -d -p 6688:6688 -v <ABSOLUTE PATH OF plugin-deployment DIRECTORY:/pluginAdm --add-host=host:192.168.0.1 <IMAGE_ID>

4) sudo docker ps -a => Get the <container_ID> 
```

```
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
```
##################################################################################################

```
5) sudo pg_ctlcluster12 main restart

6) sudo docker exec -it <container_ID> /bin/bash -c ". ~/.profile && pm2 start /pluginAdm/startNode.sh"
```

Your node will start with status as 'online'.
If you want to probe your running node, then you can use the command format as given below.

```
sudo docker exec -it <container_ID> /bin/bash -c "<YOUR_COMMAND>"
```

You can replace <YOUR_COMMAND> with
 -pm2 status
 -pm2 logs 0

Login to UI:
```
http://<IP_ADDRESS_OF_YOUR_HOST_MACHINE>:6688
```
To login to Plugin node UI, replace <IP_ADDRESS_OF_YOUR_HOST_MACHINE> with the actual IP address and run it through a browser
