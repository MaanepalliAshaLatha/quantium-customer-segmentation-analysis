CREATE DATABASE quantium_project;
USE quantium_project;

CREATE TABLE purchase_behaviour (
  LYLTY_CARD_NBR BIGINT,
  LIFESTAGE VARCHAR(100),
  PREMIUM_CUSTOMER VARCHAR(100)
);
CREATE TABLE transactions (
 EXCEL_DATES INT,
 TORE_NBR INT,
 LYLTY_CARD_NBR INT,
 TXN_ID INT,
 PROD_NBR INT,
 PROD_NAME VARCHAR(100),
 PROD_QTY INT,
 TOT_SALES DOUBLE
);

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/ashal/Downloads/QVI_purchase_behaviour.csv'
INTO TABLE purchase_behaviour
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(LYLTY_CARD_NBR, LIFESTAGE, PREMIUM_CUSTOMER);


LOAD DATA LOCAL INFILE 'C:/Users/ashal/Downloads/QVI_transaction_data.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(EXCEL_DATES, TORE_NBR,	LYLTY_CARD_NBR,	TXN_ID,	PROD_NBR, PROD_NAME, PROD_QTY, TOT_SALES);

select count(*) from purchase_behaviour;
select * from purchase_behaviour
limit 10;

select count(*) from transactions;
select * from transactions
limit 100;

SELECT p.LIFESTAGE,
       ROUND(SUM(t.TOT_SALES),2) AS total_sales
FROM purchase_behaviour p
JOIN transactions t
ON p.LYLTY_CARD_NBR = t.LYLTY_CARD_NBR
GROUP BY p.LIFESTAGE
ORDER BY total_sales DESC;

SELECT p.LIFESTAGE,
       ROUND(AVG(t.TOT_SALES),2) AS average_sales
FROM purchase_behaviour p
JOIN transactions t
ON p.LYLTY_CARD_NBR = t.LYLTY_CARD_NBR
GROUP BY p.LIFESTAGE
ORDER BY average_sales DESC;

SELECT p.LIFESTAGE, 
COUNT(DISTINCT t.TXN_ID) as No_Of_Transactions 
FROM purchase_behaviour p 
JOIN transactions t 
ON p.LYLTY_CARD_NBR = t.LYLTY_CARD_NBR 
GROUP BY p.LIFESTAGE 
ORDER BY No_Of_Transactions desc;


SELECT LIFESTAGE,
       AVG(customer_total) AS avg_customer_spend
FROM (
    SELECT t.LYLTY_CARD_NBR,
           p.LIFESTAGE,
           SUM(t.TOT_SALES) AS customer_total
    FROM transactions t
    JOIN purchase_behaviour p
    ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
    GROUP BY t.LYLTY_CARD_NBR, p.LIFESTAGE
) x	
GROUP BY LIFESTAGE
ORDER BY avg_customer_spend desc;

SELECT p.LIFESTAGE,
       AVG(t.PROD_QTY) AS avg_qty
FROM transactions t
JOIN purchase_behaviour p
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
GROUP BY p.LIFESTAGE
ORDER BY avg_qty DESC;

SELECT p.LIFESTAGE,
       AVG(t.TOT_SALES / t.PROD_QTY) AS avg_price_per_unit
FROM transactions t
JOIN purchase_behaviour p
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
GROUP BY p.LIFESTAGE
ORDER BY avg_price_per_unit DESC;

SELECT p.LIFESTAGE,
       p.PREMIUM_CUSTOMER,
       SUM(t.TOT_SALES) AS total_sales
FROM transactions t
JOIN purchase_behaviour p
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
GROUP BY p.LIFESTAGE, p.PREMIUM_CUSTOMER
ORDER BY total_sales DESC;

SELECT
 p.LIFESTAGE, p.PREMIUM_CUSTOMER, 
count(distinct t.LYLTY_CARD_NBR) as unique_customers, 
SUM(t.TOT_SALES) AS total_sales 
FROM transactions t 
JOIN purchase_behaviour p 
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR 
GROUP BY p.LIFESTAGE, p.PREMIUM_CUSTOMER 
ORDER BY total_sales DESC;

SELECT 
p.LIFESTAGE, 
p.PREMIUM_CUSTOMER,
 count(distinct t.LYLTY_CARD_NBR) as unique_customers, 
 round(SUM(t.TOT_SALES),2) AS total_sales , 
 round(SUM(TOT_SALES) / COUNT(DISTINCT t.LYLTY_CARD_NBR),2) as revenue_per_customer 
 FROM transactions t
 JOIN purchase_behaviour p 
 ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
 GROUP BY p.LIFESTAGE, p.PREMIUM_CUSTOMER 
ORDER BY total_sales DESC;

SET SQL_SAFE_UPDATES = 0;
ALTER TABLE transactions
ADD COLUMN txn_date DATE;
UPDATE transactions
SET txn_date = DATE_ADD('1899-12-30', INTERVAL EXCEL_DATES DAY);
SET SQL_SAFE_UPDATES = 1;
SELECT txn_date FROM transactions LIMIT 5;

ALTER TABLE transactions
ADD COLUMN pack_size_g INT;
UPDATE transactions
SET pack_size_g =
CAST(
REGEXP_SUBSTR(PROD_NAME, '[0-9]+(?=g)')
AS UNSIGNED
);
SELECT PROD_NAME, pack_size_g
FROM transactions
LIMIT 10;

ALTER TABLE transactions
ADD COLUMN brand VARCHAR(50);
UPDATE transactions
SET brand = TRIM(SUBSTRING_INDEX(PROD_NAME, ' ', 1));
SELECT PROD_NAME, brand
FROM transactions
LIMIT 10;

UPDATE transactions
SET brand =
CASE
    WHEN PROD_NAME LIKE 'Old El Paso%' THEN 'Old El Paso'
    WHEN PROD_NAME LIKE 'Grain Waves%' THEN 'Grain Waves'
    WHEN PROD_NAME LIKE 'Natural Chip%' THEN 'Natural Chip Co'
    WHEN PROD_NAME LIKE 'Red Rock Deli%' THEN 'Red Rock Deli'
    ELSE TRIM(SUBSTRING_INDEX(PROD_NAME,' ',1))
END;
UPDATE transactions
SET brand =
CASE
WHEN brand='Dorito' THEN 'Doritos'
WHEN brand='GrnWves' THEN 'Grain Waves'
WHEN brand='Infzns' THEN 'Infuzions'
WHEN brand='NCC' THEN 'Natural Chip Co'
WHEN brand='RRD' THEN 'Red Rock Deli'
WHEN brand='Smith' THEN 'Smiths'
WHEN brand='Snbts' THEN 'Sunbites'
WHEN brand='WW' THEN 'Woolworths'
ELSE brand
END;

SELECT DISTINCT brand
FROM transactions
ORDER BY brand;

select brand,round(sum(tot_sales),2) as total_sales
from transactions
group by brand
order by total_sales desc;

select t.brand,round(sum(t.tot_sales),2) as total_sales
from transactions as t
join 
purchase_behaviour as p
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
where p.lifestage="OLDER FAMILIES"
group by t.brand
order by total_sales desc; 

select 
t.brand,
round(sum(t.tot_sales),2) as total_sales
from transactions as t
join 
purchase_behaviour as p
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
where p.lifestage="YOUNG SINGLES/COUPLES" and 
p.premium_customer="Mainstream"
group by t.brand
order by total_sales desc; 

select distinct premium_customer from purchase_behaviour;
select distinct lifestage  from purchase_behaviour;

UPDATE purchase_behaviour
SET premium_customer =
CASE
    WHEN premium_customer LIKE 'Mainstream%' THEN "Mainstream"
    WHEN premium_customer LIKE 'Premium%' THEN "Premium"
    WHEN premium_customer LIKE 'Budget%' THEN "Budget"
    ELSE TRIM(premium_customer)
END;

select 
round(avg(total_sales),2) as avg_customer_spend 
from
	(
    select
    t.LYLTY_CARD_NBR,
    sum(t.TOT_SALES) as total_sales
	from transactions as t
	join 
	purchase_behaviour as p
	ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
	where p.lifestage="YOUNG SINGLES/COUPLES" and
    p.premium_customer="Mainstream" and
    t.brand="Smiths"
	group by t.LYLTY_CARD_NBR
    ) tem ;
    
select 
round(avg(total_quantity),2) as avg_customer_quantity 
from
	(
    select
    t.LYLTY_CARD_NBR,
    sum(t.prod_qty) as total_quantity
	from transactions as t
	join 
	purchase_behaviour as p
	ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
	where p.lifestage="YOUNG SINGLES/COUPLES" and
    p.premium_customer="Mainstream" and
    t.brand="Smiths"
	group by t.LYLTY_CARD_NBR
    ) tem ;
    
select 
round(avg(total_sales/prod_qty),2) as avg_price_per_unit
from
	(
    select
    t.LYLTY_CARD_NBR,t.prod_qty,
    sum(t.TOT_SALES) as total_sales
	from transactions as t
	join 
	purchase_behaviour as p
	ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
	where p.lifestage="YOUNG SINGLES/COUPLES" and
    p.premium_customer="Mainstream" and
    t.brand="Doritos"
	group by t.LYLTY_CARD_NBR,t.prod_qty
    ) tem ;
    
select 
round(avg(total_sales),2) as avg_customer_spend 
from
	(
    select
    t.LYLTY_CARD_NBR,
    sum(t.TOT_SALES) as total_sales
	from transactions as t
	join 
	purchase_behaviour as p
	ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
	-- where p.lifestage="OLDER FAMILIES" and
--     p.premium_customer="Budget" and
--     t.brand="Smiths"
	group by t.LYLTY_CARD_NBR
    ) tem ;
    
select 
round(avg(total_quantity),2) as avg_customer_quantity 
from
	(
    select
    t.LYLTY_CARD_NBR,
    sum(t.prod_qty) as total_quantity
	from transactions as t
	join 
	purchase_behaviour as p
	ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
	where p.lifestage="OLDER FAMILIES" and
    p.premium_customer="Budget" and
    t.brand="Kettle"
	group by t.LYLTY_CARD_NBR
    ) tem ;
    
select 
round(avg(total_sales/prod_qty),2) as avg_price_per_unit
from
	(
    select
    t.LYLTY_CARD_NBR,t.prod_qty,
    sum(t.TOT_SALES) as total_sales
	from transactions as t
	join 
	purchase_behaviour as p
	ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
	where p.lifestage="OLDER FAMILIES" and
    p.premium_customer="Budget" and
    t.brand="Kettle"
	group by t.LYLTY_CARD_NBR,t.prod_qty
    ) tem ;
    
select 
pack_size_g,round(sum(tot_sales),2) as total_sales
from transactions
group by  pack_size_g
order by total_sales desc;

select 
p.lifestage,
count(t.pack_size_g) as count_of_packs,
t.pack_size_g,
round(sum(t.tot_sales),2) as total_sales
from transactions as t
join
purchase_behaviour as p
ON t.LYLTY_CARD_NBR = p.LYLTY_CARD_NBR
group by  p.lifestage,t.pack_size_g
order by total_sales desc;

select sum(tot_sales) from transactions;
select count( txn_id) from transactions;