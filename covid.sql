use portfolioproject;
# Default format for date in MYSQL is YYYY-MM-DD so if the data is not in this format before converting you need to update it first
#update the table, identify what the current format of the date is
UPDATE coviddeaths
SET coviddeaths.date=str_to_date(coviddeaths.date, "%m-%d-%Y");

#Changing Date column title in table
ALTER TABLE coviddeaths change date obsdate date;


#Creating a View so that I don't accidentally alter the raw data table

Create VIEW covid as SELECT record, location, obsdate, population, total_cases, new_cases, new_deaths, reproduction_rate, icu_patients, hosp_patients, 
weekly_icu_admissions, weekly_hosp_admissions
FROM coviddeaths;

#Check the view
SELECT *
FROM covid;

#Update view to include total_deaths since it was forgotten when the view was originally created
ALTER VIEW covid as
SELECT record, location, obsdate, population, total_cases, new_cases, total_deaths, new_deaths, reproduction_rate, icu_patients, hosp_patients, 
weekly_icu_admissions, weekly_hosp_admissions
FROM coviddeaths;

#Order the view by date
SELECT *
FROM covid
ORDER BY 3;


#Looking at Total Cases vs Total Deaths in the US
#Reformat the result as a number and change the variable titles
SELECT format(sum(total_cases), "NO") as 'Covid Cases', format(sum(total_deaths), "NO") as 'Total Deaths', 
sum(total_deaths)/sum(total_cases)*100 as 'Death Rate'
FROM covid
WHERE location= "United States";

#Looking at Death Rate
#Shows the likelihood of dying if you contract COVID in your country
SELECT location, obsdate, total_cases, total_deaths, (total_deaths/total_cases)*100 as "coviddeathrate"
FROM covid
WHERE location = "United States"
order by 1,2;

#Looking at total cases vs the population
SELECT location, obsdate, population, total_cases, (total_cases/population)*100 as "infectionrate"
FROM covid
WHERE location = "United States"
order by 1,2;

#Which countries (of the data available) have the highest infection rate compared to population
#note: I truncated the file so that not every country is represented in the data
SELECT location, population, format(MAX(total_cases), "NO") as 'HighestInfectionCount',  MAX((total_cases/population))*100 as "PopInfectionRate"
FROM covid
GROUP BY Location, Population
ORDER BY 4 DESC;

#List the countries (of the data available) with the highest death count per population
SELECT location, format((population), "NO") AS 'Population', format(MAX(total_deaths), "NO") as 'TotalDeathCount'
FROM covid
GROUP BY Location, Population
ORDER BY 3 DESC;

#The query above revealed that the totaldeath variable is not formatted as the appropriate data type, so that needs to be updated
#by casting as an integer data type (unsigned--non-negative integer)
SELECT location, max(cast(total_deaths as unsigned)) as TotalDeathCount
FROM covid
GROUP BY location
ORDER BY 2 DESC;