### Project Report: COVID-19 Vaccination and Death Analysis using SQL

#### Objective
The primary goal of this project is to analyze COVID-19 vaccination and death data to understand the distribution and impact of the pandemic across different countries and continents. This involves using SQL queries to extract, transform, and analyze data from the `CovidDeaths` and `CovidVaccinations` tables in the `portfolioproject` database.

#### Data Description
The analysis utilizes two main tables:
1. **CovidDeaths**: Contains data on COVID-19 cases and deaths by location and date.
2. **CovidVaccinations**: Contains data on COVID-19 vaccinations by location and date.

Key fields used in the analysis include:
- **CovidDeaths**: `location`, `date`, `total_cases`, `new_cases`, `total_deaths`, `population`, `continent`.
- **CovidVaccinations**: `location`, `date`, `new_vaccinations`.

#### Methodology and SQL Queries

1. **Initial Data Inspection**
   ```sql
   SELECT *
   FROM portfolioproject..CovidDeaths
   ORDER BY 3, 4;
   ```

2. **Data Selection for Analysis**
   ```sql
   SELECT location, date, total_cases, new_cases, total_deaths, population
   FROM portfolioproject..CovidDeaths
   ORDER BY 1, 2;
   ```

3. **Total Cases vs Total Deaths in Nigeria**
   ```sql
   SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
   FROM portfolioproject..CovidDeaths
   WHERE location LIKE '%Nigeria%'
   ORDER BY 1, 2;
   ```

4. **Total Cases vs Population (Percentage of People Infected) in Nigeria**
   ```sql
   SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
   FROM portfolioproject..CovidDeaths
   WHERE location LIKE '%Nigeria%'
   ORDER BY 1, 2;
   ```

5. **Countries with Highest Infection Rates Compared to Population**
   ```sql
   SELECT location, MAX(total_cases) AS Max_total_cases, population, MAX(total_cases/population)*100 AS InfectedpopulationPercentage
   FROM portfolioproject..CovidDeaths
   GROUP BY location, population
   ORDER BY InfectedpopulationPercentage DESC;
   ```

6. **Countries with Highest Death Count**
   ```sql
   SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
   FROM portfolioproject..CovidDeaths
   GROUP BY location
   ORDER BY TotalDeathCount DESC;
   ```

7. **Total Deaths by Continent**
   ```sql
   SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
   FROM portfolioproject..CovidDeaths
   WHERE continent IS NOT NULL
   GROUP BY continent
   ORDER BY TotalDeathCount DESC;
   ```

8. **Global Numbers (Total Cases and Deaths Over Time)**
   ```sql
   SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Deathpercentage
   FROM portfolioproject..CovidDeaths
   WHERE continent IS NOT NULL
   GROUP BY date
   ORDER BY 1, 2;
   ```

9. **Vaccinations vs Population**
   ```sql
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   FROM portfolioproject..CovidDeaths AS DEA
   JOIN portfolioproject..CovidVaccinations AS VAC
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
   ORDER BY 2, 3;
   ```

10. **Total Vaccinations per Location**
    ```sql
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccination
    FROM portfolioproject..CovidDeaths AS DEA
    JOIN portfolioproject..CovidVaccinations AS VAC
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2, 3;
    ```

11. **Vaccination Percentage Using CTE**
    ```sql
    WITH popvsvac (continent, location, date, population, new_vaccinations, Total_vaccination) AS (
        SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccination
        FROM portfolioproject..CovidDeaths AS DEA
        JOIN portfolioproject..CovidVaccinations AS VAC
        ON dea.location = vac.location
        AND dea.date = vac.date
        WHERE dea.continent IS NOT NULL
    )
    SELECT *, (Total_vaccination/population)*100 AS Percentage_vaccinated
    FROM popvsvac;
    ```

12. **Temporary Table for Vaccination Percentage**
    ```sql
    DROP TABLE IF EXISTS #percentage_vaccinated;
    CREATE TABLE #percentage_vaccinated (
        continent NVARCHAR(255),
        location NVARCHAR(255),
        date DATETIME,
        population NUMERIC,
        new_vaccinations NUMERIC,
        Total_vaccination NUMERIC
    );

    INSERT INTO #percentage_vaccinated
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccination
    FROM portfolioproject..CovidDeaths AS DEA
    JOIN portfolioproject..CovidVaccinations AS VAC
    ON dea.location = vac.location
    AND dea.date = vac.date;

    SELECT *, (Total_vaccination/population)*100 AS Percentage_Vaccinated
    FROM #percentage_vaccinated;
    ```

13. **View for Displaying Vaccination Percentage**
    ```sql
    CREATE VIEW Percentage_vaccinated AS
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_vaccination
    FROM portfolioproject..CovidDeaths AS DEA
    JOIN portfolioproject..CovidVaccinations AS VAC
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL;
    ```

#### Key Findings
- **Death Rate in Nigeria**: The percentage of deaths compared to total cases in Nigeria.
- **Infection Rates**: Identified countries with the highest infection rates relative to their populations.
- **Death Counts**: Highlighted countries and continents with the highest total death counts.
- **Global Trends**: Analyzed global trends in new cases and deaths over time.
- **Vaccination Analysis**: Compared vaccination rates to population sizes, highlighting vaccination progress in different regions.

#### Conclusion
This project successfully uses SQL to analyze COVID-19 data, revealing critical insights into the pandemic's spread, mortality rates, and vaccination efforts. The findings underscore the importance of continued vaccination efforts and provide valuable information for public health strategies. Future work could involve more detailed demographic analyses and predictive modeling to further understand and combat the pandemic.
