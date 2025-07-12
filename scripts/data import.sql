SET GLOBAL local_infile = 1;

create database netflix_data_analysis;
use netflix_data_analysis;

/*to check if our dataset is loaded in the database or not we will run a count command
which will tell us the total no of content in the dataset.*/
-- select count(*) as total_content from dataset;
select * from dataset; -- yeh sirf 100 rows print kr rha tha qk hmare work bench mein limit lgi huyi th
delete from dataset; -- column names abh bh show ho rhe th 
select * from dataset;
truncate table dataset; -- isme bh col names show ho rhe the 
select * from dataset;
drop table dataset; -- isliye table hi uda diya :)
select * from dataset;
select count(*) as total_content from dataset;
-- load data from this file on disk
load data local infile '"C:\Users\DELL\OneDrive\Desktop\sql 2025\netflix_data_analysis\netflix_dataset\netflix_titles.csv"'
-- specifies the target table
into table dataset
-- defines column seperators in my csv file.
fields terminated by ','
-- handles the cases where fields are wrapped in quotes
enclosed by '"'
-- specifies the end of a row in the file
lines terminated by '\n'
-- tells mysql to skip first row which generally contains column names.
ignore 1 lines;

