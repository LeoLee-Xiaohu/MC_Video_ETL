
-- create tables
CREATE TABLE IF NOT EXISTS time(
	timeid int not null identity(0,1),
	DateTime char(16),
	year smallint,
	month smallint,
	day smallint,
	hour smallint,
	minute smallint);

CREATE TABLE IF NOT EXISTS title(
	titleid int not null identity(0,1),
	title varchar(200));

CREATE TABLE IF NOT EXISTS site(
	siteid int not null identity(0,1),
	site varchar(200));

CREATE TABLE IF NOT EXISTS platform(
	platformid int not null identity(0,1),
	platform varchar(50));

CREATE or replace table staging(
	DateTime char(16) not null,
	title varchar(200) not null,
	site varchar(200) not null,
	platform varchar(50) null);


CREATE or replace table fact(
	timeid int not null,
	titleid int not null,
	siteid int not null,
	platformid int null);
    
    
---file format
create or replace file format "MC_VIDEO"."PUBLIC".site
type = 'CSV'
field_delimiter = ','
record_delimiter = '\n'
skip_header = 1
field_optionally_enclosed_by = '\042'
trim_space = true
error_on_column_count_mismatch = true
escape = 'none'
escape_unenclosed_field = '\134'
date_format = 'auto'
timestamp_format = '%Y-%m-%dT%H:%M'
null_if = ('null') ;

create or replace file format "MC_VIDEO"."PUBLIC".platform
type = 'CSV'
field_delimiter = ','
record_delimiter = '\n'
skip_header = 1
field_optionally_enclosed_by = '\042'
trim_space = true
error_on_column_count_mismatch = true
escape = 'none'
escape_unenclosed_field = '\134'
date_format = 'auto'
timestamp_format = '%Y-%m-%dT%H:%M'
null_if = ('null') ;

create or replace file format "MC_VIDEO"."PUBLIC".staging
type = 'CSV'
field_delimiter = ','
record_delimiter = '\n'
skip_header = 1
field_optionally_enclosed_by = '\042'
trim_space = true
error_on_column_count_mismatch = true
escape = 'none'
escape_unenclosed_field = '\134'
date_format = 'auto'
timestamp_format = '%Y-%m-%dT%H:%M'
null_if = ('null') ;

create or replace file format "MC_VIDEO"."PUBLIC".time
type = 'CSV'
field_delimiter = ','
record_delimiter = '\n'
skip_header = 1
field_optionally_enclosed_by = '\042'
trim_space = true
error_on_column_count_mismatch = true
escape = 'none'
escape_unenclosed_field = '\134'
date_format = 'auto'
timestamp_format = '%Y-%m-%dT%H:%M'
null_if = ('null') ;

create or replace file format "MC_VIDEO"."PUBLIC".title
field_delimiter = ','
record_delimiter = '\n'
skip_header = 1
field_optionally_enclosed_by = '\042'
trim_space = true
error_on_column_count_mismatch = true
escape = 'none'
escape_unenclosed_field = '\134'
date_format = 'auto'
timestamp_format = '%Y-%m-%dT%H:%M'
null_if = ('null') ;

create or replace file format "MC_VIDEO"."PUBLIC".fact
type = 'CSV'
field_delimiter = ','
record_delimiter = '\n'
skip_header = 1
field_optionally_enclosed_by = '\042'
trim_space = true
error_on_column_count_mismatch = true
escape = 'none'
escape_unenclosed_field = '\134'
date_format = 'auto'
timestamp_format = '%Y-%m-%dT%H:%M'
null_if = ('null') ;

-- LOAD DATA from s3 staging 
copy into "MC_VIDEO"."PUBLIC".site from @S3STAGE_MCVIDEO
  file_format = site;

copy into "MC_VIDEO"."PUBLIC".PLATFORM from @STAGE_PLATFORM
  file_format = platform;

copy into "MC_VIDEO"."PUBLIC".TITLE from @TITLE
  file_format = TITLE;
  
copy into "MC_VIDEO"."PUBLIC".STAGING from @STAGING
  file_format = STAGING;
  
copy into "MC_VIDEO"."PUBLIC".TIME from @STGTIME
  file_format = TIME;
  

select * from TIME
limit 10;

select * from staging
limit 10;

-- load fact from staging table to fact table
insert into fact (timeid, titleid, siteid, platformid)
select a.timeid, b.titleid, c.siteid, d.platformid
from staging e
left join time a 
on e.DateTime = a.DateTime
left join title b 
on e.title = b.title
left join site c 
on e.site = e.site
left join platform d 
on e.platform = d.platform;

select * from fact limit 10;