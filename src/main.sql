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

-- Show percentage of population that has received at least one Covid vaccine
SELECT cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
           AS RollingPeopleVaccinated
FROM covid_pandemic_database.covid_vaccinations AS cv
    JOIN covid_pandemic_database.covid_deaths AS cd
        ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.new_vaccinations IS NOT NULL
AND cv.continent IS NOT NULL
ORDER BY cv.continent, cv.location;

-- Use Common Table Expressions (CTE) to perform more calculations on partition by in previous query
WITH PopulationVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
           AS RollingPeopleVaccinated
FROM covid_pandemic_database.covid_vaccinations AS cv
    JOIN covid_pandemic_database.covid_deaths AS cd
        ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.new_vaccinations IS NOT NULL
AND cv.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentageVaccinations
FROM PopulationVaccination
ORDER BY continent, location, date;

-- Use temporary table to perform calculation on partition by in previous query
DROP TABLE IF EXISTS covid_pandemic_database.PercentPopulationVaccinated;
CREATE TABLE covid_pandemic_database.PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date TEXT,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

INSERT INTO covid_pandemic_database.PercentPopulationVaccinated
SELECT cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
           AS RollingPeopleVaccinated
FROM covid_pandemic_database.covid_vaccinations AS cv
    JOIN covid_pandemic_database.covid_deaths AS cd
        ON cv.location = cd.location AND cv.date = cd.date
WHERE cv.new_vaccinations IS NOT NULL
AND cv.continent IS NOT NULL
ORDER BY cv.continent, cv.location;

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM covid_pandemic_database.PercentPopulationVaccinated;
