#!/usr/bin/env python

# HELK script: helk_otx.py
# HELK script description: Pulling intelligence from OTX (AlienVault)
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause
# Since original python file didn't contain OTX Domain Data, so I made a little changes to this.

from OTXv2 import OTXv2
from pandas.io.json import json_normalize
from datetime import datetime
from datetime import timedelta


otx = OTXv2("a5389a7d96e237ca7af48901f7054d2af4c51af7c0302a4dd0b31f96c20dd003")
time_range = 30
timedelta_days = timedelta(days=int(time_range))
pull_time = (datetime.now() - timedelta_days).isoformat()

def OTXEnrichment():
    pulses = otx.getsince(pull_time)
    data = []
    object = {}
    for p in pulses:
        for i in p['indicators']:
            object = {
                'industries': p['industries'],
                'tlp': p['tlp'],
                'description' : p['description'],
                'created' : p['created'],
                'pulse_name' : p['name'],
                'tags' : p['tags'],
                'author_name' : p['author_name'],
                'created': p['created'],
                'modified' : p['modified'],
                'targeted_countries' : p['targeted_countries'],
                'id' : p['id'],
                'extract_source' : p['extract_source'],
                'references' : p['references'],
                'adversary' : p['adversary'],
                'indicator_name': i['indicator'],
                'indicator_description': i['description'],
                'indicator_title': i['title'],
                'indicator_created': i['created'],
                'indicator_content': i['content'],
                'indicator_type': i['type'],
                'indicator_id': i['id']
            }    
            data.append(object)
    
    IPV4 = []
    IMPHASH = []
    MD5 = []
    SHA256 = []
    SHA1 = []
    DOMAIN = []
    #HOSTNAME = []
    def pull_indicators(lst, name):
        object = {
            'indicator_name' : (i['indicator_name']).upper(),
            'pulse_name' : i['pulse_name'],
            'ioc_name': name
        }
        return object

    def pull_indicators_domain(lst, name):
        object = {
            'indicator_name' : (i['indicator_name']).lower(),
            'pulse_name' : i['pulse_name'],
            'ioc_name': name
        }
        return object

    for i in data:
        if i['indicator_type'] == "IPv4":
            IPV4.append(pull_indicators(IPV4, 'ipv4'))
        elif i['indicator_type'] == "FileHash-MD5":
            MD5.append(pull_indicators(MD5, 'md5'))
        elif i['indicator_type'] == "FileHash-SHA1":
            SHA1.append(pull_indicators(SHA1, 'sha1'))
        elif i['indicator_type'] == "FileHash-SHA256":
            SHA256.append(pull_indicators(SHA256, 'sha256'))
        elif i['indicator_type'] == "FileHash-IMPHASH":
            IMPHASH.append(pull_indicators(IMPHASH, 'imphash'))
        elif i['indicator_type'] == "domain":
            DOMAIN.append(pull_indicators_domain(DOMAIN, 'domain'))
        elif i['indicator_type'] == "hostname":
            DOMAIN.append(pull_indicators_domain(DOMAIN, 'domain'))


    iocs = [IPV4, IMPHASH, MD5, SHA1, SHA256, DOMAIN]
    for i in iocs:
        try:
            df = json_normalize(i)
            df.to_csv(('otx_'+i[0]['ioc_name']+'_.csv'), index=False, header=False, encoding='utf-8', columns=("indicator_name", "pulse_name"))
        except:
            print "Not available Intelligence for one indicator in the past 30 days"

if __name__=="__main__":
    OTXEnrichment()
