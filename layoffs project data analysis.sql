# exploratory data analysis

select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

# companies that laid off all of their employees
select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

# companies that laid off all of their employees versus amount of funds raised
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

# Companies versus sum of total laid off
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

# looking at the dates during which these layoffs occurred (note: this began aroundt he time lock downs from COVID started)
select min(`date`), max(`date`)
from layoffs_staging2;

# looking at which industries were hit hard during this time
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

# looking at the years during this time period (note: 2023 is only for the first 3 months at the time this data was used)
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

# looking at rolling total layoffs by month/year
select substring(`date`, 1, 7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc;

# shows each month how many were laid off and as the years progress 2020-2023 
with rolling_total as 
(select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as laid_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc)
select `month`, laid_off, sum(laid_off) over(order by `month`) as rolling_total
from rolling_total;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

# rank of top 5 companies who laid off most people by each year
with company_year (company, years, total_laid_off) as 
(select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as
(select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null)
select *
from company_year_rank
where ranking <=5;
