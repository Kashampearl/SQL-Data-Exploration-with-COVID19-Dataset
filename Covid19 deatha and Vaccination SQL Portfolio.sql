use PortfolioProject

--Displaying the Covi Deaths Table
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--Displaying the Covi Vaccination Table
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

--SELECTING THE DATA THAT WE WILL BE USING
SELECT continent,location,date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Looking at Total cases verses total death
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases * 100) AS deathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 2,1;

--Looking at the Total cases verses total death for Nigeria
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases * 100) AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_deaths IS NOT NULL AND location = 'Nigeria'

--ORDER BY total_deaths;
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases * 100) AS deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at total cases verses population
--This will show the percentage of the population that had covid
SELECT location, date, population, total_cases,(total_cases/population * 100) AS Percentage_case_by_population
FROM PortfolioProject..CovidDeaths
ORDER BY Percentage_case_by_population DESC;

--Looking at countries with the highest infected rate compared with their population
SELECT location, population,
MAX(total_cases) AS highest_infection_count, 
MAX(total_cases/population * 100) AS Percentage_of_pop_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Percentage_of_pop_infected DESC;

--Showing countries with the highest death count by population
SELECT location, date, population, total_deaths,(total_deaths/population * 100) AS Percentage_death_by_population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY Percentage_death_by_population DESC;

--Looking at the highest death count per day
SELECT location, date, population, MAX(total_deaths) AS MAX_DeathCoutnt,(total_deaths/population * 100) AS Percentage_death_by_population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, date, population, total_deaths
ORDER BY Percentage_death_by_population DESC;

--Looking at total Death count by country
SELECT location, MAX(CAST(Total_deaths AS INT)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Looking at the total death count by continent
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount DESC;

--Looking at total death count by continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY totalDeathCount DESC;

--GLOBAL NUMBERS
SELECT date,sum(new_cases) AS total_cases, 
			sum(cast((new_deaths)as int)) AS total_deaths, 
			sum(cast((new_deaths)as int))/sum(new_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY total_cases DESC

--looking at the total cases across the world
SELECT sum(new_cases) AS total_cases, 
			sum(cast((new_deaths)as int)) AS total_deaths, 
			sum(cast((new_deaths)as int))/sum(new_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2,1;


--looking at the vaccination table
--Joining the 2 tables using an inner join
SELECT *
FROM PortfolioProject..CovidDeaths as dea
INNER JOIN PortfolioProject..CovidVaccinations as cov
ON dea.location = cov.location
AND dea.date = cov.date;

--Looking at total vaccination verses population
SELECT dea.continent, dea.location, dea.date, dea.population,cov.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS cov
ON dea.location = cov.location
AND dea.date = cov.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


--Finding the cummulative count of vaccinated people by country
SELECT dea.continent, dea.location, dea.date, dea.population,cov.new_vaccinations,
		SUM(CAST(cov.new_vaccinations AS INT)) over (partition by dea.location
		order by dea.location, dea.date) AS cummulative_total_vaccination_per_country
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS cov
ON dea.location = cov.location
AND dea.date = cov.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Looking for the percentage of people vaccinated per country
--we can do this using the cummulative_total_vaccination_per_country and dividing it by population and then
--multiply by 100. This will return an error bcos cummulative_total_vaccination_per_country is a temporary column name
--and sql doesnt store it as a full column. Best thing is to use a CTE by creating like a a new table where SQL sees it as a stored column name under the new table

SELECT dea.continent, dea.location, dea.date, dea.population,cov.new_vaccinations,
		SUM(CAST(cov.new_vaccinations AS INT)) over (partition by dea.location
		order by dea.location, dea.date) AS cummulative_total_vaccination_per_country,
		(cummulative_total_vaccination_per_country/population) * 100
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS cov
ON dea.location = cov.location
AND dea.date = cov.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

----USING CTE
----With cte, our new column name will be registered under the cte .the order by was commented out since in can not be used with a cte
----out new cte table is called popversesvacc
--WITH PopversesVacc (continent, location, date, population,new_vaccinations,
--		cummulative_total_vaccination_per_country)
--as ( SELECT dea.continent, dea.location, dea.date, dea.population,cov.new_vaccinations,
--		SUM(CAST(cov.new_vaccinations AS INT)) over (partition by dea.location
--		order by dea.location, dea.date) AS cummulative_total_vaccination_per_country
--FROM PortfolioProject..CovidDeaths AS dea
--INNER JOIN PortfolioProject..CovidVaccinations AS cov
--ON dea.location = cov.location
--AND dea.date = cov.date
--WHERE dea.continent IS NOT NULL)
----ORDER BY 2,3)
--SELECT *
--FROM PopversesVacc
----We can now go ahead and do our calculations now

--WITH PopversesVacc (continent, location, date, population,new_vaccinations,cummulative_total_vaccination_per_country)
--as ( SELECT dea.continent, dea.location, dea.date, dea.population,cov.new_vaccinations,
--		SUM(CAST(cov.new_vaccinations AS INT)) over (partition by dea.location
--		order by dea.location, dea.date) AS cummulative_total_vaccination_per_country,
--		(cummulative_total_vaccination_per_country/population)*100
--FROM PortfolioProject..CovidDeaths AS dea
--INNER JOIN PortfolioProject..CovidVaccinations AS cov
--ON dea.location = cov.location
--AND dea.date = cov.date
--WHERE dea.continent IS NOT NULL)
----ORDER BY 2,3)
--SELECT *
--FROM PopversesVacc




