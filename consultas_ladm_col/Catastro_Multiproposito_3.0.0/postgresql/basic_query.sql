WITH
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'op_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'op_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 1377 AS ue_op_terreno WHERE '1377' <> 'NULL'
		UNION
	SELECT col_uebaunit.ue_op_terreno FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON op_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_op_terreno FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON op_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_op_terreno FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON op_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT col_uebaunit.baunit as t_id FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.ue_op_terreno = 1377 AND '1377' <> 'NULL'
		UNION
	SELECT t_id FROM test_ladm_col_queries.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial_anterior = 'NULL' END
 ),
  construcciones_seleccionadas AS (
	 SELECT ue_op_construccion FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.baunit IN (SELECT predios_seleccionados.t_id FROM predios_seleccionados WHERE predios_seleccionados.t_id IS NOT NULL) AND ue_op_construccion IS NOT NULL
 ),
 unidadesconstruccion_seleccionadas AS (
	 SELECT op_unidadconstruccion.t_id FROM test_ladm_col_queries.op_unidadconstruccion WHERE op_unidadconstruccion.op_construccion IN (SELECT ue_op_construccion FROM construcciones_seleccionadas)
 ),
 uc_extdireccion AS (
	SELECT extdireccion.op_unidadconstruccion_ext_direccion_id,
		json_agg(
			json_build_object('id', extdireccion.t_id,
									 'attributes', json_build_object('Tipo dirección', (select dispname from test_ladm_col_queries.extdireccion_tipo_direccion where t_id = extdireccion.tipo_direccion),
																	 'Código postal', extdireccion.codigo_postal,
																	 'Dirección', concat(COALESCE((select dispname from test_ladm_col_queries.extdireccion_clase_via_principal where t_id = extdireccion.clase_via_principal) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_principal || ' ', ''),
																						 COALESCE(extdireccion.letra_via_principal || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_ciudad where t_id = extdireccion.sector_ciudad) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.letra_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.numero_predio || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_predio where t_id = extdireccion.sector_predio) || ' ', ''),
																						 COALESCE(extdireccion.complemento || ' ', ''),
																						 COALESCE(extdireccion.nombre_predio || ' ', '')
																						)))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM test_ladm_col_queries.extdireccion WHERE op_unidadconstruccion_ext_direccion_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	GROUP BY extdireccion.op_unidadconstruccion_ext_direccion_id
 ),
 info_uc AS (
	 SELECT op_unidadconstruccion.op_construccion,
			json_agg(json_build_object('id', op_unidadconstruccion.t_id,
							  'attributes', json_build_object('Número de pisos', op_unidadconstruccion.total_pisos,
															  'Número de habitaciones', op_unidadconstruccion.total_habitaciones,
															  'Número de baños', op_unidadconstruccion.total_banios,
															  'Número de locales', op_unidadconstruccion.total_locales,
															  'Tipo construcción', (select dispname from test_ladm_col_queries.OP_ConstruccionTipo where t_id = op_unidadconstruccion.tipo_construccion),
															  'Tipo unidad de construcción', (select dispname from test_ladm_col_queries.OP_UnidadConstruccionTipo where t_id = op_unidadconstruccion.tipo_unidad_construccion),
															  'Tipo planta', (select dispname from test_ladm_col_queries.OP_ConstruccionPlantaTipo where t_id = op_unidadconstruccion.tipo_planta),
															  'Tipo dominio', (select dispname from test_ladm_col_queries.OP_DominioConstruccionTipo where t_id = op_unidadconstruccion.tipo_dominio),
															  'Ubicación en el piso', op_unidadconstruccion.planta_ubicacion,
															  CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), op_unidadconstruccion.area_construida,
															  'Uso', (SELECT dispname FROM test_ladm_col_queries.op_usouconstipo WHERE t_id = op_unidadconstruccion.uso),
															  'extdireccion', COALESCE(uc_extdireccion.extdireccion, '[]')
															 )) ORDER BY op_unidadconstruccion.t_id) FILTER(WHERE op_unidadconstruccion.t_id IS NOT NULL)  as unidadconstruccion
	 FROM test_ladm_col_queries.op_unidadconstruccion
	 LEFT JOIN uc_extdireccion ON op_unidadconstruccion.t_id = uc_extdireccion.op_unidadconstruccion_ext_direccion_id
	 WHERE op_unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	 GROUP BY op_unidadconstruccion.op_construccion
 ),
 c_extdireccion AS (
	SELECT extdireccion.op_construccion_ext_direccion_id,
		json_agg(
			json_build_object('id', extdireccion.t_id,
									 'attributes', json_build_object('Tipo dirección', (select dispname from test_ladm_col_queries.extdireccion_tipo_direccion where t_id = extdireccion.tipo_direccion),
																	 'Código postal', extdireccion.codigo_postal,
																	 'Dirección', concat(COALESCE((select dispname from test_ladm_col_queries.extdireccion_clase_via_principal where t_id = extdireccion.clase_via_principal) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_principal || ' ', ''),
																						 COALESCE(extdireccion.letra_via_principal || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_ciudad where t_id = extdireccion.sector_ciudad) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.letra_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.numero_predio || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_predio where t_id = extdireccion.sector_predio) || ' ', ''),
																						 COALESCE(extdireccion.complemento || ' ', ''),
																						 COALESCE(extdireccion.nombre_predio || ' ', '')
																						)))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM test_ladm_col_queries.extdireccion WHERE op_construccion_ext_direccion_id IN (SELECT * FROM construcciones_seleccionadas)
	GROUP BY extdireccion.op_construccion_ext_direccion_id
 ),
 info_construccion as (
	 SELECT col_uebaunit.baunit,
			json_agg(json_build_object('id', op_construccion.t_id,
							  'attributes', json_build_object('Área construcción', op_construccion.area_construccion,
															  'extdireccion', COALESCE(c_extdireccion.extdireccion, '[]'),
															  'op_unidadconstruccion', COALESCE(info_uc.unidadconstruccion, '[]')
															 )) ORDER BY op_construccion.t_id) FILTER(WHERE op_construccion.t_id IS NOT NULL) as construccion
	 FROM test_ladm_col_queries.op_construccion LEFT JOIN c_extdireccion ON op_construccion.t_id = c_extdireccion.op_construccion_ext_direccion_id
	 LEFT JOIN info_uc ON op_construccion.t_id = info_uc.op_construccion
     LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.ue_op_construccion = op_construccion.t_id
	 WHERE op_construccion.t_id IN (SELECT * FROM construcciones_seleccionadas)
	 GROUP BY col_uebaunit.baunit
 ),
 info_predio AS (
	 SELECT col_uebaunit.ue_op_terreno,
			json_agg(json_build_object('id', op_predio.t_id,
							  'attributes', json_build_object('Nombre', op_predio.nombre,
															  'Departamento', op_predio.departamento,
															  'Municipio', op_predio.municipio,
															  'NUPRE', op_predio.nupre,
															  'FMI', (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria),
															  'Número predial', op_predio.numero_predial,
															  'Número predial anterior', op_predio.numero_predial_anterior,
															  'Tipo', (SELECT dispname FROM test_ladm_col_queries.op_prediotipo WHERE t_id = op_predio.tipo),
															  'Destinación económica', (SELECT dispname FROM test_ladm_col_queries.fcm_destinacioneconomicatipo WHERE t_id = fcm_formulario_unico_cm.destinacion_economica),
															  'op_construccion', COALESCE(info_construccion.construccion, '[]')
															 )) ORDER BY op_predio.t_id) FILTER(WHERE op_predio.t_id IS NOT NULL) as predio
	 FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = op_predio.t_id
	 LEFT JOIN info_construccion ON op_predio.t_id = info_construccion.baunit
	 LEFT JOIN test_ladm_col_queries.fcm_formulario_unico_cm ON fcm_formulario_unico_cm.op_predio = op_predio.t_id
	 WHERE op_predio.t_id IN (SELECT * FROM predios_seleccionados)
		AND col_uebaunit.ue_op_terreno IS NOT NULL
		AND col_uebaunit.ue_op_construccion IS NULL
		AND col_uebaunit.ue_op_unidadconstruccion IS NULL
		GROUP BY col_uebaunit.ue_op_terreno
 ),
 t_extdireccion AS (
	SELECT extdireccion.op_terreno_ext_direccion_id,
		json_agg(
			json_build_object('id', extdireccion.t_id,
									 'attributes', json_build_object('Tipo dirección', (select dispname from test_ladm_col_queries.extdireccion_tipo_direccion where t_id = extdireccion.tipo_direccion),
																	 'Código postal', extdireccion.codigo_postal,
																	 'Dirección', concat(COALESCE((select dispname from test_ladm_col_queries.extdireccion_clase_via_principal where t_id = extdireccion.clase_via_principal) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_principal || ' ', ''),
																						 COALESCE(extdireccion.letra_via_principal || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_ciudad where t_id = extdireccion.sector_ciudad) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.letra_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.numero_predio || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_predio where t_id = extdireccion.sector_predio) || ' ', ''),
																						 COALESCE(extdireccion.complemento || ' ', ''),
																						 COALESCE(extdireccion.nombre_predio || ' ', '')
																						)))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM test_ladm_col_queries.extdireccion WHERE op_terreno_ext_direccion_id IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY extdireccion.op_terreno_ext_direccion_id
 ),
 info_terreno AS (
	SELECT op_terreno.t_id,
      json_build_object('id', op_terreno.t_id,
						'attributes', json_build_object(CONCAT('Área de terreno' , (SELECT * FROM unidad_area_terreno)), op_terreno.area_terreno,
														'extdireccion', COALESCE(t_extdireccion.extdireccion, '[]'),
														'op_predio', COALESCE(info_predio.predio, '[]')
													   )) as terreno
    FROM test_ladm_col_queries.op_terreno LEFT JOIN info_predio ON info_predio.ue_op_terreno = op_terreno.t_id
	LEFT JOIN t_extdireccion ON op_terreno.t_id = t_extdireccion.op_terreno_ext_direccion_id
	WHERE op_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY op_terreno.t_id
 )
 SELECT json_agg(info_terreno.terreno) AS terreno FROM info_terreno
