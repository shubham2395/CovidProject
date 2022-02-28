---Covid Deaths Data Exploration 

Select *
from Projects.dbo.CovidDeaths
where continent is not null --To exclude the continent value which is available in location
order by 3,5


Select *
from Projects..CovidVaccinations
order by 3,4

-- Using this data for exploration
Select location,date,total_cases,new_cases,total_deaths,population
From Projects..CovidDeaths
order by 1,2

-- Observing Total cases and deaths
--Likelihood of getting infected in India
Select location,date,total_cases,total_deaths,round(total_deaths/total_cases,3)*100 as DeathPercentage
From Projects..CovidDeaths
order by 1,2

--Total cases over population
Select location,date,total_cases,total_deaths,Population,(total_cases/population)*100 as CasePercentage
From Projects..CovidDeaths
order by 1,2

-- Looking at countries with Highest Covid Rate
Select location,population,MAX(total_cases) as HighestCovidCount,(total_cases/population)*100 as CovidCasePercentage
From Projects..CovidDeaths
group by location,population,total_cases
order by 4 DESC

-- Looking at countries with Highest Death count per population
Select distinct location,population, MAX(Cast(total_deaths as Int)) as HighestDeathCount,round(total_deaths/population,5)*100 as DeathPercentage
From Projects..CovidDeaths
where continent is not null
group by location,population,total_deaths
order by 3 DESC

--- Looking at Continent with Highest Death count
Select continent,MAX(cast(total_deaths as int)) as HighestDeathCount
from Projects..CovidDeaths
where continent is not null
group by continent
order by 2 DESC

--- Looking at Continent with Highest Case count
Select continent,MAX(cast(total_cases as int)) as HighestCaseCount
from Projects..CovidDeaths
where continent is not null
group by continent
order by 2 DESC

--- Observing Data Globally on per day basis

Select Date, sum(new_cases) as totalNewCases,sum(cast(new_deaths as int)) as totalNewDeaths
From Projects..CovidDeaths
where continent is not null
group by Date
order by 1

--- Onserving Data on continent basis

Select continent,SUM(new_cases )as totalNewCases,sum(cast(new_deaths as int)) as totalNewDeaths
From Projects..CovidDeaths
where continent is not null
group by continent
order by 2 DESC

---- Observing Data on Location(Country) Basis

Select location,SUM(new_cases )as totalNewCases,sum(cast(new_deaths as int)) as totalNewDeaths
From Projects..CovidDeaths
where continent is not null
group by location
order by 2 DESC


----Covid Vaccination Data Exploration starts here

 Select *
 from Projects..CovidVaccinations

 ---- Rolling Vaccination count of all continents and countries(location)
 Select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVac
 from Projects..CovidDeaths dea Join Projects..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,4


 -- Observing Total Population vaccinated for each location/continent
 DROP TABLE IF EXISTS #PopulationVaccinated
 CREATE TABLE #PopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 population numeric,
 date datetime,
 new_vaccinations numeric,
 RollingCountVac numeric 
 )
INSERT INTO #PopulationVaccinated
 Select dea.continent,dea.location,dea.population,isnull(convert(datetime,dea.date),getdate()) date,vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVac
 from Projects..CovidDeaths dea Join Projects..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 select *, (RollingCountVac/population)*100 as PopulationVaccinated
 from #PopulationVaccinated
 

 ---Creating views..

 CREATE VIEW PopulationVaccinatedView AS
 Select dea.continent,dea.location,dea.population,isnull(convert(datetime,dea.date),getdate()) date,vac.new_vaccinations,
 SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingCountVac
 from Projects..CovidDeaths dea Join Projects..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null


