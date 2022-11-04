
Covid 19 Data

SELECT*
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


-- Select data that we will be starting with

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Cases vs Total Deaths in a United States

SELECT Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as Total_USA_Death_Percentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states'
AND continent is not null
ORDER BY 1,2


-- Total cases vs population
-- Percentage of population infected with Covid

SELECT Location, Date, Total_Cases, Population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
ORDER BY 1,2 


-- Countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Country_Population_Infected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY Country_Population_Infected DESC


-- Countries with highest death count per population

SELECT location, MAX(CAST(Total_deaths as INT)) as TotalCountryDeathCount
FROM PortfolioProject1..CovidDeaths
-- WHERE location like '%states'
Where continent is not null 
GROUP BY location
ORDER BY TotalCountryDeathCount DESC


-- Continents with the highest death count per population.

SELECT location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT SUM(New_cases) as Total_Cases, SUM(CAST(new_deaths as INT)) as Total_Deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Total population vs Rolling Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated	
-- , (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3




-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated	
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




-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BigINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated	
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
ORDER BY 2,3

CREATE VIEW Total_Continent_DeathCount AS
SELECT location, MAX(CAST(Total_deaths as INT)) as Total_Continent_DeathCount
FROM PortfolioProject1..CovidDeaths
-- WHERE location like '%states'
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
--ORDER BY Total_Continent_DeathCount DESC

CREATE VIEW Total_USA_Death_Percentage AS
SELECT Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as Total_USA_Death_Percentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states'
AND continent is not null
--ORDER BY 1,2

CREATE VIEW Country_Population_Infected AS
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Country_Population_Infected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY Location, Population
--ORDER BY Country_Population_Infected DESC




