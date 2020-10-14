WITH
 _unidad_avaluo_predio AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename LIKE 'lc_predio' AND columnname LIKE 'avaluo_catastral' LIMIT 1
 ),
 _unidad_avaluo_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'avaluo_terreno' LIMIT 1
 ),
 _unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 _unidad_avaluo_construccion AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_construccion' AND columnname = 'avaluo_construccion' LIMIT 1
 ),
 _unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 _unidad_avaluo_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'avaluo_unidad_construccion' LIMIT 1
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
 _construcciones_seleccionadas AS (
	 SELECT ue_lc_construccion FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.baunit IN (SELECT _predios_seleccionados.t_id FROM _predios_seleccionados WHERE _predios_seleccionados.t_id IS NOT NULL) AND ue_lc_construccion IS NOT NULL
 ),
 _unidadesconstruccion_seleccionadas AS (
	 SELECT lc_unidadconstruccion.t_id FROM test_ladm_col_queries.lc_unidadconstruccion WHERE lc_unidadconstruccion.lc_construccion IN (SELECT ue_lc_construccion FROM _construcciones_seleccionadas)
 ),
 _info_uc AS (
	 SELECT lc_unidadconstruccion.lc_construccion,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_unidadconstruccion.t_id,
							  'attributes', JSON_BUILD_OBJECT(CONCAT('Avalúo' , (SELECT * FROM _unidad_avaluo_uc)), lc_unidadconstruccion.avaluo_unidad_construccion
															  , CONCAT('Área construida' , (SELECT * FROM _unidad_area_construida_uc)), lc_unidadconstruccion.area_construida
															  , CONCAT('Área privada construida' , (SELECT * FROM _unidad_area_construida_uc)), lc_unidadconstruccion.area_privada_construida
															  , 'Número de pisos', lc_unidadconstruccion.total_pisos
															  , 'Ubicación en el piso', lc_unidadconstruccion.planta_ubicacion
															  , 'Uso',  (SELECT dispname FROM test_ladm_col_queries.lc_usouconstipo WHERE t_id = lc_unidadconstruccion.uso)
															  , 'Año construcción',  lc_unidadconstruccion.anio_construccion
															 )) ORDER BY lc_unidadconstruccion.t_id) FILTER(WHERE lc_unidadconstruccion.t_id IS NOT NULL)  AS _unidadconstruccion_
	 FROM test_ladm_col_queries.lc_unidadconstruccion
	 WHERE lc_unidadconstruccion.t_id IN (SELECT * FROM _unidadesconstruccion_seleccionadas)
	 GROUP BY lc_unidadconstruccion.lc_construccion
 ),
 _info_construccion AS (
	 SELECT col_uebaunit.baunit,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_construccion.t_id,
							  'attributes', JSON_BUILD_OBJECT(CONCAT('Avalúo' , (SELECT * FROM _unidad_avaluo_construccion)), lc_construccion.avaluo_construccion,
															  'Área construcción', lc_construccion.area_construccion,
															  'lc_unidadconstruccion', COALESCE(_info_uc._unidadconstruccion_, '[]')
															 )) ORDER BY lc_construccion.t_id) FILTER(WHERE lc_construccion.t_id IS NOT NULL) AS _construccion_
	 FROM test_ladm_col_queries.lc_construccion
	 LEFT JOIN _info_uc ON lc_construccion.t_id = _info_uc.lc_construccion
     LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.ue_lc_construccion = lc_construccion.t_id
	 WHERE lc_construccion.t_id IN (SELECT * FROM _construcciones_seleccionadas)
	 GROUP BY col_uebaunit.baunit
 ),
_info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_predio.t_id,
							  'attributes', JSON_BUILD_OBJECT('Nombre', lc_predio.nombre,
															  'Departamento', lc_predio.departamento,
															  'Municipio', lc_predio.municipio,
															  'Id operación', lc_predio.id_operacion,
															  'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria),
															  'Número predial', lc_predio.numero_predial,
															  'Número predial anterior', lc_predio.numero_predial_anterior,
															  CONCAT('Avalúo predio' , (SELECT * FROM _unidad_avaluo_predio)), lc_predio.avaluo_catastral,
															  'Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_prediotipo WHERE t_id = lc_predio.tipo),
															  'lc_construccion', COALESCE(_info_construccion._construccion_, '[]')
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) AS _predio_
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = lc_predio.t_id
	 LEFT JOIN _info_construccion ON lc_predio.t_id = _info_construccion.baunit
	 WHERE lc_predio.t_id IN (SELECT * FROM _predios_seleccionados)
	 AND col_uebaunit.ue_lc_terreno IS NOT NULL
	 AND col_uebaunit.ue_lc_construccion IS NULL
	 AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_lc_terreno
 ),
 _info_terreno AS (
	SELECT lc_terreno.t_id,
      JSON_BUILD_OBJECT('id', lc_terreno.t_id,
						'attributes', JSON_BUILD_OBJECT(CONCAT('Avalúo', (SELECT * FROM _unidad_avaluo_terreno)), lc_terreno.avaluo_terreno
													    , CONCAT('Área' , (SELECT * FROM _unidad_area_terreno)), lc_terreno.area_terreno
														, 'lc_predio', COALESCE(_info_predio._predio_, '[]')
													   )) AS _terreno_
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN _info_predio ON _info_predio.ue_lc_terreno = lc_terreno.t_id
	WHERE lc_terreno.t_id IN (SELECT * FROM _terrenos_seleccionados)
	ORDER BY lc_terreno.t_id
 )
SELECT JSON_BUILD_OBJECT('lc_terreno', COALESCE(JSON_AGG(_info_terreno._terreno_), '[]')) FROM _info_terreno