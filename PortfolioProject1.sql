

SELECT*
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT*
FROM PortfolioProject1..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--Select data that we will be using.

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--looking at Total Cases vs Total Deaths
--Shows likelihood of dying if contracting Covid in a country.

SELECT Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states'
AND continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got Covid

SELECT Location, Date, Total_Cases, Population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
ORDER BY 1,2 

--Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC

--Showing countries with highest death count per population.

SELECT Location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing continent with highest death count per population.

SELECT location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global numbers by date

SELECT Date, SUM(New_cases) as Total_Cases, SUM(CAST(new_deaths as INT)) as Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Global numbers 

SELECT SUM(New_cases) as Total_Cases, SUM(CAST(new_deaths as INT)) as Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as Rolling_People_Vaccinated	
, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as Rolling_People_Vaccinated	
--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac 

--Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric,
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as Rolling_People_Vaccinated	
--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated 

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
  dea.date) as Rolling_People_Vaccinated	
--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

CREATE VIEW TotalDeathCount AS
SELECT location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is null
GROUP BY location
--ORDER BY TotalDeathCount DESC

CREATE VIEW Death_Percentage AS
SELECT Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states'
AND continent is not null
--ORDER BY 1,2

CREATE VIEW PercentagePopulationInfected AS
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY Location, Population
--ORDER BY PercentagePopulationInfected DESC