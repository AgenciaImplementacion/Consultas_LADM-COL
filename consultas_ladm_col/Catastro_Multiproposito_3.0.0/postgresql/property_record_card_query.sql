WITH
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'op_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 1416 AS ue_op_terreno WHERE '1416' <> 'NULL'
		UNION
	SELECT col_uebaunit.ue_op_terreno FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON op_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_op_terreno FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON op_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial = 'NULL' END
		UNION
	SELECT col_uebaunit.ue_op_terreno FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON op_predio.t_id = col_uebaunit.baunit  WHERE col_uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT col_uebaunit.baunit as t_id FROM test_ladm_col_queries.col_uebaunit WHERE col_uebaunit.ue_op_terreno = 1416 AND '1416' <> 'NULL'
		UNION
	SELECT t_id FROM test_ladm_col_queries.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial_anterior = 'NULL' END
 ),
 info_predio AS (
	 SELECT col_uebaunit.ue_op_terreno,
			json_agg(json_build_object('id', op_predio.t_id,
							  'attributes', json_build_object('Nombre', op_predio.nombre
															  , 'Departamento', op_predio.departamento
															  , 'Municipio', op_predio.municipio
															  , 'NUPRE', op_predio.nupre
															  , 'FMI', (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria)
															  , 'Número predial', op_predio.numero_predial
															  , 'Número predial anterior', op_predio.numero_predial_anterior
															  , 'Tipo', (SELECT dispname FROM test_ladm_col_queries.op_prediotipo WHERE t_id = op_predio.tipo)
															 )) ORDER BY op_predio.t_id) FILTER(WHERE op_predio.t_id IS NOT NULL) as op_predio
	 FROM test_ladm_col_queries.op_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = op_predio.t_id
	 WHERE op_predio.t_id IN (SELECT * FROM predios_seleccionados)
	 AND col_uebaunit.ue_op_terreno IS NOT NULL
	 AND col_uebaunit.ue_op_construccion IS NULL
	 AND col_uebaunit.ue_op_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_op_terreno
 ),
 info_terreno AS (
	SELECT op_terreno.t_id,
      json_build_object('id', op_terreno.t_id,
						'attributes', json_build_object(CONCAT('Área' , (SELECT * FROM unidad_area_terreno)), op_terreno.area_terreno,
														'op_predio', COALESCE(info_predio.op_predio, '[]')
													   )) as op_terreno
    FROM test_ladm_col_queries.op_terreno LEFT JOIN info_predio ON info_predio.ue_op_terreno = op_terreno.t_id
	WHERE op_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY op_terreno.t_id
 )
 SELECT json_agg(info_terreno.op_terreno) AS op_terreno FROM info_terreno
