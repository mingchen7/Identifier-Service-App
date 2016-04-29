#!/bin/bash

# take filepath and uuid of object as input

UUID=$1
SRA_FILE=$2

if [ ! -f "${SRA_FILE}" ]; then
	

