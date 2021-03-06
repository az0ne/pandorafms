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
$working_dir = str_replace("\\", "/", getcwd()); // Windows compatibility
if (file_exists($working_dir . '/include/config.php')) {
	require_once ("include/config.php");
}
else {
	require_once ("../../include/config.php");
}

$hash = (string)get_parameter('hash', '');
if (!empty($hash)) {
	//It is a ajax call from PUBLIC_CONSOLE
	
	$idMap = (int) get_parameter ('map_id');
	$id_user = get_parameter ('id_user', '');
	
	$myhash = md5($config["dbpass"] . $idMap . $id_user);
	
	// Check input hash
	if ($myhash == $hash) {
		$config['id_user'] = $id_user;
	}
}
else {
	check_login ();
}

global $config;

require_once ($config['homedir'] . '/include/functions_gis.php');
require_once ($config['homedir'] . '/include/functions_ui.php');
require_once ($config['homedir'] . '/include/functions_agents.php');
require_once ($config['homedir'] . '/include/functions_groups.php');

$opt = get_parameter('opt');

switch ($opt) {
	case 'get_data_conexion':
		$returnJSON['correct'] = 1;
		$idConection = get_parameter('id_conection');
		
		$row = db_get_row_filter('tgis_map_connection',
			array('id_tmap_connection' => $idConection));
		
		$returnJSON['content'] = $row;
		
		echo json_encode($returnJSON);
		break;
	case 'get_new_positions':
		$id_features = get_parameter('id_features', '');
		$last_time_of_data = get_parameter('last_time_of_data');
		$layerId = get_parameter('layer_id');
		$agentView = get_parameter('agent_view');
		
		$returnJSON = array();
		$returnJSON['correct'] = 1;
		
		$idAgentsWithGIS = array();
		
		if ($agentView == 0) {
			$flagGroupAll = db_get_all_rows_sql('SELECT tgrupo_id_grupo
				FROM tgis_map_layer
				WHERE id_tmap_layer = ' . $layerId . ' AND tgrupo_id_grupo = 0;'); //group 0 = all groups
			
			$defaultCoords = db_get_row_sql('SELECT default_longitude, default_latitude
				FROM tgis_map
				WHERE id_tgis_map IN (SELECT tgis_map_id_tgis_map FROM tgis_map_layer WHERE id_tmap_layer = ' . $layerId . ')');
			
			if ($flagGroupAll === false) {
				$idAgentsWithGISTemp = db_get_all_rows_sql('SELECT id_agente
					FROM tagente
					WHERE id_grupo IN
						(SELECT tgrupo_id_grupo
							FROM tgis_map_layer
							WHERE id_tmap_layer = ' . $layerId . ')
						OR id_agente IN
						(SELECT tagente_id_agente
							FROM tgis_map_layer_has_tagente
							WHERE tgis_map_layer_id_tmap_layer = ' . $layerId . ');');
			}
			else {
				//All groups, all agents
				$idAgentsWithGISTemp = db_get_all_rows_sql('SELECT
						tagente_id_agente AS id_agente
					FROM tgis_data_status
					WHERE tagente_id_agente');
			}
			
			if (empty($idAgentsWithGISTemp)) {
				$idAgentsWithGISTemp = array();
			}
			
			foreach ($idAgentsWithGISTemp as $idAgent) {
				$idAgentsWithGIS[] = $idAgent['id_agente'];
			}
		}
		else {
			//Extract the agent GIS status for one agent.
			$idAgentsWithGIS[] = $id_features;
		}
		
		switch ($config["dbtype"]) {
			case "mysql":
				if (empty($idAgentsWithGIS)) {
					$agentsGISStatus = db_get_all_rows_sql('SELECT t1.nombre, id_parent, t1.id_agente AS tagente_id_agente,
							IFNULL(t2.stored_longitude, ' . $defaultCoords['default_longitude'] . ') AS stored_longitude,
							IFNULL(t2.stored_latitude, ' . $defaultCoords['default_latitude'] . ') AS stored_latitude
						FROM tagente AS t1
						LEFT JOIN tgis_data_status AS t2 ON t1.id_agente = t2.tagente_id_agente
							WHERE 1 = 0');
				}
				else {
					$agentsGISStatus = db_get_all_rows_sql('SELECT t1.nombre, id_parent, t1.id_agente AS tagente_id_agente,
							IFNULL(t2.stored_longitude, ' . $defaultCoords['default_longitude'] . ') AS stored_longitude,
							IFNULL(t2.stored_latitude, ' . $defaultCoords['default_latitude'] . ') AS stored_latitude
						FROM tagente AS t1
						LEFT JOIN tgis_data_status AS t2 ON t1.id_agente = t2.tagente_id_agente
							WHERE id_agente IN (' . implode(',', $idAgentsWithGIS) . ')');
				}
				break;
			case "postgresql":
				if (empty($idAgentsWithGIS)) {
					$agentsGISStatus = db_get_all_rows_sql('SELECT t1.nombre, id_parent, t1.id_agente AS tagente_id_agente,
							COALESCE(t2.stored_longitude, ' . $defaultCoords['default_longitude'] . ') AS stored_longitude,
							COALESCE(t2.stored_latitude, ' . $defaultCoords['default_latitude'] . ') AS stored_latitude
						FROM tagente AS t1
						LEFT JOIN tgis_data_status AS t2 ON t1.id_agente = t2.tagente_id_agente
							WHERE 1 = 0');
				}
				else {
					$agentsGISStatus = db_get_all_rows_sql('SELECT t1.nombre, id_parent, t1.id_agente AS tagente_id_agente,
							COALESCE(t2.stored_longitude, ' . $defaultCoords['default_longitude'] . ') AS stored_longitude,
							COALESCE(t2.stored_latitude, ' . $defaultCoords['default_latitude'] . ') AS stored_latitude
						FROM tagente AS t1
						LEFT JOIN tgis_data_status AS t2 ON t1.id_agente = t2.tagente_id_agente
							WHERE id_agente IN (' . implode(',', $idAgentsWithGIS) . ')');
				}
				break;
			case "oracle":
				if (empty($idAgentsWithGIS)) {
					$agentsGISStatus = db_get_all_rows_sql('SELECT t1.nombre, id_parent, t1.id_agente AS tagente_id_agente,
							COALESCE(t2.stored_longitude, ' . $defaultCoords['default_longitude'] . ') AS stored_longitude,
							COALESCE(t2.stored_latitude, ' . $defaultCoords['default_latitude'] . ') AS stored_latitude
						FROM tagente t1
						LEFT JOIN tgis_data_status t2 ON t1.id_agente = t2.tagente_id_agente
							WHERE 1 = 0');
				}
				else {
					$agentsGISStatus = db_get_all_rows_sql('SELECT t1.nombre, id_parent, t1.id_agente AS tagente_id_agente,
							COALESCE(t2.stored_longitude, ' . $defaultCoords['default_longitude'] . ') AS stored_longitude,
							COALESCE(t2.stored_latitude, ' . $defaultCoords['default_latitude'] . ') AS stored_latitude
						FROM tagente t1
						LEFT JOIN tgis_data_status t2 ON t1.id_agente = t2.tagente_id_agente
							WHERE id_agente IN (' . implode(',', $idAgentsWithGIS) . ')');
				}
				break;
		}
		
		if ($agentsGISStatus === false) {
			$agentsGISStatus = array();
		}
		
		$agents = null;
		foreach ($agentsGISStatus as $row) {
			$status = agents_get_status($row['tagente_id_agente']);
			
			if (!$config['gis_label'])
				$row['nombre'] = '';
			
			$icon = gis_get_agent_icon_map($row['tagente_id_agente'], true, $status);
			if ($icon[0] !== '/') {
				$icon_size = getimagesize($config['homedir'] . "/" . $icon);
			}
			else {
				$icon_size = getimagesize($config['homedir'] . $icon);
			}
			$icon_width = $icon_size[0];
			$icon_height = $icon_size[1];
			
			$agents[$row['tagente_id_agente']] = array(
				'icon_path' => $config["homeurl"] . '/' . $icon,
				'icon_width' => $icon_width,
				'icon_height' => $icon_height,
				'name' => $row['nombre'],
				'status' => $status,
				'stored_longitude' => $row['stored_longitude'],
				'stored_latitude' => $row['stored_latitude'],
				'id_parent' => $row['id_parent'] 
			);
		}
		
		$returnJSON['content'] = json_encode($agents);
		echo json_encode($returnJSON);
		break;
	case 'point_path_info':
		$id = get_parameter('id');
		$row = db_get_row_sql('SELECT * FROM tgis_data_history WHERE id_tgis_data = ' . $id);
		
		$returnJSON = array();
		$returnJSON['correct'] = 1;
		$returnJSON['content'] = __('Agent') . ': <a style="font-weight: bolder;" href="?sec=estado&sec2=operation/agentes/ver_agente&id_agente=' . $row['tagente_id_agente'] . '">'.agents_get_name($row['tagente_id_agente']).'</a><br />';
		$returnJSON['content'] .= __('Position (Lat, Long, Alt)') . ': (' . $row['latitude'] . ', ' . $row['longitude'] . ', ' . $row['altitude'] . ') <br />';
		$returnJSON['content'] .= __('Start contact') . ': ' . $row['start_timestamp'] . '<br />';
		$returnJSON['content'] .= __('Last contact') . ': ' . $row['end_timestamp'] . '<br />';
		$returnJSON['content'] .= __('Num reports') . ': '.$row['number_of_packages'].'<br />'; 
		if ($row['manual_placemen'])
			$returnJSON['content'] .= '<br />' . __('Manual placement') . '<br />'; 
		
		echo json_encode($returnJSON);
		
		break;
	case 'point_agent_info':
		$id = get_parameter('id');
		$agent = db_get_row_sql('SELECT * FROM tagente WHERE id_agente = ' . $id);
		$agentDataGIS = gis_get_data_last_position_agent($agent['id_agente']);
		
		$returnJSON = array();
		$returnJSON['correct'] = 1;
		$returnJSON['content'] = '';

		$content = '';

		$table = new StdClass();
		$table->class = 'blank';
		$table->style = array();
		$table->style[0] = 'font-weight: bold';
		$table->rowstyle = array();
		$table->data = array();

		// Agent name
		$row = array();
		$row[] = __('Agent');
		$row[] = '<a style="font-weight: bolder;" href="?sec=estado&sec2=operation/agentes/ver_agente&id_agente='
			. $agent['id_agente'] . '">'.$agent['nombre'].'</a>';
		$table->data[] = $row;

		// Position
		$row = array();
		$row[] = __('Position (Lat, Long, Alt)');

		//it's positioned in default position of map.
		if ($agentDataGIS === false) {
			$row[] = __("Default position of map.");
		}
		else {
			$row[] = '(' . $agentDataGIS['stored_latitude'] . ', ' . $agentDataGIS['stored_longitude'] . ', ' . $agentDataGIS['stored_altitude'] . ')';
		}
		$table->data[] = $row;

		// IP
		$agent_ip_address = agents_get_address ($id);
		if ($agent_ip_address || $agent_ip_address != '') {
			$row = array();
			$row[] = __('IP Address');
			$row[] = agents_get_address($id);
			$table->data[] = $row;
		}

		// OS
		$row = array();
		$row[] = __('OS');
		$osversion_offset = strlen($agent["os_version"]);
		if ($osversion_offset > 15) {
			$osversion_offset = $osversion_offset - 15;
		}
		else {
			$osversion_offset = 0;
		}
		$row[] = ui_print_os_icon($agent['id_os'], true, true)
			. '&nbsp;(<i><span title="' . $agent["os_version"] . '">'
			. substr($agent["os_version"],$osversion_offset,15).'</span></i>)';
		$table->data[] = $row;

		// URL
		$agent_url = $agent['url_address'];
		if (!empty($agent_url)) {
			$row = array();
			$row[] = __('URL');
			$row[] = "<a href=\"$agent_url\">" . ui_print_truncate_text($agent_url, 20) . "</a>";
			$table->data[] = $row;
		}

		// Description
		$agent_description = $agent['comentarios'];
		if ($agent_description || $agent_description != '') {
			$row = array();
			$row[] = __('Description');
			$row[] = $agent_description;
			$table->data[] = $row;
		}

		// Group
		$row = array();
		$row[] = __('Group');
		$row[] = groups_get_name($agent["id_grupo"]);
		$table->data[] = $row;

		// Agent version
		$row = array();
		$row[] = __('Agent Version');
		$row[] = $agent["agent_version"];
		$table->data[] = $row;

		// Last contact
		$row = array();
		$row[] = __('Last contact');
		if ($agent["ultimo_contacto"] == "01-01-1970 00:00:00") {
			$row[] = __('Never');
		}
		else {
			$row[] = $agent["ultimo_contacto"];
		}
		$table->data[] = $row;

		// Last remote contact
		$row = array();
		$row[] = __('Remote');
		if ($agent["ultimo_contacto_remoto"] == "01-01-1970 00:00:00") {
			$row[] = __('Never');
		}
		else {
			$row[] = $agent["ultimo_contacto_remoto"];
		}
		$table->data[] = $row;

		// To remove the grey background color of the classes datos and datos2
		for ($i = 0; $i < count($table->data); $i++)
			$table->rowstyle[] = 'background-color: inherit;';

		// Save table
		$returnJSON['content'] = html_print_table($table, true);

		echo json_encode($returnJSON);
		break;
	case 'get_map_connection_data':
		$idConnection = get_parameter('id_connection');
		
		$returnJSON = array();
		
		$returnJSON['correct'] = 1;
		
		$returnJSON['content'] = db_get_row_sql('SELECT * FROM tgis_map_connection WHERE id_tmap_connection = ' . $idConnection);
		
		echo json_encode($returnJSON);
		break;
}
?>