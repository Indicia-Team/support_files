
SELECT setval('indicia.taxon_meanings_id_seq', (SELECT max(id) FROM indicia.taxon_meanings), true);
SELECT setval('indicia.taxa_id_seq', (SELECT max(id) FROM indicia.taxa), true);
SELECT setval('indicia.taxa_taxon_lists_id_seq', (SELECT max(id) FROM indicia.taxa_taxon_lists), true);
SELECT setval('indicia.taxon_groups_id_seq', (SELECT max(id) FROM indicia.taxon_groups), true);
SELECT setval('indicia.taxon_ranks_id_seq', (SELECT max(id) FROM indicia.taxon_ranks), true);
