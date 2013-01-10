-- -----------------------------------------------------
-- Table "tusuario"
-- -----------------------------------------------------
ALTER TABLE "tusuario" ADD COLUMN "disabled" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "shortcut" SMALLINT DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "disabled" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "shortcut" SMALLINT DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "shortcut_data" text DEFAULT '';
ALTER TABLE "tusuario" ADD COLUMN "section" varchar(255) NOT NULL DEFAULT '';
INSERT INTO "tusuario" ("section") VALUES ("Default");
ALTER TABLE "tusuario" ADD COLUMN "data_section" varchar(255) NOT NULL DEFAULT '';
ALTER TABLE "tusuario" ADD COLUMN "force_change_pass" SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "last_pass_change" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "last_failed_login" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "failed_attempt" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tusuario" ADD COLUMN "login_blocked" SMALLINT NOT NULL DEFAULT 0;
CREATE TYPE type_tusuario_metaconsole_access AS ENUM ('basic','advanced','custom','all','only_console');
ALTER TABLE "tusuario" ADD COLUMN "metaconsole_access" type_tusuario_metaconsole_access DEFAULT 'only_console';
ALTER TABLE "tusuario" ADD COLUMN "not_login" SMALLINT NOT NULL default 0;

-- -----------------------------------------------------
-- Table "tnetflow_filter"
-- -----------------------------------------------------
CREATE TABLE "tnetflow_filter" (
	"id_sg" SERIAL NOT NULL PRIMARY KEY,
	"id_name" varchar(600) NOT NULL default '',
	"id_group" INTEGER,
	"ip_dst" TEXT NOT NULL,
	"ip_src" TEXT NOT NULL,
	"dst_port" TEXT NOT NULL,
	"src_port" TEXT NOT NULL,
	"advanced_filter" TEXT NOT NULL,
	"filter_args" TEXT NOT NULL,
	"aggregate" varchar(60),
	"output" varchar(60)
);

-- -----------------------------------------------------
-- Table "tnetflow_report"
-- -----------------------------------------------------
CREATE TABLE "tnetflow_report" (
	"id_report" SERIAL NOT NULL PRIMARY KEY,
	"id_name" varchar(150) NOT NULL default '',
	"description" TEXT,
	"id_group" INTEGER,
	"server_name" TEXT
);

-- -----------------------------------------------------
-- Table "tnetflow_report_content"
-- -----------------------------------------------------
CREATE TABLE "tnetflow_report_content" (
	"id_rc" SERIAL NOT NULL PRIMARY KEY,
	"id_report" INTEGER NOT NULL default 0 REFERENCES tnetflow_report("id_report") ON DELETE CASCADE,
	"id_filter" INTEGER NOT NULL default 0 REFERENCES tnetflow_filter("id_sg") ON DELETE CASCADE,
	"description" TEXT,
	"date" BIGINT NOT NULL default 0,
	"period" INTEGER NOT NULL default 0,
	"max" INTEGER NOT NULL default 0,
	"show_graph" varchar(60),
	"order" INTEGER NOT NULL default 0
);

-- -----------------------------------------------------
-- Table "tincidencia"
-- -----------------------------------------------------
ALTER TABLE "tincidencia" ADD COLUMN "id_agent" INTEGER NULL DEFAULT 0;

-- -----------------------------------------------------
-- Table "tagente"
-- -----------------------------------------------------
ALTER TABLE "tagente" ADD COLUMN "url_address" text NULL default '';
ALTER TABLE "tagente" ADD COLUMN "quiet" SMALLINT NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "normal_count" INTEGER NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "warning_count" INTEGER NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "critical_count" INTEGER NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "unknown_count" INTEGER NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "notinit_count" INTEGER NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "total_count" INTEGER NOT NULL default 0;
ALTER TABLE "tagente" ADD COLUMN "fired_count" INTEGER NOT NULL default 0;

-- -----------------------------------------------------
-- Table "talert_special_days"
-- -----------------------------------------------------

CREATE TYPE type_talert_special_days_same_day AS ENUM ('monday','tuesday','wednesday','thursday','friday','saturday','sunday');
CREATE TABLE "talert_special_days" (
        "id" SERIAL NOT NULL PRIMARY KEY,
        "date" DATE NOT NULL default '0001-01-01',
        "same_day" type_talert_special_days_same_day NOT NULL default 'sunday',
        "description" TEXT
);

-- -----------------------------------------------------
-- Table "talert_templates"
-- -----------------------------------------------------

ALTER TABLE "talert_templates" ADD COLUMN "special_day" SMALLINT default 0;
CREATE TYPE type_talert_templates_wizard_level AS ENUM ('basic','advanced','custom','nowizard');
ALTER TABLE "talert_templates" ADD COLUMN "wizard_level" type_talert_templates_wizard_level default 'nowizard';

-- -----------------------------------------------------
-- Table "tplanned_downtime"
-- -----------------------------------------------------
ALTER TABLE "tplanned_downtime" ADD COLUMN "monday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "tuesday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "wednesday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "thursday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "friday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "saturday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "sunday" SMALLINT default 0;
ALTER TABLE "tplanned_downtime" ADD COLUMN "periodically_time_from" TIME default NULL;
ALTER TABLE "tplanned_downtime" ADD COLUMN "periodically_time_to" TIME default NULL;
ALTER TABLE "tplanned_downtime" ADD COLUMN "periodically_day_from" SMALLINT default NULL;
ALTER TABLE "tplanned_downtime" ADD COLUMN "periodically_day_to" SMALLINT default NULL;
ALTER TABLE "tplanned_downtime" ADD COLUMN "type_downtime" VARCHAR( 100 ) NOT NULL default 'disabled_agents_alerts';
ALTER TABLE "tplanned_downtime" ADD COLUMN "type_execution" VARCHAR( 100 ) NOT NULL default 'once';
ALTER TABLE "tplanned_downtime" ADD COLUMN "type_periodicity" VARCHAR( 100 ) NOT NULL default 'weekly';

-- -----------------------------------------------------
-- Table "tplanned_downtime_agents"
-- -----------------------------------------------------
DELETE FROM "tplanned_downtime_agents"
WHERE "id_downtime" NOT IN (SELECT "id" FROM "tplanned_downtime");

ALTER TABLE "tplanned_downtime_agents"
ADD CONSTRAINT downtime_foreign
FOREIGN KEY("id_downtime")
REFERENCES "tplanned_downtime"("id");

ALTER TABLE "tplanned_downtime_agents" ADD COLUMN "all_modules" SMALLINT default 1;

------------------------------------------------------------------------
-- Table "tplanned_downtime_modules"
------------------------------------------------------------------------
CREATE TABLE "tplanned_downtime_modules" (
	"id" BIGSERIAL NOT NULL PRIMARY KEY,
	"id_agent" BIGINT NOT NULL default 0,
	"id_agent_module" INTEGER NOT NULL default 0,
	"id_downtime" BIGINT NOT NULL REFERENCES tplanned_downtime("id")  ON DELETE CASCADE 
);

------------------------------------------------------------------------
-- Table "tevento"
------------------------------------------------------------------------
ALTER TABLE "tevento" ADD COLUMN "source" text NULL default '';
ALTER TABLE "tevento" ADD COLUMN "id_extra" text NULL default '';
ALTER TABLE "tevento" ADD COLUMN "critical_instructions" text default '';
ALTER TABLE "tevento" ADD COLUMN "warning_instructions" text default '';
ALTER TABLE "tevento" ADD COLUMN "unknown_instructions" text default '';
ALTER TYPE type_tevento_event ADD VALUE 'going_unknown' BEFORE 'unknown';
ALTER TABLE "tevento" ADD COLUMN "owner_user" varchar(100) NOT NULL default '0';
ALTER TABLE "tevento" ADD COLUMN "ack_utimestamp" BIGINT NOT NULL default 0;

-- -----------------------------------------------------
-- Table "tgrupo"
-- -----------------------------------------------------

ALTER TABLE "tgrupo" ADD COLUMN "description" text;
ALTER TABLE "tgrupo" ADD COLUMN "contact" text;
ALTER TABLE "tgrupo" ADD COLUMN "other" text;

-- -----------------------------------------------------
-- Table "talert_snmp"
-- -----------------------------------------------------

ALTER TABLE "talert_snmp" ADD COLUMN "_snmp_f1_" text DEFAULT ''; 
ALTER TABLE "talert_snmp" ADD COLUMN "_snmp_f2_" text DEFAULT ''; 
ALTER TABLE "talert_snmp" ADD COLUMN "_snmp_f3_" text DEFAULT '';
ALTER TABLE "talert_snmp" ADD COLUMN "_snmp_f4_" text DEFAULT '';
ALTER TABLE "talert_snmp" ADD COLUMN "_snmp_f5_" text DEFAULT '';
ALTER TABLE "talert_snmp" ADD COLUMN "_snmp_f6_" text DEFAULT '';
ALTER TABLE "talert_snmp" ADD COLUMN "trap_type" INTEGER NOT NULL DEFAULT '-1';
ALTER TABLE "talert_snmp" ADD COLUMN "single_value" varchar(255) DEFAULT '';

-- -----------------------------------------------------
-- Table "tagente_modulo"
-- -----------------------------------------------------
ALTER TABLE "tagente_modulo" ADD COLUMN "module_ff_interval" INTEGER NOT NULL default 0;
ALTER TABLE "tagente_modulo" ADD COLUMN "quiet" SMALLINT NOT NULL default 0;
CREATE TYPE type_tagente_modulo_wizard_level AS ENUM ('basic','advanced','custom','nowizard');
ALTER TABLE "tagente_modulo" ADD COLUMN "wizard_level" type_tagente_modulo_wizard_level default 'nowizard';
ALTER TABLE "tagente_modulo" ADD COLUMN "macros" TEXT default '';
ALTER TABLE "tagente_modulo" ADD COLUMN "critical_instructions" text default '';
ALTER TABLE "tagente_modulo" ADD COLUMN "warning_instructions" text default '';
ALTER TABLE "tagente_modulo" ADD COLUMN "unknown_instructions" text default '';
ALTER TABLE "tagente_modulo" ADD COLUMN "critical_inverse" SMALLINT NOT NULL default 0;
ALTER TABLE "tagente_modulo" ADD COLUMN "warning_inverse" SMALLINT NOT NULL default 0;
ALTER TABLE "tagente_modulo" ADD COLUMN "cron_interval" varchar(100) default '';
ALTER TABLE "tagente_modulo" ADD COLUMN "max_retries" INTEGER default 0;
ALTER TABLE "tagente_modulo" ADD COLUMN "id_category" INTEGER default 0;

-- Move the number of retries for web modules from plugin_pass to max_retries
UPDATE "tagente_modulo" SET max_retries=plugin_pass WHERE id_modulo=7;

-- -----------------------------------------------------
-- Table "tevent_filter"
-- -----------------------------------------------------
CREATE TABLE "tevent_filter" (
	"id_filter"  SERIAL NOT NULL PRIMARY KEY,
	"id_group_filter" INTEGER NOT NULL default 0,
	"id_name" varchar(600) NOT NULL,
	"id_group" INTEGER NOT NULL default 0,
	"event_type" TEXT NOT NULL default '',
	"severity" INTEGER NOT NULL default -1,
	"status" INTEGER NOT NULL default -1,
	"search" TEXT default '',
	"text_agent" TEXT default '', 
	"pagination" INTEGER NOT NULL default 25,
	"event_view_hr" INTEGER NOT NULL default 8,
	"id_user_ack" TEXT,
	"group_rep" INTEGER NOT NULL default 0,
	"tag_with" text NOT NULL,
	"tag_without" text NOT NULL,
	"filter_only_alert" INTEGER NOT NULL default -1
);

-- -----------------------------------------------------
-- Table "tconfig"
-- -----------------------------------------------------
ALTER TABLE "tconfig" ALTER COLUMN "value" TYPE TEXT;

INSERT INTO tconfig ("token", "value") SELECT 'list_ACL_IPs_for_API', array_to_string(ARRAY(SELECT value FROM tconfig WHERE token LIKE 'list_ACL_IPs_for_API%'), ';') AS "value";
INSERT INTO "tconfig" ("token", "value") VALUES ('event_fields', 'evento,id_agente,estado,timestamp');

-- -----------------------------------------------------
-- Table "treport_content_item"
-- -----------------------------------------------------
 ALTER TABLE treport_content_item ADD FOREIGN KEY("id_report_content") REFERENCES treport_content("id_rc") ON UPDATE CASCADE ON DELETE CASCADE;

-- -----------------------------------------------------
-- Table "treport"
-- -----------------------------------------------------
ALTER TABLE "treport" ADD COLUMN "id_template" INTEGER NOT NULL default 0;
ALTER TABLE "treport" ADD COLUMN "id_group_edit" BIGINT NOT NULL default 0;
ALTER TABLE "treport" ADD COLUMN "metaconsole" SMALLINT DEFAULT 0;

-- -----------------------------------------------------
-- Table "tgraph"
-- -----------------------------------------------------
ALTER TABLE "tgraph" ADD COLUMN "id_graph_template" INTEGER NOT NULL default 0;

-- -----------------------------------------------------
-- Table "ttipo_modulo"
-- -----------------------------------------------------
UPDATE "ttipo_modulo" SET "descripcion"='Generic data' WHERE "id_tipo"=1;
UPDATE "ttipo_modulo" SET "descripcion"='Generic data incremental' WHERE "id_tipo"=4;

-- -----------------------------------------------------
-- Table "treport_content_item"
-- -----------------------------------------------------
ALTER TABLE "treport_content_item" ADD COLUMN "operation" text default '';

-- -----------------------------------------------------
-- Table "tmensajes"
-- -----------------------------------------------------
ALTER TABLE "tmensajes" ALTER COLUMN "mensaje" TYPE TEXT;

-- -----------------------------------------------------
-- Table "talert_compound"
-- -----------------------------------------------------

ALTER TABLE "talert_compound" ADD COLUMN "special_day" SMALLINT default 0;

-- -----------------------------------------------------
-- Table "tnetwork_component"
-- -----------------------------------------------------

ALTER TABLE "tnetwork_component" ADD COLUMN "unit" text default '';
ALTER TABLE "tnetwork_component" ADD COLUMN "max_retries" INTEGER default 0;
ALTER TABLE "tnetwork_component" ADD COLUMN "id_category" INTEGER default 0;

-- -----------------------------------------------------
-- Table "talert_commands"
-- -----------------------------------------------------

INSERT INTO "talert_commands" ("name", "command", "description", "internal") VALUES ('Validate Event','Internal type','This alert validate the events matched with a module given the agent name (_field1_) and module name (_field2_)', 1);

-- -----------------------------------------------------
-- Table "tconfig"
-- -----------------------------------------------------

INSERT INTO "tconfig" ("token", "value") VALUES
('enable_pass_policy', 0),
('pass_size', 4),
('pass_needs_numbers', 0),
('pass_needs_symbols', 0),
('pass_expire', 0),
('first_login', 0),
('mins_fail_pass', 5),
('number_attempts', 5),
('enable_pass_policy_admin', 0),
('enable_pass_history', 0),
('compare_pass', 3),
('meta_style', 'meta_pandora'),
('enable_refr', 0);

-- -----------------------------------------------------
-- Table "tpassword_history"
-- -----------------------------------------------------
CREATE TABLE "tpassword_history" (
  "id_pass"  INTEGER NOT NULL PRIMARY KEY,
  "id_user" varchar(60) NOT NULL,
  "password" varchar(45) default NULL,
  "date_begin" BIGINT NOT NULL default 0,
  "date_end" BIGINT NOT NULL default 0,
);

-- -----------------------------------------------------
-- Table "tconfig"
-- -----------------------------------------------------
UPDATE TABLE tconfig SET "value"='comparation'
WHERE "token"='prominent_time';

-- -----------------------------------------------------
-- Table "tnetwork_component"
-- -----------------------------------------------------

CREATE TYPE type_tnetwork_component_wizard_level AS ENUM ('basic','advanced','custom','nowizard');
ALTER TABLE "tnetwork_component" ADD COLUMN "wizard_level" type_tnetwork_component_wizard_level default 'nowizard';
ALTER TABLE "tnetwork_component" ADD COLUMN "only_metaconsole" INTEGER default '0';
ALTER TABLE "tnetwork_component" ADD COLUMN "macros" TEXT default '';

-- -----------------------------------------------------
-- Table "tplugin"
-- -----------------------------------------------------

ALTER TABLE "tplugin" ADD COLUMN "macros" TEXT default '';
ALTER TABLE "tplugin" ADD COLUMN "parameters" TEXT default '';
ALTER TABLE "tplugin" ADD COLUMN "max_retries" INTEGER default '0';

------------------------------------------------------------------------
-- Table "trecon_task"
------------------------------------------------------------------------
ALTER TABLE "trecon_task" ALTER COLUMN "subnet" TYPE TEXT;
ALTER TABLE "trecon_task" ALTER COLUMN "field1" TYPE TEXT;

------------------------------------------------------------------------
-- Table "tlayout_data"
------------------------------------------------------------------------
ALTER TABLE "tlayout_data" ADD COLUMN "enable_link" SMALLINT NOT NULL default 1;
ALTER TABLE "tlayout_data" ADD COLUMN "id_metaconsole" INTEGER NOT NULL default 0;

------------------------------------------------------------------------
-- Table "tnetwork_component"
------------------------------------------------------------------------
ALTER TABLE "tnetwork_component" ADD COLUMN "critical_instructions" text default '';
ALTER TABLE "tnetwork_component" ADD COLUMN "warning_instructions" text default '';
ALTER TABLE "tnetwork_component" ADD COLUMN "unknown_instructions" text default '';
ALTER TABLE "tnetwork_component" ADD COLUMN "critical_inverse" SMALLINT NOT NULL default 0;
ALTER TABLE "tnetwork_component" ADD COLUMN "warning_inverse" SMALLINT NOT NULL default 0;
ALTER TABLE "tnetwork_component" ADD COLUMN "tags" text default '';

------------------------------------------------------------------------
-- Table "tnetwork_map"
------------------------------------------------------------------------
ALTER TABLE "tnetwork_map" ADD COLUMN "text_filter" VARCHAR(100) DEFAULT '';
ALTER TABLE "tnetwork_map" ADD COLUMN "dont_show_subgroups" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tnetwork_map" ADD COLUMN "pandoras_children" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tnetwork_map" ADD COLUMN "show_modules" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tnetwork_map" ADD COLUMN "show_groups" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "tnetwork_map" ADD COLUMN "id_agent" INTEGER NOT NULL default 0;
ALTER TABLE "tnetwork_map" ADD COLUMN "server_name" VARCHAR(100)  NOT NULL;
ALTER TABLE "tnetwork_map" ADD COLUMN "show_modulegroup" INTEGER NOT NULL default 0;

------------------------------------------------------------------------
-- Table "tagente_estado"
------------------------------------------------------------------------
ALTER TABLE "tagente_estado" ADD COLUMN "last_known_status" INTEGER default 0;
ALTER TABLE "tagente_estado" ADD COLUMN "last_error" INTEGER default 0;

-- -----------------------------------------------------
-- Table "tevent_response"
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS "tevent_response" (
	"id"  SERIAL NOT NULL PRIMARY KEY,
	"name" varchar(600) NOT NULL default '',
	"description" TEXT,
	"target" TEXT,
	"type" varchar(60) NOT NULL,
	"id_group" INTEGER NOT NULL default 0,
	"modal_width" INTEGER NOT NULL DEFAULT 0,
	"modal_height" INTEGER NOT NULL DEFAULT 0,
	"new_window" INTEGER NOT NULL DEFAULT 0,
	"params" TEXT,
);

-- ----------------------------------------------------------------------
-- Table "talert_actions"
-- ----------------------------------------------------------------------
ALTER TABLE "talert_actions" ADD COLUMN "field4" TEXT NOT NULL;
ALTER TABLE "talert_actions" ADD COLUMN "field5" TEXT NOT NULL;
ALTER TABLE "talert_actions" ADD COLUMN "field6" TEXT NOT NULL;
ALTER TABLE "talert_actions" ADD COLUMN "field7" TEXT NOT NULL;
ALTER TABLE "talert_actions" ADD COLUMN "field8" TEXT NOT NULL;
ALTER TABLE "talert_actions" ADD COLUMN "field9" TEXT NOT NULL;
ALTER TABLE "talert_actions" ADD COLUMN "field10" TEXT NOT NULL;

-- ----------------------------------------------------------------------
-- Table "talert_templates"
-- ----------------------------------------------------------------------
ALTER TABLE "talert_templates" ADD COLUMN "field4" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field5" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field6" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field7" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field8" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field9" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field10" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field4_recovery" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field5_recovery" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field6_recovery" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field7_recovery" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field8_recovery" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field9_recovery" TEXT NOT NULL;
ALTER TABLE "talert_templates" ADD COLUMN "field10_recovery" TEXT NOT NULL;

-- ----------------------------------------------------------------------
-- Table "talert_commands"
-- ----------------------------------------------------------------------
ALTER TABLE "talert_commands" ADD COLUMN "fields_descriptions" TEXT;
ALTER TABLE "talert_commands" ADD COLUMN "fields_values" TEXT;

-- ---------------------------------------------------------------------
-- Table "tcategory"
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "tcategory" (
	"id"  SERIAL NOT NULL PRIMARY KEY,
	"name" varchar(600) NOT NULL default '',
);

-- ----------------------------------------------------------------------
-- Table "tperfil"
-- ----------------------------------------------------------------------
ALTER TABLE "tperfil" ADD COLUMN "report_view" SMALLINT NOT NULL default 0;
ALTER TABLE "tperfil" ADD COLUMN "report_edit" SMALLINT NOT NULL default 0;
ALTER TABLE "tperfil" ADD COLUMN "report_management" SMALLINT NOT NULL default 0;
ALTER TABLE "tperfil" ADD COLUMN "event_view" SMALLINT NOT NULL default 0;
ALTER TABLE "tperfil" ADD COLUMN "event_edit" SMALLINT NOT NULL default 0;
ALTER TABLE "tperfil" ADD COLUMN "event_management" SMALLINT NOT NULL default 0;

UPDATE tperfil SET "report_view"= 1, "event_view"= 1 WHERE id_perfil = 1 AND name = 'Operator&#x20;&#40;Read&#41;';
UPDATE tperfil SET "report_view"= 1, "report_edit"= 1, "event_view"= 1, "event_edit"= 1 WHERE id_perfil = 2 AND name = 'Operator&#x20;&#40;Write&#41;';
UPDATE tperfil SET "report_view"= 1, "report_edit"= 1, "report_management"= 1, "event_view"= 1, "event_edit"= 1 WHERE id_perfil = 3 AND name = 'Chief&#x20;Operator';
UPDATE tperfil SET "report_view"= 1, "report_edit"= 1, "report_management"= 1, "event_view"= 1, "event_edit"= 1, "event_management"= 1 WHERE id_perfil = 4 AND name = 'Group&#x20;coordinator';
UPDATE tperfil SET "report_view"= 1, "report_edit"= 1, "report_management"= 1, "event_view"= 1, "event_edit"= 1, "event_management"= 1 WHERE id_perfil = 5 AND name = 'Pandora&#x20;Administrator';

-- ---------------------------------------------------------------------
-- Table `tusuario_perfil`
-- ---------------------------------------------------------------------
ALTER TABLE "tusuario_perfil" ADD COLUMN "tags" text default '';

-- ---------------------------------------------------------------------
-- Table `ttag`
-- ---------------------------------------------------------------------
ALTER TABLE "ttag" ADD COLUMN "email" TEXT NULL;