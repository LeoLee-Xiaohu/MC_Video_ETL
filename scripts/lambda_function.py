# using layer to import pandas, 
# here is the arn list to find pandas package: https://api.klayers.cloud//api/v2/p3.9/layers/latest/ap-southeast-2/html
import boto3
import os 
from urllib.parse import unquote_plus
import json
from datetime import datetime
import pandas as pd 
import sys

s3_client = boto3.client('s3')  

def lambda_handler(event, context):
    print("lambda function invoked")
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        file_name = key.split("/")[-1]
        print(f"received file: {key}")
        
        local_path = f'/tmp/{file_name}'
        
        s3_client.download_file(bucket, key, local_path)
        print("files in tmp directory: ", os.listdir('/tmp'))
        file_list = data_process(local_path)
        print("data transformation finished")
        print('files in tmp directory: ', os.listdir('/tmp'))
        for file in file_list:
            s3_client.upload_file(f'/tmp/{file}.csv', bucket, f'processed/{file}.csv')
            print(f'upload file to: processed/{file}.csv')
            
def data_process(file):
    def dt_obj(x):
        return datetime.strptime(x, '%Y-%m-%dT%H:%M')
        
    def like_platform(x):
        titles = x.split('|')[0]
        if 'Android' in titles: return 'Android'
        if 'iPhone' in titles: return 'iPhone'
        if 'iPad' in titles: return 'iPad'
        return 'Desktop'
        
    def like_site(x):
        platform_set = {'Android','iPhone','iPad','Web'}
        titles = x.split('|')[0]
        if any(title in platform_set for title in titles.split()): return 'None' 
        return titles 

    raw = pd.read_csv(file, quotechar= '"', escapechar='\\',error_bad_lines = False)

    processed = raw[raw['events'].str.contains('206')]
    processed = processed[processed['VideoTitle'].apply(lambda x : len(x.split('|'))>1)]

    del raw 

    processed.loc[:, 'DateTime'] = processed['DateTime'].apply(lambda x : x[:-8])
    dim_time = pd.DataFrame(processed['DateTime'].unique())
    dim_time.columns = ['DateTime']


    dim_time.loc[:,'year'] = dim_time['DateTime'].apply(lambda x : dt_obj(x).year)
    dim_time.loc[:, 'month'] = dim_time['DateTime'].apply(lambda x: dt_obj(x).month)
    dim_time.loc[:,'day'] = dim_time['DateTime'].apply(lambda x: dt_obj(x).day)
    dim_time.loc[:,'hour'] = dim_time['DateTime'].apply(lambda x: dt_obj(x).hour)
    dim_time.loc[:,'minute'] = dim_time['DateTime'].apply(lambda x: dt_obj(x).minute)    

    processed.loc[:,'title'] = processed['VideoTitle'].apply(lambda x : x.split('|')[-1])
    dim_title = pd.DataFrame(processed['title'].unique())
    dim_title.columns = ['title']
    dim_title.index += 1
    dim_title.index.name = 'titleid'

    processed.loc[:,'platform'] = processed['VideoTitle'].apply(lambda x : like_platform(x))
    dim_platform = pd.DataFrame(processed['platform'].unique())
    dim_platform.columns = ['platform']
    dim_platform.index += 1
    dim_platform.index.name = 'platformid'

    processed.loc[:,'site'] = processed['VideoTitle'].apply(lambda x: like_site(x))
    dim_site = pd.DataFrame(processed['site'].unique())
    dim_site.columns = ['site']
    dim_site.index += 1
    dim_site.index.name = 'siteid'

    processed.drop(columns = ['VideoTitle'], inplace =True)
    processed.drop(columns = ['events'], inplace = True)

    processed.index.name = 'factid'
    fact = processed 
    del processed 

    dim_time.to_csv('/tmp/dim_time.csv', line_terminator= '\n', escapechar='\\',index=False)
    dim_site.to_csv('/tmp/dim_site.csv',line_terminator='\n',escapechar='\\')
    dim_title.to_csv('/tmp/dim_title.csv',line_terminator='\n',escapechar='\\')
    dim_platform.to_csv('/tmp/dim_platform.csv',line_terminator='\n',escapechar='\\')
    fact.to_csv('/tmp/fact.csv',line_terminator='\n',escapechar='\\',index=False)
    return ["dim_time","dim_site","dim_title","dim_platform","fact"]
