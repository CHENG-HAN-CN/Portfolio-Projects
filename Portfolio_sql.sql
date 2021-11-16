SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Death Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Infection Percentage
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDealthCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDealthCount DESC

SELECT Continent, MAX(CAST(total_deaths AS int)) AS TotalDealthCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Continent
ORDER BY TotalDealthCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS bigint)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.DATE = VAC.DATE
WHERE DEA.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)/100
FROM PopvsVac

-- Creating View
CREATE VIEW PercentagePopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS bigint)) OVER (PARTITION BY DEA.Location ORDER BY DEA.Location, DEA.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.DATE = VAC.DATE
WHERE DEA.continent is not null

SELECT *
FROM PercentagePopulationVaccinated