#!/bin/bash

DIR=$1
du -sk ${DIR} | awk '{print $1}'
