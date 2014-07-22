-- spreadsheet-drop.sql
--
-- @author Benjamin Brink
-- @copyright 2014
-- @for OpenACS.org
-- @cvs-id


drop index qss_cells_id_idx;
drop index qss_cells_sheet_id_idx;
DROP TABLE qss_cells;

drop index qss_sheets_id_idx;
drop index qss_sheets_template_id_idx;
drop index qss_sheets_instance_id_idx;
drop index qss_sheets_user_id_idx;
drop index qss_sheets_trashed_idx;
DROP TABLE qss_sheets;

DROP TABLE qss_sheets_object_id_map;
DROP SEQUENCE qss_id_seq;

-- drop the simple-table db model

DROP index qss_simple_cells_table_id_idx;
DROP TABLE qss_simple_cells;

DROP index qss_simple_table_id_idx;
DROP index qss_simple_table_template_id_idx;
DROP index qss_simple_table_instance_id_idx;
DROP index qss_simple_table_user_id_idx;
DROP TABLE qss_simple_table;

DROP TABLE qss_simple_object_id_map;
DROP SEQUENCE qss_simple_id_seq;
