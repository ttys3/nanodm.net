#!/bin/sh

rsync --rsh='ssh -p29684' -ravzzP --checksum --delete --out-format="%t | %f%L | %l | %b"  ./public/ root@files.80x86.io:/home/http/html/nanodm.net/

