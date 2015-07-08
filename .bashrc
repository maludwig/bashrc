#!/bin/bash
# Source global bashrc
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
# Source main bashrc
if [ -f ~/bashrc/main ]; then
	. ~/bashrc/main
fi