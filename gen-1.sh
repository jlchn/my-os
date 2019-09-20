#!/bin/bash

REMOTE_IP=192.168.0.108
REMOTE_DIR=/home/jiangli/workspace/
rsync -az "$PWD" $REMOTE_IP:$REMOTE_DIR
ssh jiangli@$REMOTE_IP 'cd '$REMOTE_DIR'my-os/; sh gen-2.sh '
rsync -az $REMOTE_IP:$REMOTE_DIR'my-os/hd60.img' ./