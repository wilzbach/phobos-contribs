#!/bin/bash

SERVER="dime"
FOLDER="/opt/projects/dlang-contribs"

# deploy on server
scp contribs $SERVER:$FOLDER/contribs.new

# at the moment we shortly need to stop the service
ssh $SERVER "systemctl stop dlang-contrib.service"

# swap and start service
ssh $SERVER "mv $FOLDER/contribs $FOLDER/contribs.bak"
ssh $SERVER "mv $FOLDER/contribs.new $FOLDER/contribs"
ssh $SERVER "systemctl start dlang-contrib.service"
