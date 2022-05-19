libname archive 'T:\Covid19_daily_dataset_archive';
libname rates 'T:\ACDC-Shared Files\nCoV- 2019 Novel Coronavirus\Case_Dashboard\rate_daily\Data';
options compress=yes;


data cases;
set archive.cases (keep=incident_id person_id age date_episode age_cat_five_char);
where date_episode GE '25Dec2021'd;
run;

data cases_req;
set cases;
length age_new $20.;
if age >= 5 and age =< 11 then age_new = '5 to 11';
else if age >= 12 and age <= 49 then age_new = '18 to 49';
run;


proc sql;
create table tp as
select count(incident_id) as n, date_episode, age_new
from cases_req
where age_new ne''
group by age_new, date_episode
;quit;



proc sort data=tp; by age_new; run;

proc timeseries data=tp out=time_tp;
by age_new;
id date_episode interval=day start='25DEC2021'D end="&ydt."D setmiss=0;
var n;
run;

proc sort data=time_tp; by age_new; run;

proc expand data=time_tp out=exp_tp;
by age_new;
id date_episode;
convert n=_7day_cases / transformin=(setmiss 0) transformout=(movsum 7);
run;

libname pop 'T:\ACDC-Shared Files\nCoV- 2019 Novel Coronavirus\Data Management\Population';


data tp_f;
set exp_tp;
if age_new = '5 to 11' then population = 851726;
else if age_new = '18 to 49' then population = 4428873;
run;

data tp_final;
set tp_f;
case_rate = (_7day_cases/population)*100000;
run;



PROC SQL;
SELECT DATE_EPISODE, AGE_NEW, n,  _7day_cases, case_rate
FROM TP_FINAL
WHERE DATE_EPISODE IN ('16MAY2022'D, '18APR2022'D)
order by age_new ,date_episode
;QUIT;



/*** POPULATION ESTIMATES ***/
/*
if age_cat_five_char = '1:0-4' then population = 525893;
else if age_cat_five_char = '2:5-11' then population = 851726;
else if age_cat_five_char = '3:12-17' then population = 719377;
else if age_cat_five_char = '4:18-29' then population = 1703423;
else if age_cat_five_char = '5:30-49' then population =  2725450;
else if age_cat_five_char = '6:50-64' then population = 1856788;
else if age_cat_five_char = '7:65-79' then population = 931389;
else if age_cat_five_char = '8:Over 80' then population = 337286;
*/
