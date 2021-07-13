SET SESSION datestyle = 'ISO,DMY';

SET search_path=gbif, public;

TRUNCATE backbone;
COPY backbone FROM '{{ data-path }}backbone-current-simple.txt';
