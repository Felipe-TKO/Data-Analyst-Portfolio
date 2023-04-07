-- Select Data that will be used

Select Location, date, total_cases, New_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Query for Total Cases vs Total Deaths and likelyhood of dying 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Total cases vs population
Select Location, date, total_cases, population , (total_cases/population)*100 as Percentageofpopulationcovid
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighesInfectionCount, Max((total_cases/population))*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentOfPopulationInfected desc

-- Countried with Highest Death Count per population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- BY Continent with highest death count
Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/ sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/ sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Total Population vs Covid Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- New query
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric, 
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Create view to store data for later

Create View PercentpopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(int, vac.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Create View NewView as
Select *
From PortfolioProject..CovidDeaths
