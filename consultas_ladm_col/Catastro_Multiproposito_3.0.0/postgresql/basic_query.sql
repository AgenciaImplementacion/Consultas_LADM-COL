WITH
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 897 AS ue_lc_terreno WHERE '897' <> 'NULL'
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT col_uebaunit.baunit as t_id FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.ue_lc_terreno = 897 AND '897' <> 'NULL'
		UNION
	SELECT t_id FROM test_ladm_col_queries.lc_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.lc_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.lc_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial_anterior = 'NULL' END
 ),
  construcciones_seleccionadas AS (
	 SELECT ue_lc_construccion FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.baunit IN (SELECT predios_seleccionados.t_id FROM predios_seleccionados WHERE predios_seleccionados.t_id IS NOT NULL) AND ue_lc_construccion IS NOT NULL
 ),
 unidadesconstruccion_seleccionadas AS (
	 SELECT lc_unidadconstruccion.t_id FROM test_ladm_col_queries.lc_unidadconstruccion WHERE lc_unidadconstruccion.lc_construccion IN (SELECT ue_lc_construccion FROM construcciones_seleccionadas)
 ),
 uc_extdireccion AS (
	SELECT extdireccion.lc_unidadconstruccion_ext_direccion_id,
		json_agg(
			json_build_object('id', extdireccion.t_id,
									 'attributes', json_build_object('Tipo dirección', (select dispname from test_ladm_col_queries.extdireccion_tipo_direccion where t_id = extdireccion.tipo_direccion),
																	 'Código postal', extdireccion.codigo_postal,
																	 'Dirección', trim(concat(COALESCE((select dispname from test_ladm_col_queries.extdireccion_clase_via_principal where t_id = extdireccion.clase_via_principal) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_principal || ' ', ''),
																						 COALESCE(extdireccion.letra_via_principal || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_ciudad where t_id = extdireccion.sector_ciudad) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.letra_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.numero_predio || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_predio where t_id = extdireccion.sector_predio) || ' ', ''),
																						 COALESCE(extdireccion.complemento || ' ', ''),
																						 COALESCE(extdireccion.nombre_predio || ' ', '')
																						))))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM test_ladm_col_queries.extdireccion WHERE lc_unidadconstruccion_ext_direccion_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	GROUP BY extdireccion.lc_unidadconstruccion_ext_direccion_id
 ),
 info_uc AS (
	 SELECT lc_unidadconstruccion.lc_construccion,
			json_agg(json_build_object('id', lc_unidadconstruccion.t_id,
							  'attributes', json_build_object('Número de pisos', lc_unidadconstruccion.total_pisos,
															  'Número de habitaciones', lc_unidadconstruccion.total_habitaciones,
															  'Número de baños', lc_unidadconstruccion.total_banios,
															  'Número de locales', lc_unidadconstruccion.total_locales,
															  'Tipo construcción', (select dispname from test_ladm_col_queries.lc_ConstruccionTipo where t_id = lc_unidadconstruccion.tipo_construccion),
															  'Tipo unidad de construcción', (select dispname from test_ladm_col_queries.lc_UnidadConstruccionTipo where t_id = lc_unidadconstruccion.tipo_unidad_construccion),
															  'Tipo de planta', (select dispname from test_ladm_col_queries.lc_ConstruccionPlantaTipo where t_id = lc_unidadconstruccion.tipo_planta),
															  'Tipo dominio', (select dispname from test_ladm_col_queries.lc_DominioConstruccionTipo where t_id = lc_unidadconstruccion.tipo_dominio),
															  'Ubicación en el piso', lc_unidadconstruccion.planta_ubicacion,
															  CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), lc_unidadconstruccion.area_construida,
															  'Uso', (SELECT dispname FROM test_ladm_col_queries.lc_usouconstipo WHERE t_id = lc_unidadconstruccion.uso),
															  'extdireccion', COALESCE(uc_extdireccion.extdireccion, '[]')
															 )) ORDER BY lc_unidadconstruccion.t_id) FILTER(WHERE lc_unidadconstruccion.t_id IS NOT NULL)  as unidadconstruccion
	 FROM test_ladm_col_queries.lc_unidadconstruccion
	 LEFT JOIN uc_extdireccion ON lc_unidadconstruccion.t_id = uc_extdireccion.lc_unidadconstruccion_ext_direccion_id
	 WHERE lc_unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	 GROUP BY lc_unidadconstruccion.lc_construccion
 ),
 c_extdireccion AS (
	SELECT extdireccion.lc_construccion_ext_direccion_id,
		json_agg(
			json_build_object('id', extdireccion.t_id,
									 'attributes', json_build_object('Tipo dirección', (select dispname from test_ladm_col_queries.extdireccion_tipo_direccion where t_id = extdireccion.tipo_direccion),
																	 'Código postal', extdireccion.codigo_postal,
																	 'Dirección', trim(concat(COALESCE((select dispname from test_ladm_col_queries.extdireccion_clase_via_principal where t_id = extdireccion.clase_via_principal) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_principal || ' ', ''),
																						 COALESCE(extdireccion.letra_via_principal || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_ciudad where t_id = extdireccion.sector_ciudad) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.letra_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.numero_predio || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_predio where t_id = extdireccion.sector_predio) || ' ', ''),
																						 COALESCE(extdireccion.complemento || ' ', ''),
																						 COALESCE(extdireccion.nombre_predio || ' ', '')
																						))))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM test_ladm_col_queries.extdireccion WHERE lc_construccion_ext_direccion_id IN (SELECT * FROM construcciones_seleccionadas)
	GROUP BY extdireccion.lc_construccion_ext_direccion_id
 ),
 info_construccion as (
	 SELECT col_uebaunit.baunit,
			json_agg(json_build_object('id', lc_construccion.t_id,
							  'attributes', json_build_object('Área', lc_construccion.area_construccion,
															  'extdireccion', COALESCE(c_extdireccion.extdireccion, '[]'),
															  'lc_unidadconstruccion', COALESCE(info_uc.unidadconstruccion, '[]')
															 )) ORDER BY lc_construccion.t_id) FILTER(WHERE lc_construccion.t_id IS NOT NULL) as construccion
	 FROM test_ladm_col_queries.lc_construccion LEFT JOIN c_extdireccion ON lc_construccion.t_id = c_extdireccion.lc_construccion_ext_direccion_id
	 LEFT JOIN info_uc ON lc_construccion.t_id = info_uc.lc_construccion
     LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.ue_lc_construccion = lc_construccion.t_id
	 WHERE lc_construccion.t_id IN (SELECT * FROM construcciones_seleccionadas)
	 GROUP BY col_uebaunit.baunit
 ),
 info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			json_agg(json_build_object('id', lc_predio.t_id,
							  'attributes', json_build_object('Nombre', lc_predio.nombre,
															  'Departamento', lc_predio.departamento,
															  'Municipio', lc_predio.municipio,
															  'Id operación', lc_predio.id_operacion,
															  'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria),
															  'Número predial', lc_predio.numero_predial,
															  'Número predial anterior', lc_predio.numero_predial_anterior,
															  'Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_prediotipo WHERE t_id = lc_predio.tipo),
															  'lc_construccion', COALESCE(info_construccion.construccion, '[]')
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) as predio
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = lc_predio.t_id
	 LEFT JOIN info_construccion ON lc_predio.t_id = info_construccion.baunit
	 WHERE lc_predio.t_id IN (SELECT * FROM predios_seleccionados)
		AND col_uebaunit.ue_lc_terreno IS NOT NULL
		AND col_uebaunit.ue_lc_construccion IS NULL
		AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
		GROUP BY col_uebaunit.ue_lc_terreno
 ),
 t_extdireccion AS (
	SELECT extdireccion.lc_terreno_ext_direccion_id,
		json_agg(
			json_build_object('id', extdireccion.t_id,
									 'attributes', json_build_object('Tipo dirección', (select dispname from test_ladm_col_queries.extdireccion_tipo_direccion where t_id = extdireccion.tipo_direccion),
																	 'Código postal', extdireccion.codigo_postal,
																	 'Dirección', trim(concat(COALESCE((select dispname from test_ladm_col_queries.extdireccion_clase_via_principal where t_id = extdireccion.clase_via_principal) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_principal || ' ', ''),
																						 COALESCE(extdireccion.letra_via_principal || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_ciudad where t_id = extdireccion.sector_ciudad) || ' ', ''),
																						 COALESCE(extdireccion.valor_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.letra_via_generadora || ' ', ''),
																						 COALESCE(extdireccion.numero_predio || ' ', ''),
																						 COALESCE((select dispname from test_ladm_col_queries.extdireccion_sector_predio where t_id = extdireccion.sector_predio) || ' ', ''),
																						 COALESCE(extdireccion.complemento || ' ', ''),
																						 COALESCE(extdireccion.nombre_predio || ' ', '')
																						))))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM test_ladm_col_queries.extdireccion WHERE lc_terreno_ext_direccion_id IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY extdireccion.lc_terreno_ext_direccion_id
 ),
 info_terreno AS (
	SELECT lc_terreno.t_id,
      json_build_object('id', lc_terreno.t_id,
						'attributes', json_build_object(CONCAT('Área' , (SELECT * FROM unidad_area_terreno)), lc_terreno.area_terreno,
														'extdireccion', COALESCE(t_extdireccion.extdireccion, '[]'),
														'lc_predio', COALESCE(info_predio.predio, '[]')
													   )) as terreno
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN info_predio ON info_predio.ue_lc_terreno = lc_terreno.t_id
	LEFT JOIN t_extdireccion ON lc_terreno.t_id = t_extdireccion.lc_terreno_ext_direccion_id
	WHERE lc_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY lc_terreno.t_id
 )
 SELECT json_agg(info_terreno.terreno) AS lc_terreno FROM info_terreno
