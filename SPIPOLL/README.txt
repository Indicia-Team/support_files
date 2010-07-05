This folder holds additional files used for the SPIPOLL project, associated with the pollenator and pollenator_gallery IForms.

The attributes.sql file holds the definitions of the occurrence, sample and location attributes. This file needs to be run against the database.
It does not
1) assign them to the correct website/survey combination - this must be done by hand.
2) Set any termlist sort order.
3) There are some characters which were difficult to set using this method (like the temperature degree sign and some French accents) - these need to be done manually by re-editing the record or its termlist.

The WFS_views.sql file hold the  views used to expose data to WFS. This needs to be run against the database.

The *mini.png files are themeing files for the map. These are for old style controls which are not styled by CSS. They should be dropped into the iform/media/js/img directory on the DRUPAL install.

The occ*.png files are required for the labeling of insects, and should be put in the misc directory.