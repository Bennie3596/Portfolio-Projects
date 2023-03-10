USE [Portfolio Project]
GO


SELECT * FROM [dbo].['Covid Vaccine Deaths$']
ORDER BY [continent]


 Select the data we are working with

  SELECT [Location], [date], [total_cases], [new_cases], [total_deaths], [population]
  
  FROM [Portfolio Project].[dbo].[Covid Vaccine Deaths]
  ORDER BY 1,2

--Calculating death percentage per country

  SELECT [Location], [date], [total_cases], [total_deaths], ([total_deaths]/[total_cases])*100 as DeathPercentage
  
  FROM [dbo].['Covid Vaccine Deaths$']

  WHERE [Location] LIKE 'South Africa'

  ORDER BY 1,2


-- Look at total cases vs population

    SELECT [Location], [date], [total_cases], [population], ([total_cases]/[population])*100 as CovidPercentage
  
  FROM [dbo].['Covid Vaccine Deaths$']

  WHERE [Location] LIKE 'South Africa'

  ORDER BY CovidPercentage desc


--Looking at countries with highest infection rate compared to population

  SELECT [Location], [population], max([total_cases]) as MaxInfectionCount, max(([total_cases]/[population])*100) as MaxInfectionperPopulation
  
  FROM [dbo].['Covid Vaccine Deaths$']
  GROUP BY [Location], [population]
  Order by MaxInfectionperPopulation desc


-- Showing countries with highest death count per capita

  SELECT [Location], max(cast([total_deaths] as int)) as MaxDeathCount, max((cast([total_deaths] as int)/[population])*100) as MaxDeathbyPopulation
    FROM [dbo].['Covid Vaccine Deaths$']
  WHERE [continent] IS NOT NULL
  GROUP BY [Location]
  Order by MaxDeathbyPopulation desc

--  Showing continents with highest death count per capita
  
  SELECT [Location], max(cast([total_deaths] as int)) as MaxDeathCount, max((cast([total_deaths] as int)/[population])*100) as MaxDeathbyPopulation
  
  FROM [dbo].['Covid Vaccine Deaths$']
  WHERE [continent] IS NULL and [location] NOT LIKE 'International' AND [Location] NOT LIKE 'World' AND [Location] NOT LIKE '%income%'
  GROUP BY [Location]
 
  Order by MaxDeathbyPopulation desc

--  Global statistics per day

	SELECT [date], 
	sum(cast([new_cases] as bigint))							as Newcases,
	sum(cast([new_deaths] as bigint))							as NewDeaths,
	max(cast([total_cases] as bigint))						as TotalCases, 
	max(cast([total_deaths] as bigint))						as TotalDeaths, 
	max([total_deaths]/[total_cases])*100						as DeathPercentage,
	max([new_deaths]/[new_cases])*100							as NewDeathPercentage

	FROM [dbo].['Covid Vaccine Deaths$']

	WHERE [location] LIKE 'World' AND [new_cases] != 0
	Group by [date]
	ORDER BY 1,4

--  Total Global statistics

  SELECT
  sum(cast([new_cases] as bigint))							as Newcases,
  sum(cast([new_deaths] as bigint))							as NewDeaths,
  max(cast([total_cases] as bigint))						as TotalCases, 
  max(cast([total_deaths] as bigint))						as TotalDeaths, 
  max([total_deaths]/[total_cases])*100						as DeathPercentage,
  max([new_deaths]/[new_cases])*100							as NewDeathPercentage

  FROM [dbo].['Covid Vaccine Deaths$']

  WHERE [location] LIKE 'World' AND [new_cases] != 0
  ORDER BY 1,4

-- Looking at total population vs vaccinations
-- USE CTE

	--SELECT * FROM [dbo].['Covid Vaccine Deaths$']
	--SELECT * FROM [dbo].['Covid Vaccine Vaccination$']

--	WITH PopvsVacc (
--	continent, 
--	location, 
--	date, 
--	population, 
--	new_vaccinations, 
--	Cum_Vacc)
--	AS
--	(
--	SELECT 
--		death.continent, 
--		death.location, 
--		death.date,
--		death.population,
--		vacc.new_vaccinations,
--		sum(cast(cast(vacc.new_vaccinations as float) as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as Cum_Vacc
--		FROM [dbo].['Covid Vaccine Deaths$'] as death
--		JOIN [dbo].['Covid Vaccine Vaccination$'] as vacc
--			ON death.location = vacc.location
--			AND death.date = vacc.date
--		WHERE death.continent IS NOT NULL AND death.location = 'South Africa'
----		ORDER BY 2, 3 

--		)
--	SELECT *, (Cum_Vacc/population)*100 as Cum_Vacc_Perc
--	FROM PopvsVacc

-- TEMP TABLE

	DROP TABLE IF EXISTS #PercentPopulationVaccinated

	CREATE TABLE #PercentPopulationVaccinated
		(
		Continent				varchar (255),
		location				varchar (255), 
		date					datetime,
		population				numeric, 
		New_vaccinations		numeric,
		Cumulative_vaccination	numeric
		)

	INSERT INTO #PercentPopulationVaccinated

		SELECT 
			death.continent, 
			death.location, 
			death.date,
			death.population,
			(cast(cast(vacc.new_vaccinations as float) as int)),
			sum(cast(cast(vacc.new_vaccinations as float) as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as Cum_Vacc
			FROM [dbo].['Covid Vaccine Deaths$'] as death
				JOIN [dbo].['Covid Vaccine Vaccination$'] as vacc
					ON death.location = vacc.location
						AND death.date = vacc.date
			WHERE death.continent IS NOT NULL AND death.location = 'South Africa'

		SELECT *, (Cumulative_vaccination/population)*100 as Cum_Vacc_Perc
		FROM #PercentPopulationVaccinated


-- Create View to store data for later visualisation


CREATE VIEW PercentPopulationVaccinated as

		SELECT 
			death.continent, 
			death.location, 
			death.date,
			death.population,
			vacc.new_vaccinations,
			sum(cast(cast(vacc.new_vaccinations as float) as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as Cum_Vacc
			FROM [dbo].['Covid Vaccine Deaths$'] as death
				JOIN [dbo].['Covid Vaccine Vaccination$'] as vacc
					ON death.location = vacc.location
						AND death.date = vacc.date
			WHERE death.continent IS NOT NULL AND death.location = 'South Africa'

