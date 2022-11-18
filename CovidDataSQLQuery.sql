
--Total Cases vs Total Deaths (Global)

/* This query is for a table showing the global numbers for COVID cases, deaths, and death percentage */

Select total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentageByCase
from CovidPortfolioProject..CovidDeaths$
Where location = 'world' and total_cases in (select max(total_cases) from CovidPortfolioProject..CovidDeaths$ Where location = 'world')
order by 1,2


--Looking at Daily Infection Rate of All Countries
 
/* This query provides the data needed to plot the infection rate vs time for each country. 
This cart will be dependent on the map, showing the top 5 infected countries for the selected continent.*/

Select continent, location, population, date, total_cases, (total_cases/population)*100 as PercentPoplationInfectedDaily
from CovidPortfolioProject..CovidDeaths$
Where continent is not NULL
order by location, date


--Looking at Highest Infection Rate per Population for Countries

/* The following provide the data needed to make a drill down heat map of the world showing the %population infected from each continent,
then drills down to all of the countries in the selected continent. When a continent is selected, the infection vs. time chart will also update.*/ 

Select continent, location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by continent, location, population
Order by PercentPopulationInfectedByCountry desc

-- Create view for later visualization
Create View ViewPercentPopulationInfectedByCountry as
Select continent, location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by continent, location, population

--Looking at Highest Infection Rate per Population for Continent

Select location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedByContinent
from CovidPortfolioProject..CovidDeaths$
where continent is null and location in (Select continent from CovidPortfolioProject..CovidDeaths$)
Group by location, population
Order by PercentPopulationInfectedByContinent desc

-- Create view for later visualization
Create View PercentPopulationInfectedByContinent as
Select location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedByContinent
from CovidPortfolioProject..CovidDeaths$
where continent is null and location in (Select continent from CovidPortfolioProject..CovidDeaths$)
Group by location, population

-- Creates the final data source for the Tableau drill down map by joining the country and continent data
Select *
From ViewPercentPopulationInfectedByCountry
join PercentPopulationInfectedByContinent on ViewPercentPopulationInfectedByCountry.continent = PercentPopulationInfectedByContinent.location

--Highest Infection Rate per Population  (Globally)

Select location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedGlobal
from CovidPortfolioProject..CovidDeaths$
where location = 'World'
Group by location, population
Order by PercentPopulationInfectedGlobal



--TOTAL DEATHS

--Total Death Count per Country

Select location, max(cast(total_deaths as int)) as TotalDeathsByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population
Order by TotalDeathsByCountry desc

-- Create view for later visualization
Create View TotalDeathsByCountry as
Select location, max(cast(total_deaths as int)) as TotalDeathsByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population

-- Total Death Count per Continent

Select location, max(cast(total_deaths as int)) as TotalDeathsByContinent
from CovidPortfolioProject..CovidDeaths$
where continent is null and location in (Select continent from CovidPortfolioProject..CovidDeaths$)
Group by location
Order by TotalDeathsByContinent desc

-- Create view for later visualization
Create View TotalDeathsByContinent as
Select location, max(cast(total_deaths as int)) as TotalDeathsByContinent
from CovidPortfolioProject..CovidDeaths$
where continent is null and location in (Select continent from CovidPortfolioProject..CovidDeaths$)
Group by location

--Total Death Count Globally

Select max(cast(total_deaths as int)) as TotalDeathsWorld
from CovidPortfolioProject..CovidDeaths$
where location = 'World'



--DEATH RATE as % of Population

--Death Rate per Country

Select location, population, max(cast(total_deaths as int)) as PeakDeathRate, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDeathsByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population
Order by PercentPopulationDeathsByCountry desc

-- Create view for later visualization
Create View PercentPopulationDeathsByCountry as
Select location, population, max(cast(total_deaths as int)) as PeakDeathRate, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDeathsByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population




--Death Rate per Continent

Select location, population, max(cast(total_deaths as int)) as PeakDeathRate, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDeathsByContinent
from CovidPortfolioProject..CovidDeaths$
where continent is null and location in (Select continent from CovidPortfolioProject..CovidDeaths$)
Group by location, population
Order by PercentPopulationDeathsByContinent desc

-- Create view for later visualization
Create View PercentPopulationDeathsByContinent as
Select location, population, max(cast(total_deaths as int)) as PeakDeathRate, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDeathsByContinent
from CovidPortfolioProject..CovidDeaths$
where continent is null and location in (Select continent from CovidPortfolioProject..CovidDeaths$)
Group by location, population

--Death Rate of Globally

Select location, population, max(cast(total_deaths as int)) as PeakDeathRate, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDeathsGlobal
from CovidPortfolioProject..CovidDeaths$
where location = 'World'
Group by location, population
Order by PercentPopulationDeathsGlobal desc



-- Examining the Count of New Vaccinations

-- Rolling Count of New Vaccinations by Country by partitioning the data for each country

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as numeric)) over (partition by d.location order by d.date) as RollingTotal
from CovidPortfolioProject..CovidDeaths$ d
join CovidPortfolioProject..CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null and v.new_vaccinations is not Null
order by 2,3

-- Create view for later visualization
Create View RollingCountVaccinations as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as numeric)) over (partition by d.location order by d.date) as RollingTotal
from CovidPortfolioProject..CovidDeaths$ d
join CovidPortfolioProject..CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null and v.new_vaccinations is not Null


-- Using CTE to get Rate of New Vaccinations by Country

With RateOfVax (continenet, location, date, population, new_vaccinations, RollingTotal) AS
(
Select d.continent, d.location, d.date, d.population, new_vaccinations, sum(cast(v.new_vaccinations as numeric)) over (partition by d.location order by d.date) as RollingTotal
from CovidPortfolioProject..CovidDeaths$ d
join CovidPortfolioProject..CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null and v.new_vaccinations is not Null

)
Select *, (RollingTotal/population)*100 as RateOfNewVaccinationsByCountry
from RateOfVax
order by 2,3;

-- Create view for later visualization
Create View RollingCountVaccinationRate as
With RateOfVax (continenet, location, date, population, new_vaccinations, RollingTotal) AS
(
Select d.continent, d.location, d.date, d.population, new_vaccinations, sum(cast(v.new_vaccinations as numeric)) over (partition by d.location order by d.date) as RollingTotal
from CovidPortfolioProject..CovidDeaths$ d
join CovidPortfolioProject..CovidVaccinations$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null and v.new_vaccinations is not Null

)
Select *, (RollingTotal/population)*100 as RateOfNewVaccinationsByCountry
from RateOfVax