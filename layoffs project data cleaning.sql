# Data Cleaning layoffs - find duplicates, standardize data, address null or blank values, remove any column where necessary 
SELECT * 
FROM layoffs;

# Creating a second table so original data is not altered
create table layoffs_staging
like layoffs;

insert layoffs_staging
select *
from layoffs;

# Identifying duplicates, created a column row_num to identify any duplicates.  Work around because there is no unique identifying column.
select *,
Row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

with duplicate_cte as
(select *,
Row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging)
select *
from duplicate_cte
where row_num > 1;

# Deleting the duplicates, since you can't delete a cte statement will create a second table with only the duplicates
# and then delete that table where row_num is > 1.  

create table layoffs_staging2 (
	`company` text,
	`location` text,
    `industry` text,
    `total_laid_off` int default null,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int default null,
    `row_num` int)
    engine = InnoDB default charset = utf8mb4 collate = utf8mb4_0900_ai_ci;
    
select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
Row_number() over(partition by company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

delete
from layoffs_staging2
where row_num > 1;

select *
from layoffs_staging2;

# standardize data - removing white space, dealing with null and blank values (replacing where possible), 
#removed a (.) from end of United States, changed date column from text to date, replace some blank rows with null and 
# deleted the null values, removed the row_num column.

# removed white space before company name
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

# have null and blank industries, multiple crypto types
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select  industry
from layoffs_staging2
where industry like 'crypto%';

select distinct location
from layoffs_staging2
order by 1;

select distinct country
from layoffs_staging2
order by 1;

select distinct country, trim(trailing "." from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing "." from country)
where country like "united states%";

select distinct country
from layoffs_staging2
order by 1;

# change date column from text to date column
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2
order by 1;

alter table layoffs_staging2
modify column `date` date;

select *
from layoffs_staging2;

# address the null values in the table
select industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry is null
or industry = "";

# see that airbnb has populated values in other rows for the same company
select *
from layoffs_staging2
where company = 'airbnb';

# so we can use a self join to update rows with blank in industry, basically does a company have an industry 
# column with a blank entry and an industry column that is populated, if so we can use the populated row in industry column to 
# populate the blank row in the industry column.
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

# set blanks to nulls first before updating
update layoffs_staging2 t1
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

select *
from layoffs_staging2
where company like 'bally%';

# delete rows where total_laid_off and percentage_laid_off are null
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

# drop row_num column
alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;