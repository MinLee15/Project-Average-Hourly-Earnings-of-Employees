--CHECK FOR ANY DUPLICATES 
WITH CTE_row_num1 AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY Country,
				 Code,
				 Year,
				 Average_Hourly_Earnings
				 ORDER BY Code
				 ) AS row_num1
FROM Project_AverageEarning..average_hourly_earnings
)

SELECT DISTINCT (row_num1),COUNT(row_num1)
FROM CTE_row_num1
GROUP BY row_num1


--CHECK AND DELETE ROWS WITH EMPTY DATA 
SELECT COUNT(Country), COUNT(Code), COUNT(Year), COUNT(Average_Hourly_Earnings)
FROM Project_AverageEarning..average_hourly_earnings

SELECT *
FROM Project_AverageEarning..average_hourly_earnings
WHERE Average_Hourly_Earnings IS NULL

DELETE FROM Project_AverageEarning..average_hourly_earnings
WHERE Average_Hourly_Earnings IS NULL


--PLOT OF AVG SALARY BY COUNTRY
DROP TABLE IF EXISTS #AverageSalary
CREATE TABLE #AverageSalary
(
Country VARCHAR(20),
AvgSalary FLOAT(10)
)

INSERT INTO #AverageSalary
SELECT Country, AVG(Average_Hourly_Earnings) AS AvgSalary
FROM Project_AverageEarning..average_hourly_earnings
GROUP BY Country

SELECT * 
FROM #AverageSalary

ALTER TABLE #AverageSalary
ADD AvgSalaryConverted DECIMAL(10,2)
UPDATE #AverageSalary
SET AvgSalaryConverted = CONVERT(DECIMAL(10,2),AvgSalary)
ALTER TABLE #AverageSalary
DROP COLUMN AvgSalary


--PLOT OF AVG SALARY BY YEAR FOR SELECTED COUNTRIES

SELECT Country, Year, Average_Hourly_Earnings
FROM Project_AverageEarning..average_hourly_earnings
GROUP BY Country, Year, Average_Hourly_Earnings
ORDER BY Country,Year
 

 --YEARLY GROWTH RATE FOR EACH COUNTRIES
WITH CTE_GrowthRate AS
(
SELECT Country, Year, Average_Hourly_Earnings,
COUNT (Country) OVER (PARTITION BY Country) AS CountryCount,
Average_Hourly_Earnings - LAG (Average_Hourly_Earnings) OVER (PARTITION BY Country ORDER BY Year ASC) AS RevenueGrowth,
(Average_Hourly_Earnings - LAG (Average_Hourly_Earnings) OVER (PARTITION BY Country ORDER BY Year ASC)) / (LAG (Average_Hourly_Earnings) OVER (PARTITION BY Country ORDER BY Year ASC))*100 AS PercentageRevenueGrowth
FROM Project_AverageEarning..average_hourly_earnings
)
SELECT Country, Year, CountryCount, PercentageRevenueGrowth
FROM CTE_GrowthRate 
WHERE PercentageRevenueGrowth IS NOT NULL 
