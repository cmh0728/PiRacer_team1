#!/usr/bin/env bash
set -e

# source 
sudo cp sources.list.backup /etc/apt/sources.list
sudo cp -r sources.list.d.backup /etc/apt/sources.list.d/

# package install
sudo apt-get update
xargs -a apt-manual.txt sudo apt-get install -y
