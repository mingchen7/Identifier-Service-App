#!/bin/bash

# take filepath and uuid of object as input

UUID=$1
SRA_FILE=$2

if [ ! -f "${SRA_FILE}" ]; then
	echo 'SRA file not found! Please confirm the path.'
	exit 1
fi

echo $UUID
echo $SRA_FILE

# cacluate md5 checksum
md5=($(md5sum ${SRA_FILE}))

metadata=`metadata-list -v ${UUID} | jq '. | tojson | fromjson'`
echo $metadata > "old.json"

checksum_exists=`metadata-list -v ${UUID} | jq '[.value] | map(has("checksum"))[0]'`
echo checksum_exists

if [ "$checksum_exists" == true ]; then
	checksum=`metadata-list -v ${UUID} | jq '.value.checksum'`
	# remove quotes in the string
	temp="${checksum%\"}"
	temp="${temp#\"}"

	echo "Previous checksum: ${temp}"
	echo "New calcualted checksum: ${md5}"

	if [ "${md5}" = "${temp}" ]; then
		echo 'Checksum consistent, updating timestamp...'
		# timestamp=$(date '+%Y-%m-%d %X')
		# echo "$timestamp"
		# update lastChecksumUpdated fields into metadata
		new_metadata=`jq ". | .value.lastChecksumUpdated |= \"$(date '+%Y-%m-%d %X')\"" old.json`
		echo $new_metadata > "new.json"

	else
		echo 'checksum not consistent!'
		exit 2
	fi
else
	# add checksum and lastChecksumUpdated fields into metadata
	echo 'Adding checksum and timstamp...'
	update_data="{\"value\": {\"checksum\": "${md5}", \"lastChecksumUpdated\": "${timestamp}"}}"
	echo $update_data > "update.json"
	new_metadata=`jq -s '.[0] * .[1]' old.json update.json`
	echo $merge > "new.json"
	rm update.json
fi

# posting new metadata to agave
metadata-addupdate -v -F new.json ${UUID}
rm new.json old.json
exit 0




