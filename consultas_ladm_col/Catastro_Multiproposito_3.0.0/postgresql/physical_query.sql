WITH
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 unidad_area_privada_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_privada_construida' LIMIT 1
 ),
 unidad_longitud_lindero AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_lindero' AND columnname = 'longitud' LIMIT 1
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
punto_lindero_externos_seleccionados AS (
	 SELECT DISTINCT col_masccl.ue_mas_lc_terreno, lc_puntolindero.t_id
	 FROM test_ladm_col_queries.lc_puntolindero LEFT JOIN test_ladm_col_queries.col_puntoccl ON lc_puntolindero.t_id = col_puntoccl.punto_lc_puntolindero
	 LEFT JOIN test_ladm_col_queries.lc_lindero ON col_puntoccl.ccl = lc_lindero.t_id
	 LEFT JOIN test_ladm_col_queries.col_masccl ON lc_lindero.t_id = col_masccl.ccl_mas
	 WHERE col_masccl.ue_mas_lc_terreno IN (SELECT * FROM terrenos_seleccionados)
	 ORDER BY col_masccl.ue_mas_lc_terreno, lc_puntolindero.t_id
),
punto_lindero_internos_seleccionados AS (
	SELECT DISTINCT col_menosccl.ue_menos_lc_terreno, lc_puntolindero.t_id
	FROM test_ladm_col_queries.lc_puntolindero LEFT JOIN test_ladm_col_queries.col_puntoccl ON lc_puntolindero.t_id = col_puntoccl.punto_lc_puntolindero
	LEFT JOIN test_ladm_col_queries.lc_lindero ON col_puntoccl.ccl = lc_lindero.t_id
	LEFT JOIN test_ladm_col_queries.col_menosccl ON lc_lindero.t_id = col_menosccl.ccl_menos
	WHERE col_menosccl.ue_menos_lc_terreno IN (SELECT * FROM terrenos_seleccionados)
  ORDER BY col_menosccl.ue_menos_lc_terreno, lc_puntolindero.t_id
),
 uc_fuente_espacial AS (
	SELECT col_uefuente.ue_lc_unidadconstruccion,
		json_agg(
				json_build_object('id', lc_fuenteespacial.t_id,
									   'attributes', json_build_object('Tipo de fuente espacial', (SELECT dispname FROM test_ladm_col_queries.col_fuenteespacialtipo WHERE t_id = lc_fuenteespacial.tipo),
																	   'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteespacial.estado_disponibilidad),
																	   'Tipo principal', (SELECT dispname FROM test_ladm_col_queries.ci_forma_presentacion_codigo WHERE t_id = lc_fuenteespacial.tipo_principal),
																	   'Fecha documento', lc_fuenteespacial.fecha_documento_fuente,
																	   'Archivo fuente', extarchivo.datos))
		ORDER BY lc_fuenteespacial.t_id) FILTER(WHERE col_uefuente.fuente_espacial IS NOT NULL) AS lc_fuenteespacial
	FROM test_ladm_col_queries.col_uefuente LEFT JOIN test_ladm_col_queries.lc_fuenteespacial ON col_uefuente.fuente_espacial = lc_fuenteespacial.t_id
    LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteespacial_ext_archivo_id = lc_fuenteespacial.t_id
	WHERE col_uefuente.ue_lc_unidadconstruccion IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	GROUP BY col_uefuente.ue_lc_unidadconstruccion
 ),
info_uc AS (
	 SELECT lc_unidadconstruccion.lc_construccion,
			json_agg(json_build_object('id', lc_unidadconstruccion.t_id,
							  'attributes', json_build_object('Número de pisos', lc_unidadconstruccion.total_pisos,
															  'Uso', (SELECT dispname FROM test_ladm_col_queries.lc_usouconstipo WHERE t_id = lc_unidadconstruccion.uso),
															  'Tipo construcción', (select dispname from test_ladm_col_queries.lc_ConstruccionTipo where t_id = lc_unidadconstruccion.tipo_construccion),
															  'Tipo unidad de construcción', (select dispname from test_ladm_col_queries.lc_UnidadConstruccionTipo where t_id = lc_unidadconstruccion.tipo_unidad_construccion),
															  CONCAT('Área privada construida' , (SELECT * FROM unidad_area_privada_construida_uc)), lc_unidadconstruccion.area_privada_construida,
															  CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), lc_unidadconstruccion.area_construida,
															  'lc_fuenteespacial', COALESCE(uc_fuente_espacial.lc_fuenteespacial, '[]')
															 )) ORDER BY lc_unidadconstruccion.t_id) FILTER(WHERE lc_unidadconstruccion.t_id IS NOT NULL) AS lc_unidadconstruccion
	 FROM test_ladm_col_queries.lc_unidadconstruccion LEFT JOIN uc_fuente_espacial ON lc_unidadconstruccion.t_id = uc_fuente_espacial.ue_lc_unidadconstruccion
	 WHERE lc_unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
     GROUP BY lc_unidadconstruccion.lc_construccion
 ),
 c_fuente_espacial AS (
	SELECT col_uefuente.ue_lc_construccion,
		json_agg(
				json_build_object('id', lc_fuenteespacial.t_id,
									   'attributes', json_build_object('Tipo de fuente espacial', (SELECT dispname FROM test_ladm_col_queries.col_fuenteespacialtipo WHERE t_id = lc_fuenteespacial.tipo),
																	   'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteespacial.estado_disponibilidad),
																	   'Tipo principal', (SELECT dispname FROM test_ladm_col_queries.ci_forma_presentacion_codigo WHERE t_id = lc_fuenteespacial.tipo_principal),
																	   'Fecha documento', lc_fuenteespacial.fecha_documento_fuente,
																	   'Archivo fuente', extarchivo.datos))
		ORDER BY lc_fuenteespacial.t_id) FILTER(WHERE col_uefuente.fuente_espacial IS NOT NULL) AS lc_fuenteespacial
	FROM test_ladm_col_queries.col_uefuente LEFT JOIN test_ladm_col_queries.lc_fuenteespacial ON col_uefuente.fuente_espacial = lc_fuenteespacial.t_id
	LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteespacial_ext_archivo_id = lc_fuenteespacial.t_id
	WHERE col_uefuente.ue_lc_construccion IN (SELECT * FROM construcciones_seleccionadas)
	GROUP BY col_uefuente.ue_lc_construccion
 ),
 info_construccion as (
  SELECT col_uebaunit.baunit,
		json_agg(json_build_object('id', lc_construccion.t_id,
						  'attributes', json_build_object('Área construcción', lc_construccion.area_construccion,
														  'Número de pisos', lc_construccion.numero_pisos,
														  'lc_unidadconstruccion', COALESCE(info_uc.lc_unidadconstruccion, '[]'),
														  'lc_fuenteespacial', COALESCE(c_fuente_espacial.lc_fuenteespacial, '[]')
														 )) ORDER BY lc_construccion.t_id) FILTER(WHERE lc_construccion.t_id IS NOT NULL) as lc_construccion
  FROM test_ladm_col_queries.lc_construccion LEFT JOIN c_fuente_espacial ON lc_construccion.t_id = c_fuente_espacial.ue_lc_construccion
  LEFT JOIN info_uc ON lc_construccion.t_id = info_uc.lc_construccion
  LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.ue_lc_construccion = lc_construccion.t_id
  WHERE lc_construccion.t_id IN (SELECT * FROM construcciones_seleccionadas)
  GROUP BY col_uebaunit.baunit
 ),
 info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			json_agg(json_build_object('id', lc_predio.t_id,
							  'attributes', json_build_object('Nombre', lc_predio.nombre,
															  'Id operación', lc_predio.id_operacion,
															  'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria),
															  'Número predial', lc_predio.numero_predial,
															  'Número predial anterior', lc_predio.numero_predial_anterior,
															  'lc_construccion', COALESCE(info_construccion.lc_construccion, '[]')
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) as lc_predio
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN info_construccion ON lc_predio.t_id = info_construccion.baunit
     LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = info_construccion.baunit
	 WHERE lc_predio.t_id = info_construccion.baunit
	 AND col_uebaunit.ue_lc_terreno IS NOT NULL
	 AND col_uebaunit.ue_lc_construccion IS NULL
	 AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_lc_terreno
 ),
 t_fuente_espacial AS (
	SELECT col_uefuente.ue_lc_terreno,
		json_agg(
				json_build_object('id', lc_fuenteespacial.t_id,
									   'attributes', json_build_object('Tipo de fuente espacial', (SELECT dispname FROM test_ladm_col_queries.col_fuenteespacialtipo WHERE t_id = lc_fuenteespacial.tipo),
																	   'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteespacial.estado_disponibilidad),
																	   'Tipo principal', (SELECT dispname FROM test_ladm_col_queries.ci_forma_presentacion_codigo WHERE t_id = lc_fuenteespacial.tipo_principal),
																	   'Fecha documento', lc_fuenteespacial.fecha_documento_fuente,
																	   'Archivo fuente', extarchivo.datos))
		ORDER BY lc_fuenteespacial.t_id) FILTER(WHERE col_uefuente.fuente_espacial IS NOT NULL) AS lc_fuenteespacial
	FROM test_ladm_col_queries.col_uefuente LEFT JOIN test_ladm_col_queries.lc_fuenteespacial ON col_uefuente.fuente_espacial = lc_fuenteespacial.t_id
    LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteespacial_ext_archivo_id = lc_fuenteespacial.t_id
	WHERE col_uefuente.ue_lc_terreno IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY col_uefuente.ue_lc_terreno
 ),
 info_linderos_externos AS (
	SELECT col_masccl.ue_mas_lc_terreno,
		json_agg(
				json_build_object('id', lc_lindero.t_id,
									   'attributes', json_build_object(CONCAT('Longitud' , (SELECT * FROM unidad_longitud_lindero)), lc_lindero.longitud))
		ORDER BY lc_lindero.t_id) FILTER(WHERE lc_lindero.t_id IS NOT NULL) AS lc_lindero
	FROM test_ladm_col_queries.lc_lindero LEFT JOIN test_ladm_col_queries.col_masccl ON lc_lindero.t_id = col_masccl.ccl_mas
    WHERE col_masccl.ue_mas_lc_terreno IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY col_masccl.ue_mas_lc_terreno
 ),
 info_linderos_internos AS (
	SELECT col_menosccl.ue_menos_lc_terreno,
		json_agg(
				json_build_object('id', lc_lindero.t_id,
									   'attributes', json_build_object(CONCAT('Longitud' , (SELECT * FROM unidad_longitud_lindero)), lc_lindero.longitud))
		ORDER BY lc_lindero.t_id) FILTER(WHERE lc_lindero.t_id IS NOT NULL) AS lc_lindero
	FROM test_ladm_col_queries.lc_lindero LEFT JOIN test_ladm_col_queries.col_menosccl ON lc_lindero.t_id = col_menosccl.ccl_menos
	WHERE col_menosccl.ue_menos_lc_terreno IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY col_menosccl.ue_menos_lc_terreno
 ),
info_punto_lindero_externos AS (
	SELECT punto_lindero_externos_seleccionados.ue_mas_lc_terreno,
	 		json_agg(
				json_build_object('id', lc_puntolindero.t_id,
									   'attributes', json_build_object('Nombre', lc_puntolindero.id_punto_lindero,
																	   'Coordenadas', concat(st_x(lc_puntolindero.geometria),
																					 ' ', st_y(lc_puntolindero.geometria),
																					 CASE WHEN st_z(lc_puntolindero.geometria) IS NOT NULL THEN concat(' ', st_z(lc_puntolindero.geometria)) END))
			) ORDER BY lc_puntolindero.t_id) FILTER(WHERE lc_puntolindero.t_id IS NOT NULL) AS lc_puntolindero
	FROM test_ladm_col_queries.lc_puntolindero LEFT JOIN punto_lindero_externos_seleccionados ON lc_puntolindero.t_id = punto_lindero_externos_seleccionados.t_id
	WHERE punto_lindero_externos_seleccionados.ue_mas_lc_terreno IS NOT NULL
	GROUP BY punto_lindero_externos_seleccionados.ue_mas_lc_terreno
 ),
 info_punto_lindero_internos AS (
	 SELECT punto_lindero_internos_seleccionados.ue_menos_lc_terreno,
	 		json_agg(
				json_build_object('id', lc_puntolindero.t_id,
									   'attributes', json_build_object('Nombre', lc_puntolindero.id_punto_lindero,
																	   'Coordenadas', concat(st_x(lc_puntolindero.geometria),
																					 ' ', st_y(lc_puntolindero.geometria),
																					 CASE WHEN st_z(lc_puntolindero.geometria) IS NOT NULL THEN concat(' ', st_z(lc_puntolindero.geometria)) END))
			) ORDER BY lc_puntolindero.t_id) FILTER(WHERE lc_puntolindero.t_id IS NOT NULL) AS lc_puntolindero
	 FROM test_ladm_col_queries.lc_puntolindero LEFT JOIN punto_lindero_internos_seleccionados ON lc_puntolindero.t_id = punto_lindero_internos_seleccionados.t_id
     WHERE punto_lindero_internos_seleccionados.ue_menos_lc_terreno IS NOT NULL
	 GROUP BY punto_lindero_internos_seleccionados.ue_menos_lc_terreno
 ),
info_puntolevantamiento AS (
	SELECT ue_lc_terreno,
            json_agg(
                    json_build_object('id', puntoslevantamiento_seleccionados.t_id_puntolevantamiento,
                                           'attributes', json_build_object('Coordenadas', concat(st_x(puntoslevantamiento_seleccionados.geometria),
                                                                                     ' ', st_y(puntoslevantamiento_seleccionados.geometria),
                                                                                     CASE WHEN st_z(puntoslevantamiento_seleccionados.geometria) IS NOT NULL THEN concat(' ', st_z(puntoslevantamiento_seleccionados.geometria)) END)
                                                                          ))
            ORDER BY puntoslevantamiento_seleccionados.t_id_puntolevantamiento) FILTER(WHERE puntoslevantamiento_seleccionados.t_id_puntolevantamiento IS NOT NULL) AS lc_puntolevantamiento
    FROM
    (
        SELECT lc_puntolevantamiento.t_id AS t_id_puntolevantamiento, lc_puntolevantamiento.geometria, lc_terreno.t_id AS ue_lc_terreno
        FROM test_ladm_col_queries.lc_terreno, test_ladm_col_queries.lc_puntolevantamiento
        WHERE ST_Intersects(lc_terreno.geometria, lc_puntolevantamiento.geometria) AND lc_terreno.t_id IN (SELECT * from terrenos_seleccionados)
    ) AS puntoslevantamiento_seleccionados
    GROUP BY ue_lc_terreno
),
 info_terreno AS (
	SELECT lc_terreno.t_id,
      json_build_object('id', lc_terreno.t_id,
						'attributes', json_build_object(CONCAT('Área' , (SELECT * FROM unidad_area_terreno)), lc_terreno.area_terreno,
														'lc_predio', COALESCE(info_predio.lc_predio, '[]'),
														'lc_lindero externos', COALESCE(info_linderos_externos.lc_lindero, '[]'),
														'lc_puntolindero externos', COALESCE(info_punto_lindero_externos.lc_puntolindero, '[]'),
														'lc_lindero internos', COALESCE(info_linderos_internos.lc_lindero, '[]'),
														'lc_puntolindero internos', COALESCE(info_punto_lindero_internos.lc_puntolindero, '[]'),
														'lc_puntolevantamiento', COALESCE(info_puntolevantamiento.lc_puntolevantamiento, '[]'),
														'lc_fuenteespacial', COALESCE(t_fuente_espacial.lc_fuenteespacial, '[]')
													   )) as lc_terreno
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN info_predio ON info_predio.ue_lc_terreno = lc_terreno.t_id
	LEFT JOIN t_fuente_espacial ON lc_terreno.t_id = t_fuente_espacial.ue_lc_terreno
	LEFT JOIN info_linderos_externos ON lc_terreno.t_id = info_linderos_externos.ue_mas_lc_terreno
	LEFT JOIN info_linderos_internos ON lc_terreno.t_id = info_linderos_internos.ue_menos_lc_terreno
    LEFT JOIN info_punto_lindero_externos ON lc_terreno.t_id = info_punto_lindero_externos.ue_mas_lc_terreno
	LEFT JOIN info_punto_lindero_internos ON lc_terreno.t_id = info_punto_lindero_internos.ue_menos_lc_terreno
    LEFT JOIN info_puntolevantamiento ON lc_terreno.t_id = info_puntolevantamiento.ue_lc_terreno
	WHERE lc_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
  ORDER BY lc_terreno.t_id
 )
 SELECT json_agg(info_terreno.lc_terreno) AS lc_terreno FROM info_terreno
