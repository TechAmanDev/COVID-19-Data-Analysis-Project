SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM noted-app-424311-g8.covid.CovidDeaths
ORDER BY 1,2;

-- Total Cases VS Total Deaths
SELECT Location, date, total_cases, (total_deaths/total_cases)*100 AS DeathPercentage, population 
FROM noted-app-424311-g8.covid.CovidDeaths
WHERE LOWER(Location) LIKE '%india%'
ORDER BY 1,2;

-- Total Cases VS Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM noted-app-424311-g8.covid.CovidDeaths
ORDER BY 1,2;

-- Highest Infection Rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM noted-app-424311-g8.covid.CovidDeaths
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC;

-- Highest Death Rate compared to population
SELECT Location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentagePopulationDeaths
FROM noted-app-424311-g8.covid.CovidDeaths
GROUP BY Location, population
ORDER BY HighestDeathCount DESC;

-- Highest Death Rate compared to population in Continent
SELECT continent, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentagePopulationDeaths
FROM noted-app-424311-g8.covid.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- JOIN TABLES FOR TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, cov.new_vaccinations, SUM(cov.new_vaccinations) OVER(PARTITION BY dea.Location ORDER BY dea.Location,dea.date) FROM noted-app-424311-g8.covid.CovidDeaths AS dea
JOIN noted-app-424311-g8.covid.CovidVaccinations AS cov
ON dea.Location = cov.Location
AND dea.date = dea.date;

DROP Table if exists #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
continent narchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

SELECT dea.continent, dea.location, dea.date, dea.population, cov.new_vaccinations, SUM(cov.new_vaccinations) OVER(PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS RollingPeopleVaccinated
FROM noted-app-424311-g8.covid.CovidDeaths AS dea
JOIN noted-app-424311-g8.covid.CovidVaccinations AS cov
ON dea.Location = cov.Location
AND dea.date = dea.date;

Select *,(RollingPeopleVaccinated/Population)*100
From
#PercentPopulationVaccinated

-- VIEW FOR VISUALISATION
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, cov.new_vaccinations, SUM(cov.new_vaccinations) OVER(PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS RollingPeopleVaccinated
FROM noted-app-424311-g8.covid.CovidDeaths AS dea
JOIN noted-app-424311-g8.covid.CovidVaccinations AS cov
ON dea.Location = cov.Location
AND dea.date = dea.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated;
