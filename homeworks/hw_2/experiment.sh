#!/bin/bash
echo "argument number one is $1"
echo "argument number two is $2"
echo "rest of the arguments ${@:3}"
echo "all arguments $@"