WITH
 _unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 _terrenos_seleccionados AS (
	SELECT 897 AS ue_lc_terreno WHERE '897' <> 'NULL'
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial_anterior = 'NULL' END
 ),
 _predios_seleccionados AS (
	SELECT col_uebaunit.baunit AS t_id FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.ue_lc_terreno = 897 AND '897' <> 'NULL'
		UNION
	SELECT t_id FROM test_ladm_col_queries.lc_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.lc_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.lc_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial_anterior = 'NULL' END
 ),
 _info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_predio.t_id,
							  'attributes', JSON_BUILD_OBJECT('Nombre', lc_predio.nombre
															  , 'Departamento', lc_predio.departamento
															  , 'Municipio', lc_predio.municipio
															  , 'Id operación', lc_predio.id_operacion
															  , 'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria)
															  , 'Número predial', lc_predio.numero_predial
															  , 'Número predial anterior', lc_predio.numero_predial_anterior
															  , 'Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_prediotipo WHERE t_id = lc_predio.tipo)
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) AS _predio_
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = lc_predio.t_id
	 WHERE lc_predio.t_id IN (SELECT * FROM _predios_seleccionados)
	 AND col_uebaunit.ue_lc_terreno IS NOT NULL
	 AND col_uebaunit.ue_lc_construccion IS NULL
	 AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_lc_terreno
 ),
 _info_terreno AS (
	SELECT lc_terreno.t_id,
      JSON_BUILD_OBJECT('id', lc_terreno.t_id,
						'attributes', JSON_BUILD_OBJECT(CONCAT('Área' , (SELECT * FROM _unidad_area_terreno)), lc_terreno.area_terreno,
														'lc_predio', COALESCE(_info_predio._predio_, '[]')
													   )) AS _terreno_
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN _info_predio ON _info_predio.ue_lc_terreno = lc_terreno.t_id
	WHERE lc_terreno.t_id IN (SELECT * FROM _terrenos_seleccionados)
	ORDER BY lc_terreno.t_id
 )
 SELECT JSON_BUILD_OBJECT('lc_terreno', JSON_AGG(_info_terreno._terreno_)) FROM _info_terreno

