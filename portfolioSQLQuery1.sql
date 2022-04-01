select *
From [Portfolio Project]..[Covid_deaths]

Select Location, date, total_cases, new_cases, total_deaths, population
from  [Portfolio Project]..[Covid_deaths]

Alter Table [dbo].[Covid_deaths]
Alter Column new_cases float
GO

Alter Table [dbo].[Covid_deaths]
Alter Column total_deaths float
GO

Alter Table [dbo].[Covid_deaths]
Alter Column total_cases float
GO

Alter Table [dbo].[Covid_deaths]
Alter Column new_deaths float
GO


--Total Cases vs Total Deaths
--Likelihood of dying if someone gets corona in india
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_per 
from  [Portfolio Project]..[Covid_deaths] 
Where [Location] like '%India%'


--Total Cases vs Population
Select Location, date, total_cases, Population, (total_cases/Population)*100 as Population_per 
from  [Portfolio Project]..[Covid_deaths] 
Where [Location] like '%India%'

--Countries with highest Infection rate
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/Population))*100 as PercentpopulationInfected 
from  [Portfolio Project]..[Covid_deaths] 
--Where [Location] like '%India%'
Group by Location, Population
order by PercentpopulationInfected desc

--Countries with Death rate
Select Location, MAX(total_deaths) as TotalDeathCount
from  [Portfolio Project]..[Covid_deaths] 
--Where [Location] like '%India%'
Where Continent is not null
Group by Location
order by TotalDeathCount desc


--By Continent
Select continent, MAX(total_deaths) as TotalDeathCount
from  [Portfolio Project]..[Covid_deaths] 
--Where [Location] like '%India%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from  [Portfolio Project]..[Covid_deaths] 
--Where [Location] like '%India%'
where continent is not null
Group by date
order by 1,2
 

 Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from  [Portfolio Project]..[Covid_deaths] 
--Where [Location] like '%India%'
where continent is not null
order by 1,2
 

--Total population vs vaccination

With PopsvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..[Covid_deaths] dea
Join [Portfolio Project]..[Covid_vaccination] vac
    on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopsvsVac


--TEMP TABLE

DROP Table if exists
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
);
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..[Covid_deaths] dea
Join [Portfolio Project]..[Covid_vaccination] vac
    on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

Create View PopsvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated) as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..[Covid_deaths] dea
Join [Portfolio Project]..[Covid_vaccination] vac
    on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3





Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid_deaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid_deaths]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income' )
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid_deaths]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..[Covid_deaths]
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc