SELECT *
FROM [Covid Project]..Covid_Deaths
order by 3,4;

--SELECT *
--FROM [Covid Project]..Covid_Vaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths
from [Covid Project]..Covid_Deaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood of dying on contracting Covid in the month of may in india
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Project]..Covid_Deaths
where location like 'India' and MONTH(date)=5
order by 1,2


--Looking at Total cases vs Population
SELECT location, date, population, total_deaths, (total_deaths/population)*100 as DeathPercentage
from [Covid Project]..Covid_Deaths
where location like 'India'
order by 1,2


--Looking at the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as Maximum_Cases, MAX((total_cases/population))*100 as Infection_Rate
from [Covid Project]..Covid_Deaths
group by location, population
order by 4 desc


--Showing countries with highest death count per population
SELECT location, population, MAX(cast(total_deaths as int)) as Maximum_deaths
from [Covid Project]..Covid_Deaths
where continent is not null
group by location, population 
order by 3 desc



--Showing continents with highest death count per population
SELECT continent, population, MAX(cast(total_deaths as int)) as Maximum_deaths, MAX(total_deaths/population) as DeathCountperPopulation
from [Covid Project]..Covid_Deaths
where continent is not null
group by continent,population
order by 4 desc


--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Covid Project]..Covid_Deaths
where continent is not null
group by date
order by 1 desc


--Looking at Total population vs Vaccinations

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Covid Project]..Covid_Vaccinations vac
JOIN [Covid Project]..Covid_Deaths dea
 ON dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null



 --CTE

With PopvsVac(continent, date, location, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.date, dea.location, vac.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM [Covid Project]..Covid_Vaccinations vac
JOIN [Covid Project]..Covid_Deaths dea
  ON dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null and dea.location like 'India'
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentOfRollingPeopleVaccinated
from PopvsVac
where RollingPeopleVaccinated is not null





--Creating View to store data for later vizualization

Create View View1 as
SELECT dea.continent, dea.date, dea.location, vac.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM [Covid Project]..Covid_Vaccinations vac
JOIN [Covid Project]..Covid_Deaths dea
  ON dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null



SELECT * 
from View1