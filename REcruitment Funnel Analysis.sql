create database recruitment_funnel;
use recruitment_funnel;
select * from recruitment_dataset;

# Candidate counts in Each stage
select Count(*) as count_at_stage, stage
from recruitment_dataset
group by stage
order by count_at_stage desc;

# Conversion from application to screening
with application_count as(
select count(Distinct(candidate_id)) as applied_count, stage
from recruitment_dataset
where stage = 'Applied'),

screening as (
select count(Distinct(Candidate_id)) as screening_count, stage 
from recruitment_dataset
where Stage='screening')
select
screening_count * 100.0/applied_count as conversion_rate 
from application_count, screening;

# Conversion rate from screening to Interview

with screening as(
select count(distinct candidate_id)as screening_count, stage 
from recruitment_dataset
where stage = 'screening'),

Interview as(
select count(distinct candidate_id ) as interview_count, stage 
from recruitment_dataset
where stage ='Interview')

Select
interview_count *100.0 /screening_count as conversion_rate 
from screening, interview;


# Conversion rate from interview to offer
with interview as (
select count(distinct candidate_id) as interview_count
from recruitment_dataset
where stage='Interview'),

offer as (
select count(distinct candidate_id) as offer_count
from recruitment_dataset
where stage='Offer')

select
offer_count*100.0/interview_count as conversion_rate
from interview, offer;


# Conversion rate from offer to hired

with offered_candidates as(
select distinct candidate_id 
from recruitment_dataset
where stage='Offer'),

hired_candidates as(
select distinct candidate_id 
from recruitment_dataset
where stage='Hired')

select count(distinct h.candidate_id)*100.0/count(distinct o.candidate_id) as conversion_rate
from offered_candidates o
left join hired_candidates h 
on o.candidate_id=h.candidate_id;

# Time to hire
select candidate_id,
min(case when stage='Applied' then stage_date end) as applied_date,
min(case when stage='Hired' then stage_date end) as hired_date,
datediff(min(case when stage='Hired' then stage_date end),min(case when stage='Applied' then stage_date end)) as time_to_hire
from recruitment_dataset
group by candidate_id
having hired_date is not null
order by time_to_hire;


#Avg time to hire

select avg(time_to_hire) as avg_time_to_hire
from(select candidate_id,
min(case when stage='Applied' then stage_date end) as applied_date,
min(case when stage='Hired' then stage_date end) as hired_date,
datediff(min(case when stage='Hired' then stage_date end),min(case when stage='Applied' then stage_date end)) as time_to_hire
from recruitment_dataset
group by candidate_id
having hired_date is not null
order by time_to_hire)t;

#Drop off rates stage wise
# In application to screening
select count(distinct candidate_id) as count, stage
from recruitment_dataset 
group by stage
order by count desc;

with application as (
select count(distinct candidate_id) as application_count
from recruitment_dataset
where stage='applied'),

screening as (
select count(distinct candidate_id) as screening_count
from recruitment_dataset
where stage='screening')

select (application_count - screening_count)*100.0/application_count as dropping_rate
from application, screening; 

# In screening to interview

with screening as (
select count(distinct candidate_id) as screening_count
from recruitment_dataset
where stage='screening'),

interview as (
select count(distinct candidate_id) as interview_count
from recruitment_dataset
where stage='Interview')

select (screening_count - interview_count)*100.0/screening_count as dropping_rate
from screening, interview; 
# In interview to offer
with interview as (
select count(distinct candidate_id) as interview_count
from recruitment_dataset
where stage='interview'),

offer as (
select count(distinct candidate_id) as offer_count
from recruitment_dataset
where stage='offer')


select (interview_count - offer_count)*100.0/interview_count as dropping_rate
from interview,offer ; 
# In offer to hire
with offer as (
select count(distinct candidate_id) as offer_count
from recruitment_dataset
where stage='offer'),

hired as (
select count(distinct candidate_id) as hired_count
from recruitment_dataset
where stage='Hired')


select (Offer_count - hired_count)*100.0/offer_count as dropping_rate
from offer,hired ; 
