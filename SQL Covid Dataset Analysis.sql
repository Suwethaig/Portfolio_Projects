SELECT *
FROM SQLPortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM SQLPortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Selecting the required columns for the analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total cases vs Total deaths
-- Likelihood of dying if we contract covid in Canada
SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths AS float)/CAST (total_cases AS float)) * 100 AS death_percentage
FROM SQLPortfolioProject..CovidDeaths
WHERE location LIKE '%canada%'
ORDER BY 1, 2 

-- Total cases vs Population
SELECT location, date, total_cases, population,
(CAST(total_cases AS float)/CAST (population AS float)) * 100 AS infection_percentage
FROM SQLPortfolioProject..CovidDeaths
WHERE location LIKE '%canada%'
ORDER BY 1, 2

-- Countries with high infection rate in comparison to the population
SELECT location, population, MAX(total_cases) as max_infection_count,
MAX(CAST(total_cases AS float)/CAST (population AS float)) * 100 AS infection_percentage
FROM SQLPortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with Highest death count on a day
SELECT location, MAX(CAST (total_deaths AS float)) AS max_death_count
FROM SQLPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Continents with Highest death count on a day
SELECT continent, MAX(CAST (total_deaths AS float)) AS max_death_count
FROM SQLPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- Global numbers
SELECT date, SUM(CAST(new_cases AS float)) AS total_cases,
SUM(CAST(new_deaths AS float)) AS total_deaths
FROM SQLPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Joining the Covid deaths table and Covid vaccinations table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3

-- Total population vs Total vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS rolling_vaccinations_number
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE '%Canada%'
ORDER BY 2,3


-- Using a CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations_number)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS rolling_vaccinations_number
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE '%Canada%'
--ORDER BY 2,3
)
SELECT *, (rolling_vaccinations_number/population) * 100 AS vaccination_percent
FROM pop_vs_vac
ORDER BY 3

-- Using a Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations_number numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS rolling_vaccinations_number
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location LIKE '%Canada%'
--ORDER BY 2,3
SELECT *, (rolling_vaccinations_number/population) * 100 AS vaccination_percent
FROM #PercentPopulationVaccinated
ORDER BY 1, 2, 3

-- Creating a view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS rolling_vaccinations_number
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated