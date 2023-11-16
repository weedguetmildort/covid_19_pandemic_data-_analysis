-- Weedguet Mildort
-- Covid 19 Pandemic Data Analysis
-- Description: A simple analysis of available data about
-- Covid 19 Pandemic using SQL.


-- Import CSV files from data directory as tables using built-in import tools
-- Data are imported under the database named "covid_pandemic_database"
-- The tables are named "covid_deaths" and "covid_vaccinations"

-- Display covid_deaths table
SELECT *
FROM covid_pandemic_database.covid_deaths;

-- Display specific columns of covid_deaths table
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_pandemic_database.covid_deaths;

-- Display total cases vs total deaths on specific dates
-- To showcase likelihood of death in case of infection in specific countries
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM covid_pandemic_database.covid_deaths
WHERE total_cases IS NOT NULL
AND total_deaths IS NOT NULL;

-- Display total cases vs population on specific dates
-- Shows what percentage of population infected with Covid
SELECT location, date, Population, total_cases,  (total_cases/population) * 100 AS PercentPopulationInfected
FROM covid_pandemic_database.covid_deaths
WHERE total_cases IS NOT NULL
AND population IS NOT NULL;

-- List locations by their maximum percentage of population infected within time frame of data
SELECT location, population,
       MAX(total_cases) AS HighestInfectionCount,
       Max((total_cases/population)) * 100 AS PercentPopulationInfected
FROM covid_pandemic_database.covid_deaths
WHERE total_cases IS NOT NULL
AND population IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- List locations by their maximum death count within time frame of data
SELECT location,
       MAX(total_deaths) AS TotalDeathCount
FROM covid_pandemic_database.covid_deaths
WHERE total_deaths IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC ;

-- List continents in order of their death count per population
SELECT continent,
       MAX(total_deaths) AS TotalDeathCount
FROM covid_pandemic_database.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Show global values by adding non repeating values
Select SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
FROM covid_pandemic_database.covid_deaths
WHERE continent IS NOT NULL;

-- Display covid_vaccinations table
SELECT *
FROM covid_pandemic_database.covid_vaccinations;

