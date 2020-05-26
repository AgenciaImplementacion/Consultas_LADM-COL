WITH
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
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
 info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			json_agg(json_build_object('id', lc_predio.t_id,
							  'attributes', json_build_object('Nombre', lc_predio.nombre
															  , 'Departamento', lc_predio.departamento
															  , 'Municipio', lc_predio.municipio
															  , 'Id operación', lc_predio.id_operacion
															  , 'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria)
															  , 'Número predial', lc_predio.numero_predial
															  , 'Número predial anterior', lc_predio.numero_predial_anterior
															  , 'Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_prediotipo WHERE t_id = lc_predio.tipo)
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) as lc_predio
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = lc_predio.t_id
	 WHERE lc_predio.t_id IN (SELECT * FROM predios_seleccionados)
	 AND col_uebaunit.ue_lc_terreno IS NOT NULL
	 AND col_uebaunit.ue_lc_construccion IS NULL
	 AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_lc_terreno
 ),
 info_terreno AS (
	SELECT lc_terreno.t_id,
      json_build_object('id', lc_terreno.t_id,
						'attributes', json_build_object(CONCAT('Área' , (SELECT * FROM unidad_area_terreno)), lc_terreno.area_terreno,
														'lc_predio', COALESCE(info_predio.lc_predio, '[]')
													   )) as lc_terreno
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN info_predio ON info_predio.ue_lc_terreno = lc_terreno.t_id
	WHERE lc_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY lc_terreno.t_id
 )
 SELECT json_agg(info_terreno.lc_terreno) AS lc_terreno FROM info_terreno
