<?php
/**
 * Indicia, the OPAL Online Recording Toolkit.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/gpl.html.
 *
 * @package	Client
 * @author	Indicia Team
 * @license	http://www.gnu.org/licenses/gpl.html GPL 3.0
 * @link 	http://code.google.com/p/indicia/
 */

global $custom_terms;

/**
 * Language terms for the importer form.
 *
 * @package	Client
 */
$custom_terms = array(
  'column_mapping_instructions' =>
      "Please map each column in the CSV file you are uploading to the associated attribute in the database. We've tried to ".
      "match your columns to the available attributes where possible so check any automatically selected attributes in the ".
      "<strong>Database Attributes</strong> column before proceeding. If you plan to repeat imports from similar spreadsheets in ".
      "future you can use the tickboxes to remember your choices.",
  'The following database attributes must be matched to a column in your import file before you can continue'
      => 'The following database attributes must be matched to a column in the file to be imported before you can continue',
  'Maps to attribute' => 'Database Attributes',
  'Column in import File' => 'Column in the file to be imported',
  'Name' => 'Name',
  'Centroid sref' => 'Spatial reference',
  'Centroid sref system' => 'Spatial reference system'
);