-- This SQL transfers all data from old iRecord surveys to new PoMS website surveys

update indicia.samples
set survey_id=636,updated_on=now(),updated_by_id=5553
where survey_id = 467 and deleted=false;

update indicia.occurrences o
set website_id=136,updated_on=now(),updated_by_id=5553
from indicia.samples s
where sample_id = s.id
and s.survey_id = 636
and o.deleted=false
and s.deleted=false;

update indicia.samples
set survey_id=637,updated_on=now(),updated_by_id=5553
where survey_id = 480 and deleted=false;

update indicia.occurrences o
set website_id=136,updated_on=now(),updated_by_id=5553
from indicia.samples s
where sample_id = s.id
and s.survey_id = 637
and o.deleted=false
and s.deleted=false;

update indicia.samples
set survey_id=638,updated_on=now(),updated_by_id=5553
where survey_id = 481 and deleted=false;

update indicia.occurrences o
set website_id=136,updated_on=now(),updated_by_id=5553
from indicia.samples s
where sample_id = s.id
and s.survey_id = 638
and o.deleted=false
and s.deleted=false;

insert into indicia.work_queue(task, entity, record_id, cost_estimate, priority, created_on)
select 'task_cache_builder_update', 'sample', id, 100, 2, now()
from indicia.samples
where survey_id in (636,637,638) and deleted=false;

insert into indicia.work_queue(task, entity, record_id, cost_estimate, priority, created_on)
select 'task_cache_builder_update', 'occurrence', o.id, 100, 2, now()
from indicia.occurrences o
join indicia.samples s on s.id = o.sample_id and survey_id in (636,637,638) and s.deleted=false
where o.deleted=false;