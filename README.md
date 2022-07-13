# MC_video_project

1. **Introduction**

This project is for building an ETL process and building a data warehouse for the product of measuring MC video performance. By using the clean secure and consistent data, the video performance could be measured and insightful data analysing reports could be provided successfully. 

1. **ETL building**

The building process was designed as the following figure 1. shown. With the help of Serverless Framework, the process could be auto deployed by Amazon Clouldformation. 

| ![Figure 1. MC video ETL  process](https://github.com/LeoLee-Xiaohu/MC_Video_ETL/blob/main/images/MC_video_ETL.png) |
|:--:|
| <b> Figure 1. MC video ETL  process </b>|

1. **Data Quality Control** 
    1.  **Data  Profiling** 
    
    A data quality control was conducted priorly.
    
    After a raw data file (.CSV) was uploaded to the S3 storage bucket, a Lambda would be triggered automatically and produce a data profiling report. 
    
    |![Figure 2. Data profiling report](https://github.com/LeoLee-Xiaohu/MC_Video_ETL/blob/main/images/dataProfiling.png) |
    | <b> Figure 2. Data profiling report </b>|
    
    Data profiling reports would be displayed daily on the website with the support of AWS EC2. The raw data could be monitored daily before the data are prepared to be processed. For example, if the volume of records decreased significantly, this would be notified to the data engineer by Amazon SNS.
    
    ii.  **Data Auditing** 
    
    Once the data profiling report shows the raw data without problems, the raw data would be stored in the S3 landing bucket. With Amazon Athena, a data engineer could see and check the data immediately. 
    
2. **Data transformation and loading** 

To balance the cost and efficiency, the data transformation and loading were processed together, which means ETL and ELT were working together. Considering the timeout of the lambda function is 15 minutes, the Snowflake was needed as the increasing volume and complexity of data in the future. Thus,  the Amazon Lambda and the Snowflake were deployed together to handle data transformation and loading.

1. **Data warehousing (Kimball Model)**    

Since the business is relatively a small business and the demand for analysing video performance is urgent, the data warehouse was designed based on Kimball Model. 

The following figure 3. shows the star schema of the warehouse. 

| ![Figure 3. the schema of MC video data warehouse](https://github.com/LeoLee-Xiaohu/MC_Video_ETL/blob/main/images/star_schema%20copy.png)|
| <b> Figure 3. the schema of MC video data warehouse </b> |

1. **Data insight** 

Data insight was conducted by Tableau. 

Note: this is the first version of the product of the MC video. The code was still configuring. It may not work currently.# MC_Video_ETL
