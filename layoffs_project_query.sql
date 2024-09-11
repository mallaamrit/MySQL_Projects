-- Data Cleaning Using MySQL

-- 1. Remove Duplicates
-- 2. Standarize the data(e.g:spelling)
-- 3. Null values or blank values
-- 4. Remove any columns (non relevant)

-- staging ( creating copy of original table data)
CREATE TABLE layoff_staging LIKE layoffs;

-- Inserting layoffs data to the new table
Insert into layoff_staging select * from layoffs;

-- --partiton data by every column-- when row_num >1 that means duplicates
select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country,funds_raised_millions) as row_num from layoff_staging;

-- using CTE to check duplicates
with duplicate_cte as
( select *, 
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`, stage, country,funds_raised_millions) as row_num from layoff_staging)
select * from duplicate_cte where row_num > 1;

-- deleting duplicate so first make new table so that we can put the duplicates value
CREATE TABLE `layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT default null,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int default null,
`row_num` INT
);

-- --showing the newly created table layoffs_staging2
SELECT 
    *
FROM
    layoffs_staging2;


-- Inserting data from layoff_stagging to layoff_staging2 
Insert into layoffs_staging2
select *, 
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`,stage, country,funds_raised_millions) as row_num from layoff_staging;

-- extracting the duplicates from new table
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    row_num > 1;

-- deleting the duplicates
DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;

-- standardizing data ( removing spaces)
SELECT DISTINCT
    (company)
FROM
    layoffs_staging2;

-- displaying company col with trim and  without it
SELECT 
    company, TRIM(company)
FROM
    layoffs_staging2;

-- updating company col with trim (removing indentation, spaces)
UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

-- displaying insutry col
Select distinct industry from layoffs_staging2 order by 1;

-- displaying duplicate names
SELECT DISTINCT
    industry
FROM
    layoffs_staging2
WHERE
    industry LIKE 'Crypto%';

-- updating duplicates with crypto 
Update layoffs_staging2 set industry = 'Crypto'
where industry like 'Crypto%';  

-- displaying country col since it has issue with unisted states duplicates and . at the end
select distinct country from layoffs_staging2 order by 1;

-- updating united states and removing . and duplicate 
Update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

-- converting date col since it is a text col values so to change into date format values for that use backslash between them put date label since it is a reserved tag name in sql
SELECT 
    `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM
    layoffs_staging2;

-- updating the date format in date col
Update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- altering the col date into date type instead text
Alter table layoffs_staging2
modify column `date` date;

-- displayin the null value cols 
Select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

-- updating blank col with null value 
Update layoffs_staging2 set industry = Null where industry ='';


-- displaying the missing value col or blank one
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = '';


-- displaying particular row 
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company = 'Airbnb';
    

-- displaying missing values in t1 using self join
SELECT 
    t1.industry, t2.industry
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;
        

-- updating data in t1 using self join and conditions 
UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;
	
-- displaying the populated values 
SELECT 
    *
FROM
    layoffs_staging2;

-- deleting null value fields from cols 
DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- displaying the final changes 
SELECT 
    *
FROM
    layoffs_staging2;
