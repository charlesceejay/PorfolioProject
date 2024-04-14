select *
from Project..CovidDeaths$
order by 3, 4

select *
from Project..CovidVaccinations$
order by 1,2

select location, date, total_cases, new_cases, total_deaths, population
from Project..CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
from Project..CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
from Project..CovidDeaths$
where location like '%states%'
order by 1,2

select location, date, population, total_cases,  (total_cases/population)*100 as CasePercentage
from Project..CovidDeaths$
--where location like '%states%'
order by 1,2

--Highest infection rate compared to population
select location, population, MAX(total_cases) as HighestinfectionCount,  MAX((total_cases/population))*100 as CasePercentage
from Project..CovidDeaths$
Group by location, population
order by CasePercentage desc

--Higest death count per population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Breakdown by continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing continent with highest death count
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

--Gblobal Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Project..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Project..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

select *
from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

--total population vs vaccinatio
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--summing up total vaccinations by date using CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 
from popvsvac

--Temp Table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
) 
Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #percentpopulationvaccinated

--Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated

from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated





