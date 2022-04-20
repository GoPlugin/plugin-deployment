#!/bin/sh
echo '<------------------ STARTING EXTERNAL INITIATOR--------------------------->'
external-initiator "{\"name\":\"pluginei\",\"type\":\"xinfin\",\"url\":\"https://plirpc.blocksscan.io/\"}" --chainlinkurl "http://localhost:6688/"
echo '<------------------EXTERNAL INITIATOR STARTED--------------------------->'
