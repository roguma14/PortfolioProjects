/*
Queries for Tableau Project with the same tables used for Covid_Study.sql
*/



-- 1. 
--Total cases vs total Deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Study..CovidDeaths
where continent is not null 
order by 1,2



-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid_Study..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income'
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Study..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Study..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc