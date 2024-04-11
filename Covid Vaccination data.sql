SELECT *
FROM portfolioproject..CovidDeaths
order by 3,4

--SELECT *
--FROM portfolioproject..CovidVaccinations
----order by 3,4

-- select data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--show percentage of deaths compared to cases in Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where location like '%Nigeria%'
order by 1,2

-- looking at total cases vs population(percentge of people in a country that had covid)

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From portfolioproject..CovidDeaths
Where location like '%Nigeria%'
order by 1,2

-- countries with highest infection rates compared to the population

SELECT location, Max(total_cases) as Max_total_cases, population, Max(total_cases/population)*100 as InfectedpopulationPercentage
From portfolioproject..CovidDeaths
Group by Location, Population
order by InfectedpopulationPercentage desc

-- showing countries with highest death count per population
SELECT location, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
--Where continent is not null
Group by location
order by TotalDeathCount desc

-- showingTotal deaths by continent
SELECT continent, Max(Cast(Total_Deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

SELECT date, Sum(new_cases) as Total_cases, sum(Cast(new_deaths as int)) as Total_deaths, sum(Cast(new_deaths as int))/Sum(new_cases)*100  as Deathpercentage
From portfolioproject..CovidDeaths
Where continent is not null
Group by date
order by 1,2



-- looking at total population vs Vacination
--select each column and specidy which table to select from as we are selecting from multiple tables

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

-- Join covid death and covidvaccination table
From portfolioproject..CovidDeaths as DEA
Join portfolioproject..CovidVaccinations as VAC

-- specify tables that are equal or carry the exact content
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- to check total vacination per location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as Total_vaccination
-- Join covid death and covidvaccination table
From portfolioproject..CovidDeaths as DEA
Join portfolioproject..CovidVaccinations as VAC

-- specify tables that are equal or carry the exact content
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--with CTE

with popvsvac (continent, location, date, population, new_vaccinations, Total_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as Total_vaccination
-- Join covid death and covidvaccination table
From portfolioproject..CovidDeaths as DEA
Join portfolioproject..CovidVaccinations as VAC

-- specify tables that are equal or carry the exact content
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (Total_vaccination/population)*100 as Percentage_vaccinated
From popvsvac




--TEMP Table

Drop Table if exists #percentage_vaccinated
Create Table #percentage_vaccinated

(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
Total_vaccination numeric

);

Insert into #percentage_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as Total_vaccination
-- Join covid death and covidvaccination table
From portfolioproject..CovidDeaths as DEA
Join portfolioproject..CovidVaccinations as VAC

-- specify tables that are equal or carry the exact content
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3


Select *, (Total_vaccination/population)*100 as Percentage_Vaccinated
From #percentage_vaccinated


-- Create view for dispay

Create View Percentage_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as Total_vaccination
-- Join covid death and covidvaccination table
From portfolioproject..CovidDeaths as DEA
Join portfolioproject..CovidVaccinations as VAC

-- specify tables that are equal or carry the exact content
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3