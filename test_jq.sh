#!/bin/bash

json1=`metadata-list -v 4181808582778351130-242ac1110-0001-012 | jq '. | tojson | fromjson'`
json2="{\"value\": {\"newfield\": 1}}"

echo $json1 > "1.json"
echo $json2 > "2.json"
merge=`jq -s '.[0] * .[1]' 1.json 2.json`
echo $merge > "merge.json"
jq '. | .value.newfield |= 2' merge.json`
