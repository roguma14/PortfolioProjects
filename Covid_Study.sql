/*

Study of Covid-19 Cases and Vaccionations throughout the pandemic until 05/28/2022

*/


-- Select Data that we are going to be starting with
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%mexico%'
and total_deaths is not null
and continent is not null
order by 1,2

-- Total Cases vs Population 
select location, date, total_cases, population, (total_cases/population)*100 as 'Population%'
from CovidDeaths
where location like '%mexico%'
and total_cases is not null
and continent is not null
order by 1,2

--Countries with highest infection rate vs Population
select location, max(total_cases) as InfectionHigh, population, max((total_cases/population))*100 as 'Population%'
from CovidDeaths
where continent is not null
group by location, population
order by [Population%] desc


--Countries with highest Death count
select location, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by location
order by DeathCount desc


--Death count by continent
select location as Continent, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is null
and location not like '%income'
group by location
order by DeathCount desc


--GLOBAL NUMBERS

--New cases vs new deaths per day
select date, sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_Deaths
from CovidDeaths
where continent is not null
group by date
order by 1

--Total Cases vs Deaths per day and Death %
select date, sum(total_cases) as Total_Cases, sum(cast(total_deaths as int)) as Deaths, sum(cast(total_deaths as int))/sum(total_cases)*100 as 'Death%'
from CovidDeaths
where continent is not null
group by date
order by 1


--New vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths as dea
	JOIN CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Total population vs total vaccinations over time, total_vaccinations column in table has NULLS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as 'Total_Vaccinations'
from CovidDeaths as dea
	JOIN CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--Using CTE to compare Total Vaccinations vs Population over time
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as 'Total_Vaccinations'
from CovidDeaths as dea
	JOIN CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, Total_Vaccinations/Population*100 as 'Vaccination%'
from PopvsVac
order by 1,2,3

--Temp table to compare Total Vaccinations vs Population over time
drop table if exists #TotalVacs
create table #TotalVacs (
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
Total_Vaccinations numeric
)

insert into #TotalVacs
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as 'Total_Vaccinations'
from CovidDeaths as dea
	JOIN CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, Total_Vaccinations/Population*100 as 'Vaccination%'
from #TotalVacs
order by 1,2,3


--Creating a View for later viz
create view Country_Deaths as
select location, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by location


