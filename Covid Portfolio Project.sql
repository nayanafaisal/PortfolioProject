select *
from PortfolioProject..['Covid-death']
where continent is not null
order by 3,4

select the data

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..['Covid-death']
order by 1,2

--looking at Total cases vs Total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['Covid-death']
where location like '%states'
order by 1,2

--looking at Total cases vs Population
select location,date,total_cases,population,(total_cases/population)*100 as InfectionRate
from PortfolioProject..['Covid-death']
where location like '%states'
order by 1,2

--looking at Countries with High Infection Rate
select location,population,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as InfectionRate
from PortfolioProject..['Covid-death']
--where location like '%states'
group by location,population
order by InfectionRate desc

--looking at Countries with Highest Death count per Population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Covid-death']
--where location like '%states'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..['Covid-death']
--where location like '%states'
where continent is not null
--group by date
order by 1,2


--Looking at Total Popultaion vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(bigint,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVaccinations
from PortfolioProject..['Covid-death'] dea
join PortfolioProject..['Covid-vaccinations'] vacc
	on dea.location=vacc.location
	and dea.date=vacc.date
where dea.continent is not null
--and vacc.new_vaccinations is not null
order by 2,3

--USE CTE
with PopVsVacc (Continent,Location,Date,Population,New_Vaccinations,RollingCountVaccinationed)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(bigint,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVaccinations
from PortfolioProject..['Covid-death'] dea
join PortfolioProject..['Covid-vaccinations'] vacc
	on dea.location=vacc.location
	and dea.date=vacc.date
where dea.continent is not null
and vacc.new_vaccinations is not null
--order by 2,3
)
select *,(RollingCountVaccinationed/Population)*100 
from PopVsVacc


--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountVaccinationed numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(bigint,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVaccinations
from PortfolioProject..['Covid-death'] dea
join PortfolioProject..['Covid-vaccinations'] vacc
	on dea.location=vacc.location
	and dea.date=vacc.date
where dea.continent is not null
and vacc.new_vaccinations is not null
--order by 2,3
select *,(RollingCountVaccinationed/Population)*100 
from #PercentPopulationVaccinated


--Creating view for later visualizations
--drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccine as 
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(convert(bigint,vacc.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVaccinations
from PortfolioProject..['Covid-death'] dea
join PortfolioProject..['Covid-vaccinations'] vacc
	on dea.location=vacc.location
	and dea.date=vacc.date
where dea.continent is not null
--and vacc.new_vaccinations is not null
--order by 2,3

select * from PercentPopulationVaccinations