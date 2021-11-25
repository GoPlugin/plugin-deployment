<br/>
<p align="center">
<a href="https://goplugin.co" target="_blank">
<img src="https://github.com/GoPlugin/Plugin/blob/main/docs/plugin.png" width="225" alt="Plugin logo">
</a>
</p>
<br/>

This repo contains the script for automation of the [Plugin](https://goplugin.co/) Node setup which can be used by the Node operators.
There are 2 scripts in this repo(1_prerequisite.bash,2_nodeStartPM2.sh) & 2 files (apicredentials.txt, password.txt). 

1) Before executing the 1_prerequisite.bash script, please change the database password
 to your own known password(we just given a default as 'postgres', just change 'your_password') at line number 202 of 1_prerequisite.bash.
This script will install all the prerequisite tools, utilities for Plugin.
- After successfull execution of 1_prerequisite.bash, kindly go through the instructions to be followed
  for executing 2_nodeStartPM2.sh as mentioned below.
```
      ################################################################################
      # 			IMPORTANT MESSAGE                                    #
      ################################################################################
      # Make sure you have the below mentioned 2  files are available and populated  #
      # as given below. Then start 'pm2 start 2_nodeStartPM2.sh' script to run your#
      # node in the background. To view your node log use 'pm2 logs 0'.              #
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
      ################################################################################
```
2) Now execute 2_nodeStartPM2.sh through pm2 'pm2 start 2_nodeStartPM2.sh'.
3) You can view the status(pm2 status 0) && logs(pm2 logs 0) of your running node


Please follow the link [Node setup Guide](https://medium.com/@GoPlugin/setup-a-plugin-node-automated-way-using-shell-script-fbdec48a0dea) on medium for detailed process steps.

To withdraw your XDC/PLI from your node please refer to this article (https://medium.com/@GoPlugin/how-to-withdraw-xdc-pli-from-plugin-node-oracle-address-a9ebe6ff2dd7).

