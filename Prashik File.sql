use aviation_project;

 SET sql_safe_updates=0;

 ALTER TABLE dataset ADD Scheduled_Date Date;
Update dataset SET Scheduled_Date=DATE(CONCAT(Year,'-',Month,'-',Day)) ;

SELECT * FROM dataset;

CREATE VIEW DATE_view AS
SELECT 
DATE(CONCAT(Year,'-',Month,'-',Day)) AS `DATE`
FROM dataset;
SELECT * FROM DATE_view;

-- calculation Quarter-------------------------------------------------------------------------

SELECT DATE,
QUARTER(date) AS QUARTER
FROM DATE_view;

-- Calculating Month Full Name----------------------------------------------------------------------------------------

SELECT DATE,
MONTHNAME(DATE) AS MONTH_NAME
FROM DATE_VIEW;

-- Calculating date in format YYYY-MM

SELECT 
DATE,DATE_FORMAT(DATE, '%Y-%m') AS 'YYYY-MM'
FROM DATE_view;

-- Calculating Weekday No.-------------------------------------------------------------------------
SELECT 
DATE,
DAYOFWEEK(Date) + 1 AS DayNumber        -- Sunday is 1 and saturday 7
FROM DATE_view;
-- ---------------------------------------------------------------------------------------------------
-- calculating WEEKday name--------------------------------------------------------------------------

SELECT
DATE, DAYNAME(DATE) AS WEEKDAY_NAME
FROM DATE_view;

-- calculating Finncial Month-----------------------------------------------------------------------


SELECT DATE,
    CASE 
        WHEN MONTH(DATE) >= 4 THEN MONTH(DATE) - 3
        ELSE MONTH(DATE) + 9
    END AS Financial_Month
FROM DATE_view;

-- Calculating Financial Quarter---------------------------

SELECT DATE,
    CASE 
        WHEN MONTH(DATE) IN (4, 5, 6) THEN 1
        WHEN MONTH(DATE) IN (7, 8, 9) THEN 2
        WHEN MONTH(DATE) IN (10, 11, 12) THEN 3
        ELSE 4
    END AS Financial_Quarter
FROM DATE_view;

-- Calculating load Factor percentage on a yearly , Quarterly , Monthly basis

-- Year wise Load factor-----------------------------------------------------------------------
SELECT 
    year(Scheduled_Date),
    SUM(_Transported_Passengers) / SUM(_Available_Seats) * 100 AS load_factor_percentage
FROM dataset
GROUP BY YEAR(Scheduled_Date);

-- month wise Load factor----------------------------------------------------------------------
SELECT 
	MONTHNAME(Scheduled_Date) AS month,
    MONTH(Scheduled_Date),
    SUM(_Transported_Passengers) / SUM(_Available_Seats) * 100 AS load_factor_percentage
FROM dataset
GROUP BY 
	MONTH(Scheduled_Date),MONTHNAME(Scheduled_Date)
ORDER BY
	MONTH(Scheduled_Date);
    
 -- Quarter wise Load factor---------------------------------------------------------------------   

SELECT 
	QUARTER(Scheduled_Date) AS Quarter,
    SUM(_Transported_Passengers) / SUM(_Available_Seats) * 100 AS load_factor_percentage
FROM dataset
GROUP BY QUARTER(Scheduled_Date)
ORDER BY QUARTER(Scheduled_Date);

-- Year, Month and Quarter wise ------------------------------------------------------------------------
SELECT 
    year(Scheduled_Date),
    MONTHNAME(Scheduled_Date),
    MONTH(Scheduled_Date),
    QUARTER(Scheduled_Date),
    SUM(_Transported_Passengers) / SUM(_Available_Seats) * 100 AS load_factor_percentage
FROM dataset
GROUP BY 
		YEAR(Scheduled_Date),
        MONTHNAME(Scheduled_Date),
         MONTH(Scheduled_Date),
		QUARTER(Scheduled_Date)
ORDER BY
		YEAR(Scheduled_Date),
        MONTH(Scheduled_Date),
        MONTHNAME(Scheduled_Date),
		QUARTER(Scheduled_Date);
		
 


-- ------------------------------------------------------------------------------------------------------------
-- Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
SELECT
    Carrier_Name,
    SUM(_Transported_Passengers) / SUM(_Available_Seats) * 100 AS LoadFactorPercentage
FROM
    dataset
GROUP BY
    Carrier_Name;
    
    
-- ---------------------------------------------------------------------------------------------------------
-- Identify Top 10 Carrier Names based passengers preference 

SELECT
   Carrier_Name,
    COUNT(*) AS PreferenceCount
FROM
    dataset
GROUP BY
Carrier_Name
ORDER BY
    PreferenceCount DESC
    LIMIT 10;

-- -------------------------------------------------------------------------------------------------------------
-- 5. Display top Routes ( from-to City) based on Number of Flights 

SELECT 
From_To_City, SUM(_Transported_Passengers)
FROM dataset
GROUP BY 
	Carrier_Name,From_To_City
ORDER BY
	SUM(_Transported_Passengers) DESC
LIMIT 10;
-- -------------------------------------------------------------------------------------------------------------------
-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.


SELECT
   
    CASE WHEN DAYOFWEEK(Scheduled_Date) = 1 OR DAYOFWEEK(Scheduled_Date) = 7 THEN 'Weekend' ELSE 'Weekday' END AS Week,
    SUM(_Transported_Passengers) / SUM(_Available_Seats) * 100 AS LoadFactorPercentage
FROM
   dataset
GROUP BY
    Week;

-- ---------------------------------------------------------------------------------------------------------------------
-- 8. Identify number of flights based on Distance groups

SELECT 
dg.Distance_Interval, count(m.Airline_ID)
FROM distance_groups as dg JOIN dataset as m
ON DG.Distance_Group_ID = M.Distance_Group_ID
GROUP BY
	dg.Distance_Interval
	
ORDER BY 
	count(m.Airline_ID) DESC;
    

-- ----------------------------------------------------------------------------------------------------------------------
-- Searching Flight-------------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE SearchFlights(
    IN origin_Country VARCHAR(255),
    IN origin_State VARCHAR(255),
    IN origin_City VARCHAR(255),
    IN destination_Country VARCHAR(255),
    IN destination_State VARCHAR(255),
    IN destination_City VARCHAR(255)
)
BEGIN
    SELECT
        Airline_Id,
        `Origin_Country`,
        `Origin_State`,
        `Origin_City`,
        `Destination_Country`,
        `Destination_State`,
        `Destination_City`
    FROM
        dataset
    WHERE
        `Origin_Country` = origin_Country
        AND `Origin_State` = origin_State
        AND `Origin_City` = origin_City
        AND `Destination_Country` = destination_Country
        AND `Destination_State` = destination_State
        AND `Destination_City` = destination_City;
END //

DELIMITER ;












