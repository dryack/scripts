#!/bin/bash -e

PIG_SERVER="some.test.node.com"
PIG_DIR="/mnt/scrooge/user"

servo -D --abort-on-prompts -u deploy -i ~/.ssh/deploy_id -H $PIG_SERVER sudo:"if [ ! -d \"$PIG_DIR/$USER_DIR\" ]; then mkdir -p $PIG_DIR/$USER_DIR/uapig && chown -R $USER_DIR $PIG_DIR/$USER_DIR && exit 0 || echo \"USER_DIR not a valid username!\"; exit 1; fi && rm -rf $PIG_DIR/$USER_DIR/uapig/*"
#servo -u deploy -H $PIG_SERVER sudo:"echo 'rm -rf $PIG_DIR/$1/*'" #debug
