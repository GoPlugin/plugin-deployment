#!/bin/sh
echo '<--------------------STARTING PLUGIN NODE-------------------------->'
plugin node start -d -p /pluginAdm/.env.password -a /pluginAdm/.env.apicred
echo '<--------------------PLUGIN NODE STARTED-------------------------->'
