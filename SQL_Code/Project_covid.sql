

--------Covid Date wise Aggregate 
-------Creating Pivot to Make sense from the Data and Storing it into View
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



---------State Total
--------Creating and storing State Aggregate Data in View State_total

create view state_total as(
select State as State_code,type,Tested,Confirmed,Recovered,Deceased,First_Vaccine as Vaccinated1,Second_Vaccine as Vaccinated2 from(
select * 
, DENSE_RANK()over(Partition by state order by date desc) as rank
from covid
) as d
where rank=1
);



------Insight 1----Question 1
-----Weekly Evolution of Data

select Year, Month,week,Tested,Confirmed,Deceased,Recovered from(
select Year,Month,Month_Num,ceiling (cast(datepart(dd,date)as numeric(38,8))/7) as week
,Sum(Tested) as Tested ,sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Deceased) as Deceased
from covid where state='TT' and type='Delta7'
group by Year,Month,ceiling (cast(datepart(dd,date)as numeric(38,8))/7),Month_Num
)as d
order by year,Month_Num,Month,week


-----Worst Month With Respect to Highest confirmed Cases
----- Using TOP1

select Top 1 Year, Month,Tested,Confirmed,Deceased,Recovered from(
select Year,Month,Month_Num
,Sum(Tested) as Tested ,sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Deceased) as Deceased
from covid where state='TT' and type='Delta'
group by Year,Month,Month_Num
)as d
order by Confirmed desc





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



---- India Data of Total Tested, Confirmed,Recovered, Deceased

select State,Sum(Tested) as Tested ,sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Deceased) as Deceased
from covid where state='TT' and type='Delta'
group by State
order by State


---- State Data With current Active Cases


select *,(Confirmed-(Recovered+Deceased)) as Active from(
select State,Sum(Tested) as Tested ,sum(Confirmed) as Confirmed,Sum(Recovered) as Recovered,Sum(Deceased) as Deceased
from covid where state!='TT' and type='Delta'
group by state
) as d
order by Confirmed desc


-----India Death rate Overall Before Vaccine


select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
and state='TT'
group by State
) as d
order by Death_Rate desc

-----India Death rate Overall After VacCine


select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine!=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
and state='TT'
group by State
) as d
order by Death_Rate DEsc


-----Monthly Evolution of Death Rate before Vaccine


select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Year,Month,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
and state='TT'
group by State,Year,Month
) as d
order by Death_Rate DESC

------Monthly Evolution of Death Rate After Vaccine


select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Year,Month,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine!=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
and state='TT'
group by State,Year,Month
) as d
order by Death_Rate DESC


-------Monthly Evolution of Death Rate After Vaccine For each State
select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Year,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine!=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
group by State,Year
) as d
order by Death_Rate DESC

-------Monthly Evolution of Death Rate Before Vaccine For each State
select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Year,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
group by State,Year
) as d
order by Death_Rate DESC



-------Overall Death Rate Before Vaccine For each State
select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
group by State
) as d
order by Death_Rate DESC

-------Overall Death Rate After Vaccine For each State


select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from(
select State,Sum(Tested) as Tested,sum(Confirmed) as Confirmed,sum(Recovered) as recovered
,sum(Deceased) as Deceased from covid where type='Delta' and First_Vaccine!=0 and Confirmed!=0 and recovered !=0 and Tested !=0 and Deceased!=0
group by State
) as d
order by Death_Rate DESC




-----Imported Distrct Data as District

select * from district


-----Creating View as F to store Pivots

create view f as(
select * from(
select * from district
)as d
pivot
(
Sum([Count]) for [Status] in ([Tested],[Confirmed],[Deceased],[Recovered],[Vaccinated1],[Vaccinated2])
)as e
)


create view f1 as(
select * from(
select * from district where type='Meta'
)as d
pivot
(
Sum([Count]) for [Status] in ([Population])
)as e
)

--------Categorizing and Calculation of Testing Ratio as per Instruction and Storing into view as Distrct_testing

-----Comment
----- Category A: 0.05 ≤ tr ≤ 0.1
----- Category B: 0.1 < tr ≤ 0.3
----- Category C: 0.3 < tr ≤ 0.5
----- Category D: 0.5 < tr ≤ 0.75
----- Category E: 0.75 < tr ≤ 1.0
create view district_testing as(
select * from(
select *,
case when Testing_ratio <= 0.1  then 'A'
 when Testing_ratio between 0.1 and 0.3  then 'B'
 when Testing_ratio between 0.3 and 0.5  then 'C'
 when Testing_ratio between 0.5 and 0.75  then 'D'
 when Testing_ratio >= 0.75 then 'E'
end as 'Category'
from(
select f.*,f1.Population,convert(Decimal(5,2),(convert(float,Tested)/convert(float,population))) as Testing_Ratio from f 
join f1
on f1.district=f.district
where f.type='total'
) as d
) as e
)

-----Districts With highest testing Ratio

select * from district_testing order by Testing_Ratio desc


---- Top 5 District with Highest Death Rate

select Top 5 *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from district_testing
order by Death_Rate desc



---- Top 5 District with highest testing ratio

select Top 5 *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from district_testing
order by Testing_Ratio desc


----- Top 5 District with percent of Population Got Covid
select Top 5 * from(
select *,
(convert(float,Confirmed)/convert(float,Population))*100 as Case_Rate
from district_testing
) as d
order by Case_Rate desc

----Top Performing Districts with Lowest Death rate and Highest recovery Rate


select Top 5 *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate
from district_testing
where (convert(float,Deceased)/convert(float,Confirmed))*100 is not NULL
order by Recovery_Rate DESC

----Top 5 States with highest vaccination 

select Top 5 State_code,
convert(decimal(5,2),(convert(float,Vaccinated1)/convert(float,population)))*100 as First_Vaccine_Percent,
convert(decimal(5,2),(convert(float,Vaccinated2)/convert(float,population)))*100 as Second_Vaccine_Percent,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate
from(
select state_code,sum(Vaccinated1) as Vaccinated1,sum(Vaccinated2) as Vaccinated2,sum(population) as population,
sum(Confirmed) as Confirmed,sum(deceased) as deceased from district_testing
group by state_code
) as d
order by Second_Vaccine_Percent desc



------Average Vaccination rate vs District Vaccination rate
-----Worst State
select Top 5 * 
, avg(First_Vaccine_Percent) over() as AVG_First_Vaccine_Rate,
avg(Second_Vaccine_Percent) over() as AVG_Second_Vaccine_Rate
from(
select State_Code,District,Vaccinated1,Vaccinated2,Population,
convert(decimal(5,2),(convert(float,Vaccinated1)/convert(float,population)))*100 as First_Vaccine_Percent,
convert(decimal(5,2),(convert(float,Vaccinated2)/convert(float,population)))*100 as Second_Vaccine_Percent
from district_testing
) as d
where First_Vaccine_Percent is not null
order by First_Vaccine_Percent

----Best State
-----
select Top 5 * 
, avg(First_Vaccine_Percent) over() as AVG_First_Vaccine_Rate,
avg(Second_Vaccine_Percent) over() as AVG_Second_Vaccine_Rate
from(
select State_Code,District,Vaccinated1,Vaccinated2,Population,
convert(decimal(5,2),(convert(float,Vaccinated1)/convert(float,population)))*100 as First_Vaccine_Percent,
convert(decimal(5,2),(convert(float,Vaccinated2)/convert(float,population)))*100 as Second_Vaccine_Percent
from district_testing
) as d
where First_Vaccine_Percent is not null
order by First_Vaccine_Percent DESC

---- Top 5 District with Highest death rate vs Average Death Rate Vs District Death Rate


select *,
Avg(Death_Rate) over() as AVG_DEATH_Rate
from(
select State_code,District,Deceased,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate
from district_testing
where (convert(float,Deceased)/convert(float,Confirmed))*100 is not NULL
) as d
order by Death_Rate DESC


---- Top 5 DIstrict with Highest case rate vs Avg India Case rate

select Top 5  *,
avg(Case_rate) over() as Avg_Case_Rate
from(
Select State_code,District, Confirmed, Population,
(convert(float,Confirmed)/convert(float,Population))*100 as Case_rate
from district_testing
where confirmed is not Null and Population is not null
) as d
order by Case_rate desc



----India Vaccination Rate

select (convert(float,Vaccination_1)/convert(float,Population))*100 as First_Vaccine_Percent,
(convert(float,Vaccination_2)/convert(float,Population))*100 as Second_Vaccine_Percent
from(
select sum(Population) as 'Population', Sum(Vaccinated1) as Vaccination_1, Sum(Vaccinated2) as Vaccination_2
from district_testing
) as d


----Testing Category data


select *,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate,
(convert(float,Recovered)/convert(float,Confirmed))*100 as Recovery_Rate,
convert(decimal(5,2),(convert(float,Vaccinated1)/convert(float,population)))*100 as First_Vaccine_Percent,
convert(decimal(5,2),(convert(float,Vaccinated2)/convert(float,population)))*100 as Second_Vaccine_Percent,
(convert(float,Confirmed)/convert(float,Population))*100 as Case_Rate
from(
select Category,sum(Tested) as Tested
,sum(Confirmed) as Confirmed
,sum(Deceased) as Deceased
,sum(Recovered) as recovered
,sum(Vaccinated1) as Vaccinated1
,sum(Vaccinated2) as Vaccinated2
,sum(Population)as population
from district_testing
group by Category
) as d
where Category is not null
order by First_Vaccine_Percent desc

----Tetsing category Death rate and Decesed Number

select Category,deceased,
(convert(float,Deceased)/convert(float,Confirmed))*100 as Death_Rate
from(
select Category,sum(Tested) as Tested
,sum(Confirmed) as Confirmed
,sum(Deceased) as Deceased
,sum(Recovered) as recovered
,sum(Vaccinated1) as Vaccinated1
,sum(Vaccinated2) as Vaccinated2
,sum(Population)as population
from district_testing
group by Category
) as d
where Category is not null
