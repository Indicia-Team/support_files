/*
 Script to repair Naturespot TVK mismatches.
 
 NatureSpot has its own taxon list. Names on the list are mapped to UKSI via the external_key field
 which is the preferred name's TVK. If a preffered name on UKSI is relegated to a synonym so there is
 a new preferred name TVK, this will leave the NatureSpot list pointing to a synonym rather than a
 preferred name. This fix updates the TVKs and provides information to pass to the NatureSpot site 
 editors so they can update their species accounts.
 
 IMPORTANT! This script includes a query output which needs to be sent the Naturespot.org.uk admin team.
*/

/*
 Run this script to build a temporary table with all details of taxon names that are mismatched on the Naturespot list.
 */
drop table if exists to_fix;
select cttl8.id as id_on_naturespot, cttl8.taxon as taxon_on_naturespot, cttl8.external_key as tvk_on_naturespot,
 cttl15.taxon as taxon_on_uksi, cttl15.authority as authority_on_uksi, cttl15.external_key as tvk_on_uksi,
 t.taxon as synonym_pointed_to_by_naturespot_tvk, t.authority as synonym_authority
into temporary to_fix
from cache_taxa_taxon_lists cttl8
join cache_taxa_taxon_lists cttl15 on cttl15.taxon_list_id=15 and cttl15.taxon=cttl8.taxon and cttl15.allow_data_entry=true
left join taxa t on t.search_code=cttl8.external_key
where cttl8.taxon_list_id=8
and cttl15.external_key<>cttl8.external_key
and cttl8.preferred=true
order by cttl8.taxon;

/*
 IMPORTANT!
 Download the output from the following as CSV and pass to the Naturespot.org.uk admin team, notifying them that there
 has been an update to preferred taxon keys.
 */
select * from to_fix;

update taxa t
set external_key=tf.tvk_on_uksi, updated_on=now()
from to_fix tf
join taxa_taxon_lists ttl on ttl.id=tf.id_on_naturespot
where t.id=ttl.taxon_id
and t.external_key=tf.tvk_on_naturespot;

-- Force cache updates.
update taxa_taxon_lists set updated_on=now() where id in (select id_on_naturespot from to_fix);
