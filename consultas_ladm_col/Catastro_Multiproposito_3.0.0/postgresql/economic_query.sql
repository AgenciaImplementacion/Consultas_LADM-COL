WITH
 unidad_avaluo_predio AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename LIKE 'lc_predio' AND columnname LIKE 'avaluo_catastral' LIMIT 1
 ),
 unidad_avaluo_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'avaluo_terreno' LIMIT 1
 ),
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 unidad_avaluo_construccion AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_construccion' AND columnname = 'avaluo_construccion' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 unidad_avaluo_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'avaluo_unidad_construccion' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 1416 AS ue_lc_terreno WHERE '1416' <> 'NULL'
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_lc_terreno FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON lc_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_lc_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE lc_predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT col_uebaunit.baunit as t_id FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.ue_lc_terreno = 1416 AND '1416' <> 'NULL'
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
 info_uc AS (
	 SELECT lc_unidadconstruccion.lc_construccion,
			json_agg(json_build_object('id', lc_unidadconstruccion.t_id,
							  'attributes', json_build_object(CONCAT('Avalúo' , (SELECT * FROM unidad_avaluo_uc)), lc_unidadconstruccion.avaluo_unidad_construccion
															  , CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), lc_unidadconstruccion.area_construida
															  , CONCAT('Área privada construida' , (SELECT * FROM unidad_area_construida_uc)), lc_unidadconstruccion.area_privada_construida
															  , 'Número de pisos', lc_unidadconstruccion.total_pisos
															  , 'Ubicación en el piso', lc_unidadconstruccion.planta_ubicacion
															  , 'Uso',  (SELECT dispname FROM test_ladm_col_queries.lc_usouconstipo WHERE t_id = lc_unidadconstruccion.uso)
															  , 'Año construcción',  lc_unidadconstruccion.anio_construccion
															 )) ORDER BY lc_unidadconstruccion.t_id) FILTER(WHERE lc_unidadconstruccion.t_id IS NOT NULL)  as lc_unidadconstruccion
	 FROM test_ladm_col_queries.lc_unidadconstruccion
	 WHERE lc_unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	 GROUP BY lc_unidadconstruccion.lc_construccion
 ),
 info_construccion as (
	 SELECT col_uebaunit.baunit,
			json_agg(json_build_object('id', lc_construccion.t_id,
							  'attributes', json_build_object(CONCAT('Avalúo' , (SELECT * FROM unidad_avaluo_construccion)), lc_construccion.avaluo_construccion,
															  'Área construcción', lc_construccion.area_construccion,
															  'lc_unidadconstruccion', COALESCE(info_uc.lc_unidadconstruccion, '[]')
															 )) ORDER BY lc_construccion.t_id) FILTER(WHERE lc_construccion.t_id IS NOT NULL) as lc_construccion
	 FROM test_ladm_col_queries.lc_construccion
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
															  CONCAT('Avalúo predio' , (select * from unidad_avaluo_predio)), lc_predio.avaluo_catastral,
															  'Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_prediotipo WHERE t_id = lc_predio.tipo),
															  'lc_construccion', COALESCE(info_construccion.lc_construccion, '[]')
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) as lc_predio
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = lc_predio.t_id
	 LEFT JOIN info_construccion ON lc_predio.t_id = info_construccion.baunit
	 WHERE lc_predio.t_id IN (SELECT * FROM predios_seleccionados)
	 AND col_uebaunit.ue_lc_terreno IS NOT NULL
	 AND col_uebaunit.ue_lc_construccion IS NULL
	 AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_lc_terreno
 ),
 info_terreno AS (
	SELECT lc_terreno.t_id,
      json_build_object('id', lc_terreno.t_id,
						'attributes', json_build_object(CONCAT('Avalúo', (SELECT * FROM unidad_avaluo_terreno)), lc_terreno.Avaluo_Terreno
													    , CONCAT('Área' , (SELECT * FROM unidad_area_terreno)), lc_terreno.area_terreno
														, 'lc_predio', COALESCE(info_predio.lc_predio, '[]')
													   )) as lc_terreno
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN info_predio ON info_predio.ue_lc_terreno = lc_terreno.t_id
	WHERE lc_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY lc_terreno.t_id
 )
SELECT json_agg(info_terreno.lc_terreno) AS lc_terreno FROM info_terreno
