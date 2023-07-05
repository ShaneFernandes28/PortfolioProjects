SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--changes datatype of column, we use decimal so we can divide it later
--can also use cast(total_deaths as decimal)
ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_deaths decimal 

--Looking at Total Cases vs Total Deaths (*100 gets the percentage)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Death in united states
--shows the likelihood of dying if you get covid in given country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like'%states%'
ORDER BY 1,2

--Looking at the total cases vs the population
--shows what percentage of population has gotten covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like'%Guernsey%'
ORDER BY 1,2

--Looking at countries with Highest Infection rate compared to population
SELECT location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like'%states%'
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
--WHERE location like'%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
--WHERE location like'%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL
--WHERE location like'%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
--WHERE location like'%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int))
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like'%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM 
	(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Gives global stats
SELECT date, new_cases, CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE total_cases IS NOT NULL
  AND total_deaths IS NOT NULL
--GROUP BY date
ORDER BY 1,2

/*
SELECT CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)
FROM covid_project..deaths
WHERE total_cases IS NOT NULL
  AND total_deaths IS NOT NULL;
  */

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS decimal)) OVER (PARTITION BY  dea.location ORDER BY dea.Location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--using cte
with PopvsVsVac (continent, location, date, population, new_vaccinations, RollingCountPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS decimal)) OVER (PARTITION BY  dea.location ORDER BY dea.Location, dea.date) as RollingCountPeopleVaccinated
	--(RollingCountPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingCountPeopleVaccinated/population)*100
FROM PopvsVsVac

--using temp table instead

DROP TABLE IF exists #PercentPopulationVaccinated --create the table again each time executed
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingCountPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS decimal)) OVER (PARTITION BY  dea.location ORDER BY dea.Location, dea.date) as RollingCountPeopleVaccinated
	--(RollingCountPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingCountPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS decimal)) OVER (PARTITION BY  dea.location ORDER BY dea.Location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

