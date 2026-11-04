
-- Create the hospital analytics database if it does not exist
IF DB_ID('HospitalQualityAnalytics') IS NULL
BEGIN
    CREATE DATABASE HospitalQualityAnalytics;
END;
GO

-- Select the database
USE HospitalQualityAnalytics;
GO

-- Verify that the database is selected
SELECT DB_NAME() AS CurrentDatabase;


-- Select the hospital quality analytics database
USE HospitalQualityAnalytics;
GO

-- Verify the total number of imported hospital records
SELECT
    COUNT(*) AS Total_Records
FROM dbo.HospitalQualityRaw;

-- Identify the number of unique hospitals in the dataset
SELECT
    COUNT(DISTINCT Facility_ID) AS Unique_Hospitals
FROM dbo.HospitalQualityRaw;

-- Determine the number of distinct hospital quality measures
SELECT
    COUNT(DISTINCT Measure_ID) AS Total_Quality_Measures
FROM dbo.HospitalQualityRaw;


-- Analyze reporting completeness for each hospital quality measure
SELECT
    Measure_ID,
    Measure_Name,

    -- Count the total hospital records for each measure
    COUNT(*) AS Total_Hospitals,

    -- Count records containing a valid numeric score
    COUNT(TRY_CONVERT(FLOAT, Score)) AS Available_Scores,

    -- Count records without a valid numeric score
    COUNT(*) - COUNT(TRY_CONVERT(FLOAT, Score)) AS Missing_Scores,

    -- Calculate the percentage of records with available scores
    ROUND(
        100.0 * COUNT(TRY_CONVERT(FLOAT, Score))
        / NULLIF(COUNT(*), 0),
        2
    ) AS Availability_Percentage

FROM dbo.HospitalQualityRaw

-- Group records by hospital quality measure
GROUP BY
    Measure_ID,
    Measure_Name

-- Show measures with the lowest reporting availability first
ORDER BY Availability_Percentage ASC;


-- Examine the relationship between footnote codes and score availability
SELECT
    -- Group records by their reported footnote code
    COALESCE(NULLIF(LTRIM(RTRIM(Footnote)), ''), 'No Footnote')
        AS Footnote_Category,

    -- Count all records within each footnote category
    COUNT(*) AS Total_Records,

    -- Count records containing numeric scores
    COUNT(TRY_CONVERT(FLOAT, Score)) AS Available_Scores,

    -- Count records without numeric scores
    COUNT(*) - COUNT(TRY_CONVERT(FLOAT, Score))
        AS Missing_Scores,

    -- Calculate the score availability percentage
    CAST(
        100.0 * COUNT(TRY_CONVERT(FLOAT, Score))
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS Availability_Percentage

FROM dbo.HospitalQualityRaw

-- Analyze all quality measures together
GROUP BY
    COALESCE(NULLIF(LTRIM(RTRIM(Footnote)), ''), 'No Footnote')

-- Display the most common footnote categories first
ORDER BY Total_Records DESC;


-- Calculate the overall completeness of reported hospital quality scores
SELECT
    -- Count all records in the source dataset
    COUNT(*) AS Total_Records,

    -- Count scores that can be converted to numeric values
    COUNT(TRY_CONVERT(FLOAT, Score)) AS Available_Scores,

    -- Count records without a valid numeric score
    COUNT(*) - COUNT(TRY_CONVERT(FLOAT, Score))
        AS Missing_Scores,

    -- Calculate the percentage of records containing numeric scores
    CAST(
        100.0 * COUNT(TRY_CONVERT(FLOAT, Score))
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS Availability_Percentage

FROM dbo.HospitalQualityRaw;


-- Analyze the geographic distribution of hospitals
SELECT
    -- Identify the state or territory
    State,

    -- Count distinct hospitals to avoid counting multiple measures per hospital
    COUNT(DISTINCT Facility_ID) AS Total_Hospitals

FROM dbo.HospitalQualityRaw

-- Group hospitals by geographic location
GROUP BY State

-- Display states with the highest number of hospitals first
ORDER BY Total_Hospitals DESC;


-- Analyze hospital-wide mortality reporting completeness by state
SELECT
    State,

    -- Count hospitals represented in each state
    COUNT(DISTINCT Facility_ID) AS Total_Hospitals,

    -- Count hospitals with valid numeric mortality scores
    COUNT(TRY_CONVERT(FLOAT, Score)) AS Available_Scores,

    -- Count hospitals without numeric mortality scores
    COUNT(*) - COUNT(TRY_CONVERT(FLOAT, Score))
        AS Missing_Scores,

    -- Calculate the percentage of available mortality scores
    CAST(
        100.0 * COUNT(TRY_CONVERT(FLOAT, Score))
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5, 2)
    ) AS Availability_Percentage

FROM dbo.HospitalQualityRaw

-- Focus on the hospital-wide mortality measure
WHERE Measure_ID = 'Hybrid_HWM'

-- Group results by state or territory
GROUP BY State

-- Display locations with the lowest score availability first
ORDER BY Availability_Percentage ASC;


-- Compare hospital-wide mortality rates across states and territories
WITH StateMortality AS (
    SELECT
        State,

        -- Count hospitals with valid numeric mortality scores
        COUNT(TRY_CONVERT(FLOAT, Score)) AS Hospitals_With_Scores,

        -- Calculate average reported mortality rates
        AVG(TRY_CONVERT(FLOAT, Score)) AS Average_Mortality_Rate,

        -- Identify the lowest and highest reported rates
        MIN(TRY_CONVERT(FLOAT, Score)) AS Minimum_Rate,
        MAX(TRY_CONVERT(FLOAT, Score)) AS Maximum_Rate

    FROM dbo.HospitalQualityRaw

    -- Restrict the analysis to hospital-wide mortality
    WHERE Measure_ID = 'Hybrid_HWM'

    -- Aggregate hospital results by state
    GROUP BY State
)

-- Display locations with sufficient available scores
SELECT
    State,
    Hospitals_With_Scores,

    -- Round rates to two decimal places for reporting
    CAST(Average_Mortality_Rate AS DECIMAL(10, 2)) AS Average_Mortality_Rate,
    CAST(Minimum_Rate AS DECIMAL(10, 2)) AS Minimum_Rate,
    CAST(Maximum_Rate AS DECIMAL(10, 2)) AS Maximum_Rate

FROM StateMortality

-- Require at least 30 hospitals with valid scores
WHERE Hospitals_With_Scores >= 30

-- Rank locations by highest average reported mortality rate
ORDER BY Average_Mortality_Rate DESC;


-- Calculate hospital-wide mortality statistics for each state
WITH StateMortality AS (
    SELECT
        State,

        -- Count hospitals with valid mortality scores
        COUNT(TRY_CONVERT(FLOAT, Score)) AS Hospitals_With_Scores,

        -- Calculate average, minimum, and maximum mortality rates
        AVG(TRY_CONVERT(FLOAT, Score)) AS Average_Mortality_Rate,
        MIN(TRY_CONVERT(FLOAT, Score)) AS Minimum_Rate,
        MAX(TRY_CONVERT(FLOAT, Score)) AS Maximum_Rate

    FROM dbo.HospitalQualityRaw

    -- Focus on the hospital-wide mortality measure
    WHERE Measure_ID = 'Hybrid_HWM'

    -- Aggregate hospital results by state
    GROUP BY State
)

-- Display state-level mortality statistics
SELECT
    State,
    Hospitals_With_Scores,

    -- Format mortality rates to two decimal places
    CAST(Average_Mortality_Rate AS DECIMAL(10, 2)) AS Average_Mortality_Rate,
    CAST(Minimum_Rate AS DECIMAL(10, 2)) AS Minimum_Rate,
    CAST(Maximum_Rate AS DECIMAL(10, 2)) AS Maximum_Rate

FROM StateMortality

-- Include states with at least 30 valid hospital scores
WHERE Hospitals_With_Scores >= 30

-- Display the highest average mortality rates first
ORDER BY Average_Mortality_Rate DESC;
