--select * from PortfolioProject.dbo.CovidDeaths

--select * from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths, population 
from PortfolioProject.dbo.CovidDeaths order by 1,2

--Calculating the death percentage in India
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths where location = 'India' order by 2

--Calculating the covid percentage in the total population of India
select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
from PortfolioProject.dbo.CovidDeaths where location = 'India' order by 2

--Calculating countries with highest Covid Rate
select location ,population ,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as
InfectedPercent from PortfolioProject.dbo.CovidDeaths group by location,population order by InfectedPercent desc

--Showing countries with highest death
--since some location as specified as continents where the continents field is null we include a condition to prevent the mistake
select location,max(cast(total_deaths as int)) as HighestDeatCount
from PortfolioProject.dbo.CovidDeaths where continent is not null group by location order by HighestDeatCount desc

--showing continents with highest death
select continent,max(cast(total_deaths as int)) as DeathCount
from PortfolioProject.dbo.CovidDeaths  where continent is not null group by continent order by DeathCount desc

--Global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent from PortfolioProject.dbo.CovidDeaths
where continent is not null order by 1,2


--Population vs Vaccinations
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) 
over (partition by d.location order by d.date,d.location) as VaccinationCount
from PortfolioProject.dbo.CovidDeaths as d join PortfolioProject.dbo.CovidVaccinations as v on d.location=v.location
and d.date=v.date where d.continent is not null
order by 2,3

--Creating Table
Drop Table if exists VaccinationPercent
create table VaccinationPercent 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationCount numeric
)
insert into VaccinationPercent
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) 
over (partition by d.location order by d.date,d.location) as VaccinationCount
from PortfolioProject.dbo.CovidDeaths as d join PortfolioProject.dbo.CovidVaccinations as v on d.location=v.location
and d.date=v.date where d.continent is not null

select *,(VaccinationCount/population)*100 as VaccinationCountPercent from VaccinationPercent 

--creating view
create view PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as int)) 
over (partition by d.location order by d.date,d.location) as VaccinationCount
from PortfolioProject.dbo.CovidDeaths as d join PortfolioProject.dbo.CovidVaccinations as v on d.location=v.location
and d.date=v.date where d.continent is not null

Select *,(VaccinationCount/population)*100 from PercentPopulationVaccinated 