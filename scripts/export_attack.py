#!/usr/bin/env python

# ATT&CK Client Main Script - Drill-down capabilities at the tactic / technique / platform / data source levels
# Author: Jose Rodriguez (@Cyb3rPandaH)
# License: GPL-3.0
# Reference:
# https://github.com/Cyb3rWard0g/ATTACK-Python-Client
# https://stackoverflow.com/questions/27263805/pandas-when-cell-contents-are-lists-create-a-row-for-each-element-in-the-list/27266225?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# https://stackoverflow.com/questions/19913659/pandas-conditional-creation-of-a-series-dataframe-column?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
# http://pandas.pydata.org/pandas-docs/version/0.22/generated/pandas.Series.str.contains.html
# https://chrisalbon.com/python/data_wrangling/pandas_dropping_column_and_rows/

from pandas import *
from pandas.io.json import json_normalize
from pandas import Series,DataFrame

from attackcti import attack_client

mitre = attack_client()

db = mitre.get_all_attack()

# Removes '\n' inside of a list element of the 'system_requirements' property
db_fixed = db
for sr in db_fixed:
    if 'system_requirements' in sr:
        if sr['system_requirements']:
            for idx, item in enumerate(sr['system_requirements']):
                sr['system_requirements'][idx] = sr['system_requirements'][idx].replace('\n',' ')

df = json_normalize(db_fixed)
df = df[[
    'matrix','tactic','technique','technique_id','technique_description',
    'mitigation','mitigation_description','group','group_id','group_aliases',
    'group_description','software','software_id','software_description','software_labels',
    'relationship_description','platform','data_sources','detectable_by_common_defenses','detectable_explanation',
    'difficulty_for_adversary','difficulty_explanation','effective_permissions','network_requirements','permissions_required',
    'remote_support','system_requirements','contributors','url']]

#****** There are some columns that contain a list on their cells, we need to create a row per each value of the list
attributes = ['tactic','platform','data_sources','permissions_required']
# In attributes, we indicate the name of the columns that we need to distribute in rows by values of the list

for a in attributes:
    s = df.apply(lambda x: pandas.Series(x[a]),axis=1).stack().reset_index(level=1, drop=True)
    # "s" is going to be a column of a frame with every value of the list inside each cell of the column "a"
    s.name = a
    # We name "s" with the same name of "a".
    df = df.drop(a, axis=1).join(s).reset_index(drop=True)
    # We drop the column "a" from "df", and then join "df" with "s"

#****** Now we are going to create a new column to identify windows data sources in Linux and macOS platforms
conditions = [(df['platform']=='Linux')&(df['data_sources'].str.contains('windows',case=False)== True),
             (df['platform']=='macOS')&(df['data_sources'].str.contains('windows',case=False)== True),
             (df['platform']=='Linux')&(df['data_sources'].str.contains('powershell',case=False)== True),
             (df['platform']=='macOS')&(df['data_sources'].str.contains('powershell',case=False)== True),
             (df['platform']=='Linux')&(df['data_sources'].str.contains('wmi',case=False)== True),
             (df['platform']=='macOS')&(df['data_sources'].str.contains('wmi',case=False)== True)]
# In conditions we indicate a logical test

choices = ['NO OK','NO OK','NO OK','NO OK','NO OK','NO OK']
# In choices, we indicate the result when the logical test is true

df['Validation'] = np.select(conditions,choices,default='OK')
# Finally, we add a column "Validation" to "df" with the result of the logical test. The default value is going to be "OK"

#****** Now we are going to create a new dataframe and filter the value "OK" in the column "Validation". We are going to replace some values in all the cells of the data frame
df_final = df[df.Validation == 'OK'].replace(['mitre-attack-mobile','Process monitoring','Application logs'],['mitre-mobile-attack','Process Monitoring','Application Logs'])

#****** Now we are going to delete the line breaks for all the cell of the dataframe. This action only applies for cells that contain a String value
df_final = df_final.replace('\n','',regex=True)

#****** Finally, we export the data frame to a CSV file
df_final.to_csv('mitre_attack.csv',index=False,encoding='utf-8')