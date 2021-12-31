#!/bin/sh
echo '<------------------ STARTING EXTERNAL INITIATOR--------------------------->'
external-initiator "{\"name\":\"pluginei\",\"type\":\"xinfin\",\"url\":\"https://pluginrpc.blocksscan.io\"}" --chainlinkurl "http://localhost:6688/"
echo '<------------------EXTERNAL INITIATOR STARTED--------------------------->'
