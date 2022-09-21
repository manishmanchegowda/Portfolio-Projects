
--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Total cases vs Total Deaths
-- Covid percent in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercent 
from PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2

--Total Cases vs Population in India
select location, date, total_cases, population, (total_cases/population)*100 as Covidpercent 
from PortfolioProject..CovidDeaths$
--where location like '%india%'
order by 1, 2;


-- Looking at contries with Highest infection rate compared to population
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as Covidpercent 
from PortfolioProject..CovidDeaths$
Group by Location, Population
order by Covidpercent Desc;

--Looking at the countries  with Highest Death count per population
select location, max(Cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by HighestDeathCount Desc;

--Lets take Continent

--Showing continents with the highest death count per population

select continent, max(Cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by HighestDeathCount Desc;


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercent 
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

-- All Together Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercent 
from PortfolioProject..CovidDeaths$
--where location like '%india%'
where continent is not null
order by 1,2


--Joining two  table

Select * 
From PortfolioProject..CovidVaccinations$ as vac 
join PortfolioProject..CovidDeaths$ as dea 
on dea.location = vac.location 
and dea.date = vac.date;

--Looking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations$ as vac 
join PortfolioProject..CovidDeaths$ as dea 
	on dea.location = vac.location  
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3;

-------Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations$ as vac 
join PortfolioProject..CovidDeaths$ as dea 
	on dea.location = vac.location  
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentOfPeopleVac
from PopvsVac


--------TEMP Table
 --Create a temp table adding the column names as above 
 -- add above query and display it using select



----------Creating view for data visualization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))  over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations$ as vac 
join PortfolioProject..CovidDeaths$ as dea 
	on dea.location = vac.location  
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated