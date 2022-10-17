Select *
from CovidPortfolioProject..CovidDeaths$
where continent is null
order by 3,4

Select *
From CovidPortfolioProject..CovidVaccinations$
order by 3,4


--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentageByCase
from CovidPortfolioProject..CovidDeaths$
order by 1,2


--Looking at Highest Infection Rate per Population for Countries

Select location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population
Order by PercentPopulationInfectedByCountry desc

-- Create view for later visualization
Create View PercentPopulationInfectedByCountry as
Select location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedByCountry
from CovidPortfolioProject..CovidDeaths$
Where continent is not null
Group by location, population


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

--Looking at Highest Infection Rate per Population for Globe

Select location, population, max(total_cases) as PeakInfectionRate, (max(total_cases)/population)*100 as PercentPopulationInfectedGlobal
from CovidPortfolioProject..CovidDeaths$
where location = 'World'
Group by location, population
Order by PercentPopulationInfectedGlobal desc



--TOTAL DEATHS

--Looking at the Total Death Count per Country

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

--Looking at the Total Death Count per Continent

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

--Looking at the Total Death Count Total

Select max(cast(total_deaths as int)) as TotalDeathsWorld
from CovidPortfolioProject..CovidDeaths$
where location = 'World'



--DEATH RATE

--Looking at the Death Rate per Country

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




--Looking at the Death Rate per Continent

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

--Looking at the Death Rate of World

Select location, population, max(cast(total_deaths as int)) as PeakDeathRate, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDeathsGlobal
from CovidPortfolioProject..CovidDeaths$
where location = 'World'
Group by location, population
Order by PercentPopulationDeathsGlobal desc



-- Looking at the Count of New Vaccinations

-- Looking at Rolling Count of New Vaccinations by Country

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