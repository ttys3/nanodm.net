#!/bin/sh

hugo
rsync --rsh='ssh -p29684' -ravzzP --checksum --delete public/ root@files.80x86.io:/home/http/html/nanodm.net/

