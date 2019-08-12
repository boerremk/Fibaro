#!/usr/bin/python
# Script to poll the UPS (via apcupsd) and publish interesting facts to
# pachube. You'll need to alter FEED_ID and insert your API key
# Published under GPL3+ by Andrew Elwell <Andrew.Elwell@gmail.com>

import subprocess
import requests
import json

# go and grab
stats = {}
res = subprocess.check_output("/sbin/apcaccess")
for line in res.split('\n'):
    (key,spl,val) = line.partition(': ')
    key = key.rstrip()
    stats[key] = val.strip()

#print stats["status"]

print "Content-type: text/html\n\n"
print json.dumps(stats)
