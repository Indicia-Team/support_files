select taxon_id, taxon_designation_id, start_date,source, geographical_constraint, count(*)
into temporary duplicates
from taxa_taxon_designations
where deleted=false
group by taxon_id, taxon_designation_id, start_date,source, geographical_constraint
having count(*) > 1;

update taxa_taxon_designations set deleted=true, updated_by_id=3, updated_on=now() where id in (
	select distinct ttd.id
	from taxa_taxon_designations ttd
	join duplicates d on d.taxon_id=ttd.taxon_id
	  and d.taxon_designation_id=ttd.taxon_designation_id
	  and coalesce(d.start_date, '1900/01/01'::date)=coalesce(ttd.start_date, '1900/01/01'::date)
	  and coalesce(d.source, '')=coalesce(ttd.source, '')
	  and coalesce(d.geographical_constraint, '')=coalesce(ttd.geographical_constraint, '')
	join taxa_taxon_designations ttd2 on ttd2.taxon_id=ttd.taxon_id
	  and ttd2.taxon_designation_id=ttd.taxon_designation_id
	  and coalesce(ttd2.start_date, '1900/01/01'::date)=coalesce(ttd.start_date, '1900/01/01'::date)
	  and coalesce(ttd2.source, '')=coalesce(ttd.source, '')
	  and coalesce(ttd2.geographical_constraint, '')=coalesce(ttd.geographical_constraint, '')
	  and ttd2.id<ttd.id
	  and ttd2.deleted=false
	where ttd.deleted=false
)