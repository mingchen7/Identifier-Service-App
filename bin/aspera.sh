#!/bin/bash

# Set constant variables
ASPERA="~/.aspera/connect"
SRA=$1
DESTINATION_DIR=$2

if [ "${DESTINATION_DIR: -1}" != '/' ]; then
	echo 'Destination directory is not valid!'
	exit 1
fi

# echo $DESTINATION_DIR

# Get the first 6 characters of SRA accession
PREFIX=`echo $SRA | cut -b 1-3`
PREFIX_ACCESSION=`echo $SRA | cut -b 1-6`

# Join command
FTP_PREFIX='anonftp@ftp.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra'
FTP_ADDRESS="$FTP_PREFIX/$PREFIX/$PREFIX_ACCESSION/$SRA/$SRA.sra"
echo -e "ftp address:\n$FTP_ADDRESS"

# Create a new directory if not exists
if [ ! -d "${DESTINATION_DIR}" ]; then
	echo "Destination directory does not exist. Creating destination directory: $DESTINATION_DIR"
	mkdir ${DESTINATION_DIR}
else
	echo "Destination is: $DESTINATION_DIR"
fi

ascp -T -l640M -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh $FTP_ADDRESS $DESTINATION_DIR

if [ $? -eq 0 ]; then
	echo 'Download successful!'
	exit 0
else
	echo 'Download Fail!'
	exit 1	
fi
