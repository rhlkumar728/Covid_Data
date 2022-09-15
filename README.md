# Covid_Data
In this project we will be Analyzing covid data, Coming from covid19india.org, The data is coming in json and then we are converting it into Csv and then doing analyzing in MSSQL and then Making Dashboard on Excel


### Data Defination

#Delta: Data of that same day
#Delta7: 7 days Moving Avaerage data
#Total: Moving total of Tested,Recovered,deceased




Dashboard Screenshot

![image](https://user-images.githubusercontent.com/62884175/190382877-d313f56f-cb37-43b0-86f5-373c5a3a5f7b.png)
![image](https://user-images.githubusercontent.com/62884175/190382970-3469c35d-e38b-4bb9-8adc-ce3d6eadd880.png)



SQL Code and Table

#1 Create Pivot
select * from(
select State,year(Date)as Year,DATENAME(MONTH,date) as Month,Date,
Type,COALESCE(Tested,0)as Tested,COALESCE(Confirmed,0)as Confirmed,
COALESCE(Recovered,0)as Recovered,COALESCE(Deceased,0)as Deceased,COALESCE(Vaccinated1,0)as First_Vaccine,
COALESCE(Vaccinated2,0)as Second_Vaccine,Datepart(Month,date) as Month_Num
from(
select * from(
select * from date
) as d
pivot
(
sum([Count]) for [Operation] in([Tested],[Confirmed],[Recovered],[Deceased],[Vaccinated1],[Vaccinated2])
)
as e
) as f
) as g
group by State,Year,Month,Date,Type,Tested,confirmed,recovered,Deceased,First_Vaccine,Second_Vaccine,Month_num

![image](https://user-images.githubusercontent.com/62884175/190381636-87fd1474-308f-4351-85db-934345e445bb.png)


#2 Storing into View to Work on it

create view covid as(
select * from(
select State,year(Date)as Year,DATENAME(MONTH,date) as Month,Date,
Type,COALESCE(Tested,0)as Tested,COALESCE(Confirmed,0)as Confirmed,
COALESCE(Recovered,0)as Recovered,COALESCE(Deceased,0)as Deceased,COALESCE(Vaccinated1,0)as First_Vaccine,
COALESCE(Vaccinated2,0)as Second_Vaccine,Datepart(Month,date) as Month_Num
from(
select * from(
select * from date
) as d
pivot
(
sum([Count]) for [Operation] in([Tested],[Confirmed],[Recovered],[Deceased],[Vaccinated1],[Vaccinated2])
)
as e
) as f
) as g
group by State,Year,Month,Date,Type,Tested,confirmed,recovered,Deceased,First_Vaccine,Second_Vaccine,Month_num
);



#3 State Total Date of Delta,Delta7,Total

select State as State_code,type,Tested,Confirmed,Recovered,Deceased,First_Vaccine as Vaccinated1,Second_Vaccine as Vaccinated2 from(
select * 
, DENSE_RANK()over(Partition by state order by date desc) as rank
from covid
) as d
where rank=1

![image](https://user-images.githubusercontent.com/62884175/190382004-ac566b32-a430-49bc-b972-0ea894a4dbbc.png)




#3 Weekly Evolution of data

select Year, Month,week,Tested,Confirmed,Deceased,Recovered from(
select Year,Month,Month_Num,ceiling (cast(datepart(dd,date)as numeric(38,8))/7) as week
,Sum(Tested) as Tested ,sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Deceased) as Deceased
from covid where state='TT' and type='Delta7'
group by Year,Month,ceiling (cast(datepart(dd,date)as numeric(38,8))/7),Month_Num
)as d
order by year,Month_Num,Month,week

![image](https://user-images.githubusercontent.com/62884175/190382134-be7b9fe1-78da-4dc8-bcd5-50527aa5e2c5.png)


-----Worst Month With Respect to Highest confirmed Cases
----- Using TOP1

select Top 1 Year, Month,Tested,Confirmed,Deceased,Recovered from(
select Year,Month,Month_Num
,Sum(Tested) as Tested ,sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Deceased) as Deceased
from covid where state='TT' and type='Delta'
group by Year,Month,Month_Num
)as d
order by Confirmed desc

![image](https://user-images.githubusercontent.com/62884175/190382233-615a39c6-99c1-439e-8471-82b2316a7848.png)

-----State Data with First and Second Vaccine Percentage and Death and Recovery rate of Each State

select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select *,convert(decimal(5,2),(convert(float,Vaccinated1)/convert(float,population)))*100 as First_Vaccine_Percent,
convert(decimal(5,2),(convert(float,Vaccinated2)/convert(float,population)))*100 as Second_Vaccine_Percent
from(
select s.*,population from state_total as s
Join population as p
on p.state_code=s.State_code
) as d
where type='Total'
) as e
order by First_Vaccine_Percent desc


![image](https://user-images.githubusercontent.com/62884175/190382362-c3d0cf4a-406a-469e-a73d-5b01e49a9c3f.png)


And so on, Rest you can Check SQL File




