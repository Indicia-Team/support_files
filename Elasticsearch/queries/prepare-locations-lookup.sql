SELECT '"' || l.id || '"', l.id::text || '~' || l.name || '~' || COALESCE(l.code, '') || '~' || t.term
FROM locations l
JOIN cache_termlists_terms t ON t.id=l.location_type_id
WHERE l.deleted=false
AND l.location_type_id in (<indexed_location_type_ids>)
AND l.code NOT LIKE '%+%';