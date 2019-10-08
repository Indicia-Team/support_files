# Location indexing update example

The following example goes through a scenario for updating the locations.yml file on BRC's warehouse1 after adding
a new layer to the location indexing.

1. Clone a copy of the https://github.com/Indicia-Team/support_files repository if you don't already have one.
2. On the live warehouse, check the spatial_index_builder modules's config file to find a list of location types that
   we are now using:
     'Vice County',
     'LRC Boundary',
     'Country',
     'Cairngorms NP NNR',
     'Miscellaneous indexed boundaries',
     'Butterfly Conservation Branch',
     'National Trust site',
     'NUTS Level 2',
     'RSPB Reserves',
     'Country territorial waters'
3. As NUTS Level 2 type is hierarhical we need to find the location types of the parents of these locations to add as
   well using a query like this:
   ```sql
   select distinct t3.term, t2.term
    from locations l1
    join cache_termlists_terms t1 on t1.id=l1.location_type_id and t1.term='NUTS Level 2'
    left join locations l2 on l2.id=l1.parent_id
    join cache_termlists_terms t2 on t2.id=l2.location_type_id
    left join locations l3 on l3.id=l2.parent_id
    join cache_termlists_terms t3 on t3.id=l3.location_type_id
   ```
   You could extend this to more than 3 levels if you suspected it were necessary (I happen to know it isn't!), or
   better, write a recursive query to be sure. This tells me I should add 'NUTS Level 1' and 'Countries 2016' to my list
   of types.
4. Find the list of IDs for all the types as follows:
   ```sql
   SELECT string_agg(id::text, ', ')
   FROM cache_termlists_terms
   WHERE termlist_title='Location types'
   AND term in (
     'Vice County',
     'LRC Boundary',
     'Country',
     'Cairngorms NP NNR',
     'Miscellaneous indexed boundaries',
     'Butterfly Conservation Branch',
     'National Trust site',
     'NUTS Level 2',
     'RSPB Reserves',
     'Country territorial waters',
     'NUTS Level 1',
     'Countries 2016'
   )
5. Grab the latest copy of the locations extraction query and insert the list of IDs into it:
   https://github.com/Indicia-Team/support_files/blob/master/Elasticsearch/queries/prepare-locations-lookup.sql
   ```sql
   SELECT l.id::text, l.id::text || '~' || l.name || '~' || COALESCE(l.code, '') || '~' || t.term
    FROM locations l
    JOIN cache_termlists_terms t ON t.id=l.location_type_id
    WHERE l.deleted=false
    AND l.location_type_id in (15, 1370, 2188, 4839, 4980, 5702, 1103, 2187, 14587, 16516, 16517, 17484)
    AND COALESCE(l.code, '') NOT LIKE '%+%';
   ```
6. Run this query in pgAdmin v4.x using the Download as CSV (F8) (rightmost toolbutton).
7. Grab the output file and remove the first line containing the headings row.
8. Replace the elasticsearch/data/locations.yml file with the output.
9. Search and replace `","` with `": "` then save the file. Note the other replacements listed in the documentation
   apply to the taxon data so are not necessary here.
10. Double check the git diff so you are sure only expected changes are in the locations.yml file.
11. Commit and push locations.yml, then RDP to the Elasticsearch server and do a git pull on
    `D:\elastic\indicia_support_files\` (you probably need to do this from the command prompt run as administrator).
12. Restart the `Elasticsearch Logstash 6.6` service on the Elasticsearch server to ensure changes are picked up.
13. Normally, I would then increment the tracking value in cache_occurrences_function only on the affected records. This
    can be done by simply assigning a field value to itself, e.g.:
    ```sql
    UPDATE cache_occurrences_functional SET website_id=website_id WHERE location_ids && ARRAY[<location IDs];
    ```
    That forces Logstash to detect the changes and update ES. However in this instance I've realised that the
    `locations.yml` file didn't contain the "Countries 2016" due to my own past mistake, so I'm going to re-index the
    whole lot which happens gradually over about 2 days if you reset the tracking information on the warehouse:
    ```sql
    DELETE FROM variables WHERE name='rest-autofeed-BRC5';
    ```