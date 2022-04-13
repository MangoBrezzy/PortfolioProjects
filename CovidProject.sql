
Select * 
from dbo.CovidVaccinations$ 
order by 3,4

--Select data we are going to be using 

Select Location,Date,total_cases, new_cases, total_deaths, population
from [dbo].[CoviDeaths$]
where continent is not null
order by 3,4

-- Looking at Total Cases Vs Total Deaths 
--Shows the Likelihood of dying if you contract covid in USA

Select Location,Date,total_cases ,total_deaths, (total_deaths/total_cases) * 100  as PercentageOfDeaths
from [dbo].[CoviDeaths$]
Where location like '%states%' and continent is not null
order by 1,2


--Looking at Total Cases vs Population
Select Location,Date,population, total_cases, (total_cases/population) * 100  as PercentageOfPopulationGotCovid
from [dbo].[CoviDeaths$]
Where location like '%states%' and total_cases is not null and continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population 
Select Location,population,Max(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100  as PercentageOfPopulationInfected
from [dbo].[CoviDeaths$]
where continent is not null
group by location,population
order by PercentageOfPopulationInfected desc


--Looking at Countries with highest death count per Populaton 
Select Location,Max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CoviDeaths$]
where continent is not null
group by location
order by TotalDeathCount desc



--Lets break the data down by continent
Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CoviDeaths$]
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths ,
Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as PercentageOfDeaths
from [dbo].[CoviDeaths$]
Where continent is not null
order by 1,2


--Looking at total population vs vaccination
select da.continent,da.location,da.date,da.population,dv.new_vaccinations
, sum(CONVERT(bigint,dv.new_vaccinations)) OVER (Partition by da.location order by da.location,da.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations$ dv
 join  dbo.Covideaths$ da
on dv.location = da.location
and dv.date = da.date
Where da.continent is not null
order by 2,3


--USE CTE 
WITH PopVsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select da.continent,da.location,da.date,da.population,dv.new_vaccinations
, sum(CONVERT(bigint,dv.new_vaccinations)) OVER (Partition by da.location order by da.location,da.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations$ dv
 join  dbo.Covideaths$ da
on dv.location = da.location
and dv.date = da.date
Where da.continent is not null
)

Select * , (RollingPeopleVaccinated/Population) * 100 
from PopVsVac



--TEMP TABLE
Drop Table if exists
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select da.continent,da.location,da.date,da.population,dv.new_vaccinations
, sum(CONVERT(bigint,dv.new_vaccinations)) OVER (Partition by da.location order by da.location,da.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations$ dv
 join  dbo.Covideaths$ da
on dv.location = da.location
and dv.date = da.date
Where da.continent is not null

Select * , (RollingPeopleVaccinated/Population) * 100 
from #PercentPopulationVaccinated


--View to store data for later visulizations

Create View PercentPopulationVaccinated as 
select da.continent,da.location,da.date,da.population,dv.new_vaccinations
, sum(CONVERT(bigint,dv.new_vaccinations)) OVER (Partition by da.location order by da.location,da.date) as RollingPeopleVaccinated
from dbo.CovidVaccinations$ dv
 join  dbo.Covideaths$ da
on dv.location = da.location
and dv.date = da.date
Where da.continent is not null

select * 
from PercentPopulationVaccinated