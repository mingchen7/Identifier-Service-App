#! /usr/bin/env python
__author__ = 'Ming Chen'

import os
import json
import urllib2
import hashlib
import datetime
from argparse import ArgumentParser
from agavepy.agave import Agave, AgaveException
# from pprint import pprint

# SAMPLE JSON METADATA
# body =  {	
# 			"name": "test of new file",
# 			"value": 
# 				{
# 					"Publisher": "Plant Physiology", 
# 					"publicationYear":"2015",
# 					"Identifier": "doi:10.5072/FK2",
#					"identifierType": "DOI",
# 					"Subject":"Plant biology",
# 					"Date": "2015-04-22",
# 					"resourceType": "test",
# 					"relatedIdentifier": "http://www.plantphysiol.org/content/168/4/1262.long",
# 					"relatedIdentifier" : "URL",
# 					"file_name": "B73_all3_R1_val_1.fq",
# 					"path": "/corral-tacc/tacc/iplant/vaughn/springer_vaughn/eichten/5genos/",
# 					"size": "500000000"
# 				}
# 		}

# uuid = '4181808582778351130-242ac1110-0001-012'	

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def _client():
	DIR_HOME = os.path.expanduser('~')
	AGAVE_AUTH_PATH = os.path.join(DIR_HOME, '.agave/current')
	with open(AGAVE_AUTH_PATH) as auth_file:
		auth = json.load(auth_file)

	# print type(auth)
	# print(auth)

	client_key = '9hBjqdHUWW4qaBXz7TH4fInfrdYa'				  
	client_secret = 'xTsH1WesLavMsR1VXtC_WEh7Qzoa'	
	token = auth['access_token']
	refresh_token = auth['refresh_token']

	try:			
	    agave = Agave(
	        token=token, refresh_token=refresh_token, api_key=client_key, api_secret=client_secret, 
	        api_server='https://agave.iplantc.org',
	        client_name='Default', verify=False
	    )
		
	except AgaveException as e:
		print '{{"error": "{0}" }}'.format(json.dumps(e.message))

	return agave

def _create(body):	
    a = _client()    
    try:
        response = a.meta.addMetadata(body=body)             
        uuid = response['uuid']
        
    except Exception as e:
        print('no sir: %s' % e)

    return uuid

def _update(uuid, fname):
	a = _client()
	query = {'uuid' : uuid}
	body = a.meta.listMetadata(q = json.dumps(query))			
	checksum = md5(fname)
	updated_time = datetime.datetime.now()

	body = body[0]
	if 'checksum' not in body['value']:
		body['value']['checksum'] = checksum
		body['value']['lastChecksumUpdated'] = updated_time.strftime("%Y-%m-%dT%H:%M:%S")
		response = a.meta.updateMetadata(uuid = uuid, body = body)
	elif body['value']['checksum'] == checksum:
		print "Checksum is updated successfully!"
		body['value']['lastChecksumUpdated'] = updated_time.strftime("%Y-%m-%dT%H:%M:%S")
		response = a.meta.updateMetadata(uuid = uuid, body = body)
	else:
		print "Checksum is NOT consistent with previous one!"

		# should run some other checkings, just for testing here
		# body['value']['checksum'] = checksum
		# body['value']['lastChecksumUpdated'] = updated_time.strftime("%Y-%m-%dT%H:%M:%S")
		# response = a.meta.updateMetadata(uuid = uuid, body = body)

	_view(query)
	return 0

def _delete(uuid):
	a = _client()
	a.meta.deleteMetadata(uuid=uuid)		

def _view(query):
	a = _client()	
	l = a.meta.listMetadata(q = json.dumps(query))
	print json.dumps(l, indent = 2)


usage = 'Usage: ids_checksum.py [options]'	
desc = """
Run md5 checksum on the ids registered files and update metadata.
"""

# Parse the command-line options
parser = ArgumentParser(usage = usage, description = desc, add_help = True)
parser.add_argument("uuid", help = "uuid of the registered file to be checked.")
parser.add_argument("fname", help = "name of the file to be checked.")
args = parser.parse_args()
# print args.uuid
# print args.fname
_update(args.uuid, args.fname)




