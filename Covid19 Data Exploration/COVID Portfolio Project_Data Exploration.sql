--try join on my own - join covidVaccination to covidDeaths on date, lOCATION
-- Looking at totalDeaths, totalCases and totalVaccinations per continent -Globally
SELECT dea.continent, MAX(CAST(dea.total_cases as bigint)) as MaxTotalCases, 
	MAX(CAST(dea.total_deaths as bigint)) as MaxTotalDeaths, 
	MAX(CAST(vac.total_vaccinations as bigint)) as MaxTotalVaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
--WHERE dea.continent is not null
GROUP BY dea.continent
ORDER BY 2 desc


-- Looking at totalDeaths, totalCases and totalVaccinations per location -Globally
SELECT dea.location, MAX(CAST(dea.total_cases as bigint)) as MaxTotalCases, 
	MAX(CAST(dea.total_deaths as bigint)) as MaxTotalDeaths, 
	MAX(CAST(vac.total_vaccinations as bigint)) as MaxTotalVaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location
ORDER BY 2 desc

  -- Selecting the columns we will be using

SELECT location,date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths$
ORDER BY 1,2

---- Looking at Total Deaths Vs Total Cases
SELECT location, date, total_cases, total_deaths, 
	(CAST(total_deaths as float) / CAST(total_cases as float))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%mozambique%'
ORDER BY 1,2

--- Looking at the Total Cases vs the Population (Mozambique)
--- this shows the percentage of the population who got covid

SELECT location, population, date, total_cases, 
	(CAST(total_cases as float) / population )*100 AS TotalCasesPercentage
FROM CovidDeaths$
WHERE location like '%mozambique%'
ORDER BY 1,3

--- Looking at the Total Deaths vs the Population (Mozambique)
--- this shows the percentage of the population who died

SELECT location, population, date, total_deaths, 
	(CAST(total_deaths as float) / population )*100 AS DeathPercentagePerPopulation
FROM CovidDeaths$
WHERE location like '%mozambique%'
ORDER BY 1,3

--- Looking at countries with high infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX((CAST(total_cases as float) / population )*100) AS PercentPopulationInfected
FROM CovidDeaths$
--WHERE location like '%mozambique%'
GROUP BY location, population
ORDER BY PercentPopulationInfected Desc

--- Looking at countries with high Death count compared to population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathsCount,
	Max((cast(total_deaths as float) / population) * 100) as DeathPercentPopulation
FROM CovidDeaths$
--WHERE location like '%mozambique%'
WHERE continent is not null and continent like '%Africa%'
GROUP BY location
ORDER BY TotalDeathsCount Desc;


--Breaking down in continents

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathsCount,
	Max((cast(total_deaths as float) / population) * 100) as DeathPercentPopulation
FROM CovidDeaths$
--WHERE location like '%mozambique%'
WHERE continent is not null 
--and continent like '%Africa%'
GROUP BY continent
ORDER BY TotalDeathsCount Desc;

--Global Numbers
-- Total deaths per Continent

SELECT SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	(SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float))) * 100 as DeathPercentPopulation
FROM CovidDeaths$
--WHERE location like '%mozambique%'
WHERE continent is not null
--and continent like '%Africa%'
--GROUP BY date
ORDER BY 1,2;

-- Joining Tables
-- Looking at Total population vs Vaccinations - Rolling Count of Vaccinations daily 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--GROUP BY dea.date
order by 2,3


-- Using CTE to calculate the ratio of population that are vaccinated daily
-- Looking at Total population vs Vaccinations - Rolling Count of Vaccinations daily 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--GROUP BY dea.date
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated / population) * 100 as RollingPeopleVaccinatedRate
FROM PopvsVac
order by 2,3


-- Using Temp table to calculate the ratio of population that are Tested daily
-- Looking at Total population vs New people tested - Rolling Count of new people tested daily 
DROP TABLE if exists #PopvsTested
CREATE TABLE #PopvsTested (continent nvarchar (255), 
	location nvarchar (255), 
	date datetime, 
	population numeric, 
	new_tests numeric, 
	RollingPeopleTested numeric
)

INSERT INTO #PopvsTested
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
	SUM(CAST(vac.new_tests as bigint)) OVER (partition by dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleTested
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 
----GROUP BY dea.date, NewVaccinations
--order by 2,3

SELECT *, (RollingPeopleTested / population) * 100 as RollingPeopleTestedRatio
FROM #PopvsTested
--WHERE location like '%mozambique%'
order by 2,3



-- Creating Views

-- Creating view for Total Number of People Tested in a population

CREATE VIEW RollingPeopleTested as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
	SUM(CAST(vac.new_tests as bigint)) OVER (partition by dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleTested
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null 
----GROUP BY dea.date, NewVaccinations
--order by 2,3


-- Creating view for Total Number of People Vaccinated in a population (Rolling Count of daily total number of vaccinated people)

CREATE VIEW RollingPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY 
	dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--GROUP BY dea.date
--order by 2,3