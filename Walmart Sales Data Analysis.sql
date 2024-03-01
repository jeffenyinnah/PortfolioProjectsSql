-- Conducting Data Exploration on Walmart Sales data to get insight into this dataset and for learning
-- There are a couple of business case questions i will be answering here

-- This dataset has no null values
 SELECT * FROM WalmartSalesData#csv$;


------------------------------ Feature Engineering -----------------------
-- Extract out time of day, day name, month name from Date, time and creating new columns with them

------------------------------1. Time of Day Extraction (This will give insights of sales in the morning, noon or night) -----------------------------

-- Add 2 new Columns for time_of_day and extractedTime (Time part of the datetime)
ALTER TABLE WalmartSalesData#csv$ ADD time_of_day VARCHAR(20)
ALTER TABLE WalmartSalesData#csv$ ADD extractedTime TIME;

UPDATE WalmartSalesData#csv$ SET extractedTime = CONVERT (time, Time); --Extracting and Updating extractedTime to the dataset

--SELECT extractedTime,
--	CASE 
--		WHEN extractedTime BETWEEN '00:00:00.000' AND '12:00:00.000' THEN 'Morning'
--		WHEN extractedTime BETWEEN '12:01:00.000' AND '16:00:00.000' THEN 'Afternoon'
--		ELSE 'Evening'
--	END	as timeOfDay

--FROM WalmartSalesData#csv$

-- Updating time_of_day
UPDATE WalmartSalesData#csv$ 
SET time_of_day = 
	CASE 
		WHEN extractedTime BETWEEN '00:00:00.000' AND '12:00:00.000' THEN 'Morning'
		WHEN extractedTime BETWEEN '12:01:00.000' AND '16:00:00.000' THEN 'Afternoon'
		ELSE 'Evening'
	END

SELECT * FROM WalmartSalesData#csv$



------------------------------Day Name Extraction (This will give insights of sales and what day tractions took place, Monday, Tuesday etc) -----------------------------

--- Add a column 'DayName' to store the Day Name Extraction
ALTER TABLE WalmartSalesData#csv$ ADD DayName VARCHAR (20)

-- Update 'DayName' 
UPDATE WalmartSalesData#csv$ SET DayName = DATENAME(DW, Date)
SELECT * FROM WalmartSalesData#csv$


------------------------------Month Name (This will give insights of sales and what months tractions took place, January, February etc) -----------------------------------
--- Add a column 'MonthName' to store the Month Name Extraction
ALTER TABLE WalmartSalesData#csv$ ADD MonthName VARCHAR (20)

-- Update 'DayName' 
UPDATE WalmartSalesData#csv$ SET MonthName = DATENAME(M, Date)
SELECT * FROM WalmartSalesData#csv$


------------------------------------BUSINESS QUESTIONS---------------------------------------------------

---1. How many Unique Cities does the data have?
SELECT DISTINCT City 
FROM WalmartSalesData#csv$
--GROUP BY City

---2. In which city is each branch?
SELECT DISTINCT City, Branch
FROM WalmartSalesData#csv$

--- How many Unique product lines does the data have?

SELECT COUNT(DISTINCT [Product line]) --#6
FROM WalmartSalesData#csv$

-- What is the most common payment method? # Ewallet
SELECT Payment, COUNT(Payment) as PaymetCount
FROM WalmartSalesData#csv$
GROUP BY Payment

--- What is the most selling Productline?  #Food and beverages
SELECT [Product line], COUNT([Product line])
FROM WalmartSalesData#csv$
GROUP BY [Product line]
ORDER BY 2 DESC

--- What is the total revenue by month?
SELECT MonthName, SUM(Total) as TotalRevenue
FROM WalmartSalesData#csv$
GROUP BY MonthName
ORDER BY 2 DESC

--- What month had the largest COGS - Cost of Goods SOld?
SELECT MonthName, SUM(cogs) as CostOfGoodsSold
FROM WalmartSalesData#csv$
GROUP BY MonthName
ORDER BY 2 DESC

--- What Product line had the largest Revenue?
SELECT [Product line], SUM(Total) as Revenue
FROM WalmartSalesData#csv$
GROUP BY [Product line]
ORDER BY Revenue DESC

--- What is the City with the largest Revenue?
SELECT City, SUM(Total) as Revenue
FROM WalmartSalesData#csv$
GROUP BY City
ORDER BY Revenue DESC

--- What product line had the largest VAT?

SELECT [Product line], AVG([Tax 5%]) as VAT
FROM WalmartSalesData#csv$
GROUP BY [Product line]
ORDER BY 2 DESC

--- Which Branch sold more products than average products sold?

SELECT Branch, SUM(Quantity) as Qty
FROM WalmartSalesData#csv$
GROUP BY Branch
HAVING SUM(Quantity) > AVG(Quantity)
ORDER BY 2 DESC

--- What is the most common product line by Gender?
SELECT Gender, [Product line], COUNT(Gender) as GenderCount
FROM WalmartSalesData#csv$
GROUP BY Gender, [Product line]
ORDER BY 3

--- What is the AVG rating of each product line?

SELECT [Product line], AVG(Rating) as AvgRating
FROM WalmartSalesData#csv$
GROUP BY [Product line]

---- ----------------------------------------------------------SALES QUESTIONS--------------------------------------

--- Number of sales made in each time of the day per weekday & Per Month
SELECT time_of_day, COUNT(*) as TotalSales
FROM WalmartSalesData#csv$
WHERE DayName = 'Tuesday'
--WHERE MonthName = 'January'
GROUP BY time_of_day
ORDER BY 2

--- Which customer types brings the most revenue?
SELECT [Customer type], SUM(Total) as Revenue 
FROM WalmartSalesData#csv$
GROUP BY [Customer type]
ORDER BY 2 DESC

--- Which CIty has the largest Tax percent/VAT (Value Added Tax)?
SELECT City, ROUND(AVG([Tax 5%]), 2) as VAT
FROM WalmartSalesData#csv$
GROUP BY City
ORDER BY 2 DESC

--- Which Customer type pays the most VAT?
SELECT [Customer type], AVG([Tax 5%]) as VAT 
FROM WalmartSalesData#csv$
GROUP BY [Customer type]
ORDER BY 2 DESC

---- ----------------------------------------------------------CUSTOMER QUESTIONS--------------------------------------

--- How Many Unique customer types does the data have?
SELECT DISTINCT [Customer type]
FROM WalmartSalesData#csv$

--- How many unique payment methods does the data have?
SELECT DISTINCT Payment
FROM WalmartSalesData#csv$

--- What is the most common customer type?
SELECT DISTINCT COUNT([Customer type]), [Customer type] FROM WalmartSalesData#csv$
GROUP BY [Customer type]

--- Which customer type buys the most?
SELECT [Customer type], COUNT(*) as CustomerCount
FROM WalmartSalesData#csv$
GROUP BY [Customer type]
ORDER BY 2 DESC

--- what is the Gender of most of the Customers?
SELECT [Gender], COUNT(*) as GenderCount
FROM WalmartSalesData#csv$
GROUP BY [Gender]
ORDER BY 2 DESC

--- what is the Gender Distribution per Branch?
SELECT [Gender], Branch, COUNT(*) as GenderCount
FROM WalmartSalesData#csv$
GROUP BY [Gender], Branch
ORDER BY 2 DESC

--- What time of the day do customers give most rating
--CREATE VIEW MostRatings as 
SELECT time_of_day, AVG(Rating) as MostRatings
FROM WalmartSalesData#csv$
GROUP BY time_of_day
ORDER BY 2

--- Which time of the day do customers give most ratings per branch
SELECT time_of_day, Branch, ROUND(AVG(Rating), 2) as MostRatings
FROM WalmartSalesData#csv$
GROUP BY time_of_day, Branch
ORDER BY 2

--- Which day of the week has the best ratings?
SELECT DayName, ROUND(AVG(Rating), 2) as MostRatings
FROM WalmartSalesData#csv$
GROUP BY DayName
ORDER BY 2 DESC

