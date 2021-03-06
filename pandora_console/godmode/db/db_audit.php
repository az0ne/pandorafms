<?php

// Pandora FMS - http://pandorafms.com
// ==================================================
// Copyright (c) 2005-2009 Artica Soluciones Tecnologicas
// Please see http://pandorafms.org for full contribution list

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation for version 2.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// Load global vars
global $config;

ui_print_page_header (__('Database maintenance').' &raquo; '.__('Database audit purge'), "images/gm_db.png", false, "", true);

check_login ();

if (! check_acl ($config['id_user'], 0, "DM")) {
	db_pandora_audit("ACL Violation",
		"Trying to access Database Management Audit");
	require ("general/noaccess.php");
	return;
}

// All data (now)
$time["all"] = get_system_time ();

// 1 day ago
$time["1day"] = $time["all"]-86400;

// 3 days ago
$time["3day"] = $time["all"]-(86400*3);

// 1 week ago
$time["1week"] = $time["all"]-(86400*7);

// 2 weeks ago
$time["2week"] = $time["all"]-(86400*14);

// 1 month ago
$time["1month"] = $time["all"]-(86400*30);

// Three months ago
$time["3month"] = $time["all"]-(86400*90);

// Todo for a good DB maintenance 
/* 
	- Delete too on datos_string and and datos_inc tables 
	
	- A function to "compress" data, and interpolate big chunks of data (1 month - 60000 registers) 
	  onto a small chunk of interpolated data (1 month - 600 registers)
	
	- A more powerful selection (by Agent, by Module, etc).
*/

# ADQUIRE DATA PASSED AS FORM PARAMETERS
# ======================================
# Purge data using dates
if (isset($_POST["purgedb"])){	# Fixed 2005-1-13, nil
	$from_date = get_parameter_post("date_purge");
	
	$deleted = db_process_sql_delete('tsesion', array('utimestamp' => '< ' . $from_date));
	
	if ($deleted)
		ui_print_success_message(__('Success data deleted'));
	else
		ui_print_error_message(__('Error deleting data'));
}
# End of get parameters block

echo "<table cellpadding='4' cellspacing='4' class='databox' width='98%'>";
echo "<tr><td class='datos'>";
$result = db_get_row_sql ("SELECT COUNT(*) AS total, MIN(fecha) AS first_date, MAX(fecha) AS latest_date FROM tsesion");

echo "<b>".__('Total')."</b></td>";
echo "<td class='datos'>".$result["total"]." ".__('Records')."</td>";

echo "<tr>";
echo "<td class='datos2'><b>".__('First date')."</b></td>";
echo "<td class='datos2'>".$result["first_date"]."</td></tr>";

echo "<tr><td class='datos'>";
echo "<b>".__('Latest date')."</b></td>";
echo "<td class='datos'>".$result["latest_date"]."</td>";
echo "</tr></table>";
?>
<h4><?php echo __('Purge data') ?></h4>
<form name="db_audit" method="post" action="index.php?sec=gdbman&sec2=godmode/db/db_audit">
<table width='98%' cellpadding='4' cellspacing='4' class='databox'>
<tr><td class='datos'>
<select name="date_purge">
	<option value="<?php echo $time["3month"] ?>"><?php echo __('Purge audit data over 90 days') ?></option>
	<option value="<?php echo $time["1month"] ?>"><?php echo __('Purge audit data over 30 days') ?></option>
	<option value="<?php echo $time["2week"] ?>"><?php echo __('Purge audit data over 14 days') ?></option>
	<option value="<?php echo $time["1week"] ?>"><?php echo __('Purge audit data over 7 days') ?></option>
	<option value="<?php echo $time["3day"] ?>"><?php echo __('Purge audit data over 3 days') ?></option>
	<option value="<?php echo $time["1day"] ?>"><?php echo __('Purge audit data over 1 day') ?></option>
	<option value="<?php echo $time["all"] ?>"><?php echo __('Purge all audit data') ?></option>
</select>
</td>
<td class="datos">
<input class="sub wand" type="submit" name="purgedb" value="<?php echo __('Do it!') ?>" onClick="if (!confirm('<?php echo __('Are you sure?') ?>')) return false;">

</table>
</form>
