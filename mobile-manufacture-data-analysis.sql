--SQL Advance Case Study


--Q1--BEGIN 

 select distinct state from [dbo].[DIM_LOCATION] l
 inner join [dbo].[FACT_TRANSACTIONS] t
 on l.IDLocation=t.IDLocation
 where t.Date> '2005-01-01' ;

 	

	



--Q1--END

--Q2--BEGIN
	
select top 1 state , count(t.idmodel) as buyers from [dbo].[DIM_LOCATION] l
inner join [dbo].[FACT_TRANSACTIONS] t
on l.IDLocation=t.IDLocation
inner join [dbo].[DIM_MODEL] m
on m.IDModel=t.IDModel
inner join [dbo].[DIM_MANUFACTURER] a
on m.IDManufacturer=a.IDManufacturer 
where Manufacturer_Name='Samsung' and l.Country='US'
group by state
order by buyers desc;



--Q2--END

--Q3--BEGIN      

select model_name , zipcode, state , COUNT(IDCUSTOMER) as transactions from [dbo].[DIM_LOCATION] l
inner join [dbo].[FACT_TRANSACTIONS] t
on t.IDLocation= l.IDLocation
inner join [dbo].[DIM_MODEL] m
on m.IDModel = t.IDModel
 group by  Model_Name, zipcode, state








--Q3--END

--Q4--BEGIN

select top 1 Manufacturer_Name , model_name, Unit_price from [dbo].[DIM_MODEL] m
inner join [dbo].[DIM_MANUFACTURER] a
on a.IDManufacturer=m.IDManufacturer
order by unit_price ;







--Q4--END

--Q5--BEGIN


select  model_name ,avg(Unit_price ) as avg_price  from DIM_MANUFACTURER a
inner join [dbo].[DIM_MODEL] m
on a.IDManufacturer=m.IDManufacturer
where Manufacturer_Name in ( select top 5 Manufacturer_Name from DIM_MANUFACTURER a
inner join [dbo].[DIM_MODEL] m
on a.IDManufacturer=m.IDManufacturer 
inner join [dbo].[FACT_TRANSACTIONS] t
on t.IDModel=m.IDModel
group by Manufacturer_Name
order by count(quantity) desc)
group by Model_Name
order by AVG_price ;






--Q5--END

--Q6--BEGIN


select customer_name , avg(totalprice) as avg_price from  [dbo].[DIM_CUSTOMER] c
inner join [dbo].[FACT_TRANSACTIONS] t
on t.IDCustomer=c.IDCustomer
where year(Date) ='2009'
group by Customer_Name
having avg(totalprice) > 500;






--Q6--END
	
--Q7--BEGIN 
select m.Model_Name from DIM_MODEL m
 full join FACT_TRANSACTIONS t
 on m.IDModel=t.IDModel
 where t.IDModel in (select top 5 IDModel from FACT_TRANSACTIONS where year(date)= 2008 group by IDModel)
 and t.IDModel in (select top 5 IDModel from FACT_TRANSACTIONS where year(date)= 2009 group by IDModel)
 and t.IDModel in (select top 5 IDModel from FACT_TRANSACTIONS where year(date)= 2010 group by IDModel)
 group by m.Model_Name;


--Q7--END	
--Q8--BEGIN


select manufacturer_name , y as [year] from
( select  Manufacturer_Name, year(date) as y, sum(totalprice) as tt,
ROW_NUMBER() over (partition by year(date) order by sum( totalprice) desc) as rn
 from DIM_MANUFACTURER a
 inner join DIM_MODEL m
 on m.IDManufacturer=a.IDManufacturer
 inner join FACT_TRANSACTIONS t
 on t.IDModel=m.IDModel 
 group by Manufacturer_Name, date ) as pp
 where rn=2 
 and( y ='2009'
  or y='2010')
 





--Q8--END
--Q9--BEGIN

select distinct Manufacturer_Name from DIM_MANUFACTURER a
inner join DIM_MODEL m
on m.IDManufacturer=a.IDManufacturer
inner join FACT_TRANSACTIONS t
on t.IDModel=m.IDModel
where datepart(year, date)='2010' 
except 
select distinct Manufacturer_Name from DIM_MANUFACTURER a
inner join DIM_MODEL m
on m.IDManufacturer=a.IDManufacturer
inner join FACT_TRANSACTIONS t
on t.IDModel=m.IDModel
where datepart(year, date) ='2009'
 
 





--Q9--END

--Q10--BEGIN


 SELECT T1.Customer_Name, T1.Year, T1.Avg_Price,T1.Avg_Qty,
    CASE
        WHEN T2.Year IS NOT NULL
        THEN FORMAT(CONVERT(DECIMAL(8,2),(T1.Avg_Price-T2.Avg_Price))/CONVERT(DECIMAL(8,2),T2.Avg_Price),'p') ELSE NULL 
        END AS 'YEARLY_%_CHANGE'
    FROM
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Price, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date)
        )T1
    left join
        (SELECT t2.Customer_Name, YEAR(t1.DATE) AS YEAR, AVG(t1.TotalPrice) AS Avg_Price, AVG(t1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS t1 
        left join DIM_CUSTOMER as t2 ON t1.IDCustomer=t2.IDCustomer
        where t1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
        group by t2.Customer_Name, YEAR(t1.Date)
        )T2
        on T1.Customer_Name=T2.Customer_Name and T2.YEAR=T1.YEAR-1 





--Q10--END
	