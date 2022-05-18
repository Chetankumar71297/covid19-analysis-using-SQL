/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select * from PortfolioProject..CovidDeaths order by 3,4





--select * from PortfolioProject..CovidDeaths order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population 
From PortfolioProject..CovidDeaths 
Order by location,date

-- Countries with maximum new case reported on a single day

select location,max(new_cases) as max_single_day_new_cases 
From PortfolioProject..CovidDeaths
where not continent='Null'
group by location
Order by max_single_day_new_cases desc


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying,if geting contracted with covid in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths where location like '%India%'
Order by location,date


-- Looking at Total casses vs Population
-- Shows what percentage of population got covid
Select location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths 
-- where location='India'
Order by location,date

-- Present infection rate of all countries in decreasing order
Select location,population,MAX(total_cases) as highestinfection,MAX((total_cases/population))*100 as Percentpopulationinfected
From PortfolioProject..CovidDeaths 
Group by location,population 
Order by Percentpopulationinfected DESC

-- Mortality rate w.r.t population of countries in decreasing order
select location,population,max(cast(total_deaths as int)) as current_total_deaths,max((cast(total_deaths as int))/population)*100 as moratality_rate
from PortfolioProject..CovidDeaths
group by location,population
-- having location='India'
order by moratality_rate desc

-- Current deaths in countries in decreasing order with corresponding Mortality rate w.r.t population
select location,population,max(cast(total_deaths as int)) as overall_total_deaths,max((cast(total_deaths as int))/population)*100 as moratality_rate
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
-- having location='India'
order by overall_total_deaths desc

-- Current overall Mortality rate w.r.t total_cases of countries in decreasing order
select location,max(total_cases) as overall_total_cases,max(cast(total_deaths as int)) as overall_total_deaths,(max(total_deaths)/max(total_cases))*100 as moratality_rate
from PortfolioProject..CovidDeaths
where continent is not null
group by location
-- having location='India'--(also check for Faeroe Islands which have Highest percentage of poulation Infected )
order by moratality_rate desc

-- Countries with Highest percentage of poulation Infected 
select location,population,max(total_cases) as overall_total_cases,(max(total_cases)/population)*100 as population_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by population_infected desc

-- Hospitalization/ICU data is available for only 47 countries


-- NOW WE WILL EXPLORE LOADS ON HOSPITAL INFRASTRUCTURE OF DIFFERENT COUNTRIES
-- Countries with highest number of hospitalized covid patients on a single day

select location,MAX(convert(int,hosp_patients)) as max_hosp_patients_on_single_day
--convert(int,weekly_icu_admissions) as weekly_icu_admissions
from PortfolioProject..CovidDeaths
where hosp_patients is not null 
group by location
order by max_hosp_patients_on_single_day desc

-- Countries with highest number of ICU patients on a single day

select location,max(convert(int,icu_patients)) as icu_patients
from PortfolioProject..CovidDeaths
where icu_patients is not null
group by location
order by icu_patients desc

-- Countries with highest number of newly admitted covid patients in hospitals in a given week per million population 

select location,max(weekly_hosp_admissions_per_million) as weekly_hosp_admissions_per_million
from PortfolioProject..CovidDeaths
where weekly_hosp_admissions_per_million is not null
group by location
order by weekly_hosp_admissions_per_million desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage_per_positive_cases
From PortfolioProject..CovidDeaths
where continent is not null 



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as total_people_vac_till_date,total_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where not dea.continent = 'null' and dea.location='India'
order by location,date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine and total_no_of_doses_administered.


select dea.location,population,max(convert(bigint,people_vaccinated)) as people_who_received_at_least_one_vaccine_dose
,(max(convert(bigint,people_vaccinated))/population)*100 as percent_population_recived_atleast_single_dose
,(max(convert(bigint,people_fully_vaccinated))/population)*100 as percent_population_fully_vaccinated
,max(convert(bigint,total_vaccinations)) total_vaccine_doses_administered
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where not dea.continent = 'null'
group by dea.location,population
order by total_vaccine_doses_administered desc

-- Percent population fully vaccinated in decreasing order of all countries

with popvsvac (location,population,people_who_received_at_least_one_vaccine_dose,percent_population_recived_atleast_single_dose
				,percent_population_fully_vaccinated,total_vaccine_doses_administered) as 
(
select dea.location,population,max(convert(bigint,people_vaccinated)) as people_who_received_at_least_one_vaccine_dose
,(max(convert(bigint,people_vaccinated))/population)*100 as percent_population_recived_atleast_single_dose
,(max(convert(bigint,people_fully_vaccinated))/population)*100 as percent_population_fully_vaccinated
,max(convert(bigint,total_vaccinations)) total_vaccine_doses_administered
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where not dea.continent = 'null'
group by dea.location,population
)

select location,population,percent_population_fully_vaccinated
from popvsvac
order by percent_population_fully_vaccinated desc