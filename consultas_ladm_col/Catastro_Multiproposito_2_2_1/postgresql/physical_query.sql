WITH
 unidad_area_calculada_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'terreno' AND columnname = 'area_calculada' LIMIT 1
 ),
 unidad_area_registral_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'terreno' AND columnname = 'area_registral' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 unidad_area_privada_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'unidadconstruccion' AND columnname = 'area_privada_construida' LIMIT 1
 ),
 unidad_longitud_lindero AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lindero' AND columnname = 'longitud' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 764 AS ue_terreno WHERE '764' <> 'NULL'
		UNION
	SELECT uebaunit.ue_terreno FROM test_ladm_col_queries.predio LEFT JOIN test_ladm_col_queries.uebaunit ON predio.t_id = uebaunit.baunit_predio  WHERE uebaunit.ue_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.fmi = 'NULL' END
		UNION
	SELECT uebaunit.ue_terreno FROM test_ladm_col_queries.predio LEFT JOIN test_ladm_col_queries.uebaunit ON predio.t_id = uebaunit.baunit_predio  WHERE uebaunit.ue_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial = 'NULL' END
		UNION
	SELECT uebaunit.ue_terreno FROM test_ladm_col_queries.predio LEFT JOIN test_ladm_col_queries.uebaunit ON predio.t_id = uebaunit.baunit_predio  WHERE uebaunit.ue_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT uebaunit.baunit_predio as t_id FROM test_ladm_col_queries.uebaunit WHERE uebaunit.ue_terreno = 764 AND '764' <> 'NULL'
		UNION
	SELECT t_id FROM test_ladm_col_queries.predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.fmi = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM test_ladm_col_queries.predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial_anterior = 'NULL' END
 ),
 construcciones_seleccionadas AS (
	 SELECT ue_construccion FROM test_ladm_col_queries.uebaunit WHERE uebaunit.baunit_predio IN (SELECT predios_seleccionados.t_id FROM predios_seleccionados WHERE predios_seleccionados.t_id IS NOT NULL) AND ue_construccion IS NOT NULL
 ),
 unidadesconstruccion_seleccionadas AS (
	 SELECT unidadconstruccion.t_id FROM test_ladm_col_queries.unidadconstruccion WHERE unidadconstruccion.construccion IN (SELECT ue_construccion FROM construcciones_seleccionadas)
 ),
punto_lindero_externos_seleccionados AS (
	 SELECT DISTINCT masccl.uep_terreno, puntolindero.t_id
	 FROM test_ladm_col_queries.puntolindero LEFT JOIN test_ladm_col_queries.puntoccl ON puntolindero.t_id = puntoccl.punto_puntolindero
	 LEFT JOIN test_ladm_col_queries.lindero ON puntoccl.ccl_lindero = lindero.t_id
	 LEFT JOIN test_ladm_col_queries.masccl ON lindero.t_id = masccl.cclp_lindero
	 WHERE masccl.uep_terreno IN (SELECT * FROM terrenos_seleccionados)
	 ORDER BY masccl.uep_terreno, puntolindero.t_id
),
punto_lindero_internos_seleccionados AS (
	SELECT DISTINCT menos.eu_terreno, puntolindero.t_id
	FROM test_ladm_col_queries.puntolindero LEFT JOIN test_ladm_col_queries.puntoccl ON puntolindero.t_id = puntoccl.punto_puntolindero
	LEFT JOIN test_ladm_col_queries.lindero ON puntoccl.ccl_lindero = lindero.t_id
	LEFT JOIN test_ladm_col_queries.menos ON lindero.t_id = menos.ccl_lindero
	WHERE menos.eu_terreno IN (SELECT * FROM terrenos_seleccionados)
  ORDER BY menos.eu_terreno, puntolindero.t_id
),
 uc_fuente_espacial AS (
	SELECT uefuente.ue_unidadconstruccion,
		json_agg(
				json_build_object('id', col_fuenteespacial.t_id,
									   'attributes', json_build_object('Tipo de fuente espacial', col_fuenteespacial.Tipo,
																	   'Estado disponibilidad', col_fuenteespacial.estado_disponibilidad,
																	   'Tipo principal', col_fuenteespacial.tipo_principal,
																	   'Fecha de entrega', col_fuenteespacial.fecha_entrega,
																	   'Fecha de grabación', col_fuenteespacial.fecha_grabacion,
																	   'Enlace fuente espacial', extarchivo.datos))
		ORDER BY col_fuenteespacial.t_id) FILTER(WHERE ueFuente.pfuente IS NOT NULL) AS col_fuenteespacial
	FROM test_ladm_col_queries.uefuente LEFT JOIN test_ladm_col_queries.col_fuenteespacial ON uefuente.pfuente = col_fuenteespacial.t_id
    LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.col_fuenteespacial_ext_archivo_id = col_fuenteespacial.t_id
	WHERE uefuente.ue_unidadconstruccion IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	GROUP BY ueFuente.ue_unidadconstruccion
 ),
info_uc AS (
	 SELECT unidadconstruccion.construccion,
			json_agg(json_build_object('id', unidadconstruccion.t_id,
							  'attributes', json_build_object('Número de pisos', unidadconstruccion.numero_pisos,
															  'Uso', unidad_construccion.uso,
															  'Puntuación', unidad_construccion.puntuacion,
															  'Tipología', unidad_construccion.tipologia,
															  'Destino económico', unidad_construccion.destino_econo,
															  'Tipo de construcción', unidad_construccion.construccion_tipo,
															  CONCAT('Área privada construida' , (SELECT * FROM unidad_area_privada_construida_uc)), unidadconstruccion.area_privada_construida,
															  CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), unidadconstruccion.area_construida,
															  'col_fuenteespacial', COALESCE(uc_fuente_espacial.col_fuenteespacial, '[]')
															 )) ORDER BY unidadconstruccion.t_id) FILTER(WHERE unidadconstruccion.t_id IS NOT NULL) AS unidadconstruccion
	 FROM test_ladm_col_queries.unidadconstruccion LEFT JOIN uc_fuente_espacial ON unidadconstruccion.t_id = uc_fuente_espacial.ue_unidadconstruccion
	 LEFT JOIN test_ladm_col_queries.avaluounidadconstruccion ON unidadconstruccion.t_id = avaluounidadconstruccion.ucons
	 LEFT JOIN test_ladm_col_queries.unidad_construccion ON avaluounidadconstruccion.aucons = unidad_construccion.t_id
	 WHERE unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
     GROUP BY unidadconstruccion.construccion
 ),
 c_fuente_espacial AS (
	SELECT uefuente.ue_construccion,
		json_agg(
				json_build_object('id', col_fuenteespacial.t_id,
									   'attributes', json_build_object('Tipo de fuente espacial', col_fuenteespacial.Tipo,
																	   'Estado disponibilidad', col_fuenteespacial.estado_disponibilidad,
																	   'Tipo principal', col_fuenteespacial.tipo_principal,
																	   'Fecha de entrega', col_fuenteespacial.fecha_entrega,
																	   'Fecha de grabación', col_fuenteespacial.fecha_grabacion,
																	   'Enlace fuente espacial', extarchivo.datos))
		ORDER BY col_fuenteespacial.t_id) FILTER(WHERE ueFuente.pfuente IS NOT NULL) AS col_fuenteespacial
	FROM test_ladm_col_queries.uefuente LEFT JOIN test_ladm_col_queries.col_fuenteespacial ON uefuente.pfuente = col_fuenteespacial.t_id
	LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.col_fuenteespacial_ext_archivo_id = col_fuenteespacial.t_id
	WHERE uefuente.ue_construccion IN (SELECT * FROM construcciones_seleccionadas)
	GROUP BY uefuente.ue_construccion
 ),
 info_construccion as (
  SELECT uebaunit.baunit_predio,
		json_agg(json_build_object('id', construccion.t_id,
						  'attributes', json_build_object('Área construcción', construccion.area_construccion,
														  'Ńúmero de pisos', avaluos_v2_2_1avaluos_construccion.numero_pisos,
														  'col_fuenteespacial', COALESCE(c_fuente_espacial.col_fuenteespacial, '[]'),
														  'unidadconstruccion', COALESCE(info_uc.unidadconstruccion, '[]')
														 )) ORDER BY construccion.t_id) FILTER(WHERE construccion.t_id IS NOT NULL) as construccion
  FROM test_ladm_col_queries.construccion LEFT JOIN c_fuente_espacial ON construccion.t_id = c_fuente_espacial.ue_construccion
  LEFT JOIN info_uc ON construccion.t_id = info_uc.construccion
  LEFT JOIN test_ladm_col_queries.uebaunit ON uebaunit.ue_construccion = construccion.t_id
  LEFT JOIN test_ladm_col_queries.avaluoconstruccion ON avaluoconstruccion.cons = construccion.t_id
  LEFT JOIN test_ladm_col_queries.avaluos_v2_2_1avaluos_construccion  ON avaluos_v2_2_1avaluos_construccion.t_id = avaluoconstruccion.acons
  WHERE construccion.t_id IN (SELECT * FROM construcciones_seleccionadas)
  GROUP BY uebaunit.baunit_predio
 ),
 info_predio AS (
	 SELECT uebaunit.ue_terreno,
			json_agg(json_build_object('id', predio.t_id,
							  'attributes', json_build_object('Nombre', predio.nombre,
															  'NUPRE', predio.nupre,
															  'FMI', predio.fmi,
															  'Número predial', predio.numero_predial,
															  'Número predial anterior', predio.numero_predial_anterior,
															  'construccion', COALESCE(info_construccion.construccion, '[]')
															 )) ORDER BY predio.t_id) FILTER(WHERE predio.t_id IS NOT NULL) as predio
	 FROM test_ladm_col_queries.predio LEFT JOIN info_construccion ON predio.t_id = info_construccion.baunit_predio
     LEFT JOIN test_ladm_col_queries.uebaunit ON uebaunit.baunit_predio = info_construccion.baunit_predio
	 WHERE predio.t_id = info_construccion.baunit_predio
	 AND uebaunit.ue_terreno IS NOT NULL
	 AND uebaunit.ue_construccion IS NULL
	 AND uebaunit.ue_unidadconstruccion IS NULL
	 GROUP BY uebaunit.ue_terreno
 ),
 t_fuente_espacial AS (
	SELECT uefuente.ue_terreno,
		json_agg(
				json_build_object('id', col_fuenteespacial.t_id,
									   'attributes', json_build_object('Tipo de fuente espacial', col_fuenteespacial.Tipo,
																	   'Estado disponibilidad', col_fuenteespacial.estado_disponibilidad,
																	   'Tipo principal', col_fuenteespacial.tipo_principal,
																	   'Fecha de entrega', col_fuenteespacial.fecha_entrega,
																	   'Fecha de grabación', col_fuenteespacial.fecha_grabacion,
																	   'Enlace fuente espacial', extarchivo.datos))
		ORDER BY col_fuenteespacial.t_id) FILTER(WHERE ueFuente.pfuente IS NOT NULL) AS col_fuenteespacial
	FROM test_ladm_col_queries.uefuente LEFT JOIN test_ladm_col_queries.col_fuenteespacial ON uefuente.pfuente = col_fuenteespacial.t_id
    LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.col_fuenteespacial_ext_archivo_id = col_fuenteespacial.t_id
	WHERE uefuente.ue_terreno IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY uefuente.ue_terreno
 ),
 info_linderos_externos AS (
	SELECT masccl.uep_terreno,
		json_agg(
				json_build_object('id', lindero.t_id,
									   'attributes', json_build_object(CONCAT('Longitud' , (SELECT * FROM unidad_longitud_lindero)), lindero.longitud))
		ORDER BY lindero.t_id) FILTER(WHERE lindero.t_id IS NOT NULL) AS lindero
	FROM test_ladm_col_queries.lindero LEFT JOIN test_ladm_col_queries.masccl ON lindero.t_id = masccl.cclp_lindero
    WHERE masccl.uep_terreno IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY masccl.uep_terreno
 ),
 info_linderos_internos AS (
	SELECT menos.eu_terreno,
		json_agg(
				json_build_object('id', lindero.t_id,
									   'attributes', json_build_object(CONCAT('Longitud' , (SELECT * FROM unidad_longitud_lindero)), lindero.longitud))
		ORDER BY lindero.t_id) FILTER(WHERE lindero.t_id IS NOT NULL) AS lindero
	FROM test_ladm_col_queries.lindero LEFT JOIN test_ladm_col_queries.menos ON lindero.t_id = menos.ccl_lindero
	WHERE menos.eu_terreno IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY menos.eu_terreno
 ),
info_punto_lindero_externos AS (
	SELECT punto_lindero_externos_seleccionados.uep_terreno,
	 		json_agg(
				json_build_object('id', puntolindero.t_id,
									   'attributes', json_build_object('Nombre', puntolindero.nombre_punto,
																	   'coordenadas', concat(st_x(puntolindero.localizacion_original),
																					 ' ', st_y(puntolindero.localizacion_original),
																					 CASE WHEN st_z(puntolindero.localizacion_original) IS NOT NULL THEN concat(' ', st_z(puntolindero.localizacion_original)) END))
			) ORDER BY puntolindero.t_id) FILTER(WHERE puntolindero.t_id IS NOT NULL) AS puntolindero
	FROM test_ladm_col_queries.puntolindero LEFT JOIN punto_lindero_externos_seleccionados ON puntolindero.t_id = punto_lindero_externos_seleccionados.t_id
	WHERE punto_lindero_externos_seleccionados.uep_terreno IS NOT NULL
	GROUP BY punto_lindero_externos_seleccionados.uep_terreno
 ),
 info_punto_lindero_internos AS (
	 SELECT punto_lindero_internos_seleccionados.eu_terreno,
	 		json_agg(
				json_build_object('id', puntolindero.t_id,
									   'attributes', json_build_object('Nombre', puntolindero.nombre_punto,
																	   'coordenadas', concat(st_x(puntolindero.localizacion_original),
																					 ' ', st_y(puntolindero.localizacion_original),
																					 CASE WHEN st_z(puntolindero.localizacion_original) IS NOT NULL THEN concat(' ', st_z(puntolindero.localizacion_original)) END))
			) ORDER BY puntolindero.t_id) FILTER(WHERE puntolindero.t_id IS NOT NULL) AS puntolindero
	 FROM test_ladm_col_queries.puntolindero LEFT JOIN punto_lindero_internos_seleccionados ON puntolindero.t_id = punto_lindero_internos_seleccionados.t_id
     WHERE punto_lindero_internos_seleccionados.eu_terreno IS NOT NULL
	 GROUP BY punto_lindero_internos_seleccionados.eu_terreno
 ),
col_bosqueareasemi_terreno_bosque_area_seminaturale AS (
	SELECT terreno_bosque_area_seminaturale,
		json_agg(
				json_build_object('id', t_id,
									   'attributes', json_build_object('avalue', avalue))
		ORDER BY t_id) FILTER(WHERE t_id IS NOT NULL) AS col_bosqueareasemi_terreno_bosque_area_seminaturale
	FROM test_ladm_col_queries.col_bosqueareasemi_terreno_bosque_area_seminaturale
    WHERE terreno_bosque_area_seminaturale IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY terreno_bosque_area_seminaturale
 ),
col_territorioagricola_terreno_territorio_agricola AS (
	SELECT terreno_territorio_agricola,
		json_agg(
				json_build_object('id', t_id,
									   'attributes', json_build_object('avalue', avalue))
		ORDER BY t_id) FILTER(WHERE t_id IS NOT NULL) AS col_territorioagricola_terreno_territorio_agricola
	FROM test_ladm_col_queries.col_territorioagricola_terreno_territorio_agricola
    WHERE terreno_territorio_agricola IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY terreno_territorio_agricola
 ),
col_cuerpoagua_terreno_evidencia_cuerpo_agua AS (
	SELECT terreno_evidencia_cuerpo_agua,
		json_agg(
				json_build_object('id', t_id,
									   'attributes', json_build_object('avalue', avalue))
		ORDER BY t_id) FILTER(WHERE t_id IS NOT NULL) AS col_cuerpoagua_terreno_evidencia_cuerpo_agua
	FROM test_ladm_col_queries.col_cuerpoagua_terreno_evidencia_cuerpo_agua
    WHERE terreno_evidencia_cuerpo_agua IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY terreno_evidencia_cuerpo_agua
 ),
col_explotaciontipo_terreno_explotacion AS (
	SELECT terreno_explotacion,
		json_agg(
				json_build_object('id', t_id,
									   'attributes', json_build_object('avalue', avalue))
		ORDER BY t_id) FILTER(WHERE t_id IS NOT NULL) AS col_explotaciontipo_terreno_explotacion
	FROM test_ladm_col_queries.col_explotaciontipo_terreno_explotacion
    WHERE terreno_explotacion IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY terreno_explotacion
 ),
col_afectacion_terreno_afectacion AS (
	SELECT terreno_afectacion,
		json_agg(
				json_build_object('id', t_id,
									   'attributes', json_build_object('avalue', avalue))
		ORDER BY t_id) FILTER(WHERE t_id IS NOT NULL) AS col_afectacion_terreno_afectacion
	FROM test_ladm_col_queries.col_afectacion_terreno_afectacion
    WHERE terreno_afectacion IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY terreno_afectacion
 ),
col_servidumbretipo_terreno_servidumbre AS (
	SELECT terreno_servidumbre,
		json_agg(
				json_build_object('id', t_id,
									   'attributes', json_build_object('avalue', avalue))
		ORDER BY t_id) FILTER(WHERE t_id IS NOT NULL) AS col_servidumbretipo_terreno_servidumbre
	FROM test_ladm_col_queries.col_servidumbretipo_terreno_servidumbre
    WHERE terreno_servidumbre IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY terreno_servidumbre
 ),
info_puntolevantamiento AS (
	SELECT uebaunit_predio.ue_terreno,
			json_agg(
					json_build_object('id', puntoslevantamiento_seleccionados.t_id_puntolevantamiento,
										   'attributes', json_build_object('coordenadas', concat(st_x(puntoslevantamiento_seleccionados.localizacion_original),
																					 ' ', st_y(puntoslevantamiento_seleccionados.localizacion_original),
																					 CASE WHEN st_z(puntoslevantamiento_seleccionados.localizacion_original) IS NOT NULL THEN concat(' ', st_z(puntoslevantamiento_seleccionados.localizacion_original)) END)
																		  ))
			ORDER BY puntoslevantamiento_seleccionados.t_id_puntolevantamiento) FILTER(WHERE puntoslevantamiento_seleccionados.t_id_puntolevantamiento IS NOT NULL) AS puntolevantamiento
	FROM
	(
		SELECT puntolevantamiento.t_id AS t_id_puntolevantamiento, puntolevantamiento.localizacion_original, construccion.t_id AS t_id_construccion  FROM test_ladm_col_queries.construccion, test_ladm_col_queries.puntolevantamiento
		WHERE ST_Intersects(construccion.poligono_creado, puntolevantamiento.localizacion_original) = True AND construccion.t_id IN (SELECT * from construcciones_seleccionadas)
	) AS puntoslevantamiento_seleccionados
	LEFT JOIN test_ladm_col_queries.uebaunit AS uebaunit_construccion  ON uebaunit_construccion.ue_construccion = puntoslevantamiento_seleccionados.t_id_construccion
	LEFT JOIN test_ladm_col_queries.uebaunit AS uebaunit_predio ON uebaunit_predio.baunit_predio = uebaunit_construccion.baunit_predio
	WHERE uebaunit_predio.ue_terreno IS NOT NULL AND
		  uebaunit_predio.ue_construccion IS NULL AND
		  uebaunit_predio.ue_unidadconstruccion IS NULL
	GROUP BY uebaunit_predio.ue_terreno
),
 info_terreno AS (
	SELECT terreno.t_id,
      json_build_object('id', terreno.t_id,
						'attributes', json_build_object(CONCAT('Área registral' , (SELECT * FROM unidad_area_registral_terreno)), terreno.area_registral,
														CONCAT('Área calculada' , (SELECT * FROM unidad_area_calculada_terreno)), terreno.area_calculada,
														'predio', COALESCE(info_predio.predio, '[]'),
														'col_territorioagricola_terreno_territorio_agricola', COALESCE(col_territorioagricola_terreno_territorio_agricola.col_territorioagricola_terreno_territorio_agricola, '[]'),
														'col_bosqueareasemi_terreno_bosque_area_seminaturale', COALESCE(col_bosqueareasemi_terreno_bosque_area_seminaturale.col_bosqueareasemi_terreno_bosque_area_seminaturale, '[]'),
														'col_cuerpoagua_terreno_evidencia_cuerpo_agua', COALESCE(col_cuerpoagua_terreno_evidencia_cuerpo_agua.col_cuerpoagua_terreno_evidencia_cuerpo_agua, '[]'),
														'col_explotaciontipo_terreno_explotacion', COALESCE(col_explotaciontipo_terreno_explotacion.col_explotaciontipo_terreno_explotacion, '[]'),
														'col_afectacion_terreno_afectacion', COALESCE(col_afectacion_terreno_afectacion.col_afectacion_terreno_afectacion, '[]'),
														'col_servidumbretipo_terreno_servidumbre', COALESCE(col_servidumbretipo_terreno_servidumbre.col_servidumbretipo_terreno_servidumbre, '[]'),
														'Linderos externos', json_build_object('lindero', COALESCE(info_linderos_externos.lindero, '[]'),
																							   'puntolindero', COALESCE(info_punto_lindero_externos.puntolindero, '[]')),
														'Linderos internos', json_build_object('lindero', COALESCE(info_linderos_internos.lindero, '[]'),
																							   'puntolindero', COALESCE(info_punto_lindero_internos.puntolindero, '[]')),
														'puntolevantamiento', COALESCE(info_puntolevantamiento.puntolevantamiento, '[]'),
														'col_fuenteespacial', COALESCE(t_fuente_espacial.col_fuenteespacial, '[]')
													   )) as terreno
    FROM test_ladm_col_queries.terreno LEFT JOIN info_predio ON info_predio.ue_terreno = terreno.t_id
	LEFT JOIN t_fuente_espacial ON terreno.t_id = t_fuente_espacial.ue_terreno
	LEFT JOIN info_linderos_externos ON terreno.t_id = info_linderos_externos.uep_terreno
	LEFT JOIN info_linderos_internos ON terreno.t_id = info_linderos_internos.eu_terreno
    LEFT JOIN info_punto_lindero_externos ON terreno.t_id = info_punto_lindero_externos.uep_terreno
	LEFT JOIN info_punto_lindero_internos ON terreno.t_id = info_punto_lindero_internos.eu_terreno
	LEFT JOIN col_territorioagricola_terreno_territorio_agricola ON terreno.t_id = col_territorioagricola_terreno_territorio_agricola.terreno_territorio_agricola
	LEFT JOIN col_bosqueareasemi_terreno_bosque_area_seminaturale ON terreno.t_id = col_bosqueareasemi_terreno_bosque_area_seminaturale.terreno_bosque_area_seminaturale
	LEFT JOIN col_cuerpoagua_terreno_evidencia_cuerpo_agua ON terreno.t_id = col_cuerpoagua_terreno_evidencia_cuerpo_agua.terreno_evidencia_cuerpo_agua
	LEFT JOIN col_explotaciontipo_terreno_explotacion ON terreno.t_id = col_explotaciontipo_terreno_explotacion.terreno_explotacion
	LEFT JOIN col_afectacion_terreno_afectacion ON terreno.t_id = col_afectacion_terreno_afectacion.terreno_afectacion
	LEFT JOIN col_servidumbretipo_terreno_servidumbre ON terreno.t_id = col_servidumbretipo_terreno_servidumbre.terreno_servidumbre
    LEFT JOIN info_puntolevantamiento ON terreno.t_id = info_puntolevantamiento.ue_terreno
	WHERE terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
  ORDER BY terreno.t_id
 )
SELECT json_agg(info_terreno.terreno) AS terreno FROM info_terreno

