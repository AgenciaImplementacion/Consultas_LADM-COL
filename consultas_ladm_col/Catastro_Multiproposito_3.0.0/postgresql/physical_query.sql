WITH
 _unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 _unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 _unidad_area_privada_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_unidadconstruccion' AND columnname = 'area_privada_construida' LIMIT 1
 ),
 _unidad_longitud_lindero AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_lindero' AND columnname = 'longitud' LIMIT 1
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
_punto_lindero_externos_seleccionados AS (
	 SELECT DISTINCT col_masccl.ue_mas_lc_terreno, lc_puntolindero.t_id
	 FROM test_ladm_col_queries.lc_puntolindero JOIN test_ladm_col_queries.col_puntoccl ON lc_puntolindero.t_id = col_puntoccl.punto_lc_puntolindero
	 JOIN test_ladm_col_queries.lc_lindero ON col_puntoccl.ccl = lc_lindero.t_id
	 JOIN test_ladm_col_queries.col_masccl ON lc_lindero.t_id = col_masccl.ccl_mas
	 WHERE col_masccl.ue_mas_lc_terreno IN (SELECT * FROM _terrenos_seleccionados)
	 ORDER BY col_masccl.ue_mas_lc_terreno, lc_puntolindero.t_id
),
_punto_lindero_internos_seleccionados AS (
	SELECT DISTINCT col_menosccl.ue_menos_lc_terreno, lc_puntolindero.t_id
	FROM test_ladm_col_queries.lc_puntolindero JOIN test_ladm_col_queries.col_puntoccl ON lc_puntolindero.t_id = col_puntoccl.punto_lc_puntolindero
	JOIN test_ladm_col_queries.lc_lindero ON col_puntoccl.ccl = lc_lindero.t_id
	JOIN test_ladm_col_queries.col_menosccl ON lc_lindero.t_id = col_menosccl.ccl_menos
	WHERE col_menosccl.ue_menos_lc_terreno IN (SELECT * FROM _terrenos_seleccionados)
  ORDER BY col_menosccl.ue_menos_lc_terreno, lc_puntolindero.t_id
),
 _uc_fuente_espacial AS (
	SELECT col_uefuente.ue_lc_unidadconstruccion,
		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_fuenteespacial.t_id,
									   'attributes', JSON_BUILD_OBJECT('Tipo de fuente espacial', (SELECT dispname FROM test_ladm_col_queries.col_fuenteespacialtipo WHERE t_id = lc_fuenteespacial.tipo),
																	   'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteespacial.estado_disponibilidad),
																	   'Tipo principal', (SELECT dispname FROM test_ladm_col_queries.ci_forma_presentacion_codigo WHERE t_id = lc_fuenteespacial.tipo_principal),
																	   'Fecha documento', lc_fuenteespacial.fecha_documento_fuente,
																	   'Archivo fuente', extarchivo.datos))
		ORDER BY lc_fuenteespacial.t_id) FILTER(WHERE col_uefuente.fuente_espacial IS NOT NULL) AS _fuenteespacial_
	FROM test_ladm_col_queries.col_uefuente LEFT JOIN test_ladm_col_queries.lc_fuenteespacial ON col_uefuente.fuente_espacial = lc_fuenteespacial.t_id
    LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteespacial_ext_archivo_id = lc_fuenteespacial.t_id
	WHERE col_uefuente.ue_lc_unidadconstruccion IN (SELECT * FROM _unidadesconstruccion_seleccionadas)
	GROUP BY col_uefuente.ue_lc_unidadconstruccion
 ),
_info_uc AS (
	 SELECT lc_unidadconstruccion.lc_construccion,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_unidadconstruccion.t_id,
							  'attributes', JSON_BUILD_OBJECT('Número de pisos', lc_unidadconstruccion.total_pisos,
															  'Uso', (SELECT dispname FROM test_ladm_col_queries.lc_usouconstipo WHERE t_id = lc_unidadconstruccion.uso),
															  'Tipo construcción', (SELECT dispname FROM test_ladm_col_queries.lc_ConstruccionTipo WHERE t_id = lc_unidadconstruccion.tipo_construccion),
															  'Tipo unidad de construcción', (SELECT dispname FROM test_ladm_col_queries.lc_UnidadConstruccionTipo WHERE t_id = lc_unidadconstruccion.tipo_unidad_construccion),
															  CONCAT('Área privada construida' , (SELECT * FROM _unidad_area_privada_construida_uc)), lc_unidadconstruccion.area_privada_construida,
															  CONCAT('Área construida' , (SELECT * FROM _unidad_area_construida_uc)), lc_unidadconstruccion.area_construida,
															  'lc_fuenteespacial', COALESCE(_uc_fuente_espacial._fuenteespacial_, '[]')
															 )) ORDER BY lc_unidadconstruccion.t_id) FILTER(WHERE lc_unidadconstruccion.t_id IS NOT NULL) AS _unidadconstruccion_
	 FROM test_ladm_col_queries.lc_unidadconstruccion LEFT JOIN _uc_fuente_espacial ON lc_unidadconstruccion.t_id = _uc_fuente_espacial.ue_lc_unidadconstruccion
	 WHERE lc_unidadconstruccion.t_id IN (SELECT * FROM _unidadesconstruccion_seleccionadas)
     GROUP BY lc_unidadconstruccion.lc_construccion
 ),
 _c_fuente_espacial AS (
	SELECT col_uefuente.ue_lc_construccion,
		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_fuenteespacial.t_id,
									   'attributes', JSON_BUILD_OBJECT('Tipo de fuente espacial', (SELECT dispname FROM test_ladm_col_queries.col_fuenteespacialtipo WHERE t_id = lc_fuenteespacial.tipo),
																	   'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteespacial.estado_disponibilidad),
																	   'Tipo principal', (SELECT dispname FROM test_ladm_col_queries.ci_forma_presentacion_codigo WHERE t_id = lc_fuenteespacial.tipo_principal),
																	   'Fecha documento', lc_fuenteespacial.fecha_documento_fuente,
																	   'Archivo fuente', extarchivo.datos))
		ORDER BY lc_fuenteespacial.t_id) FILTER(WHERE col_uefuente.fuente_espacial IS NOT NULL) AS _fuenteespacial_
	FROM test_ladm_col_queries.col_uefuente LEFT JOIN test_ladm_col_queries.lc_fuenteespacial ON col_uefuente.fuente_espacial = lc_fuenteespacial.t_id
	LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteespacial_ext_archivo_id = lc_fuenteespacial.t_id
	WHERE col_uefuente.ue_lc_construccion IN (SELECT * FROM _construcciones_seleccionadas)
	GROUP BY col_uefuente.ue_lc_construccion
 ),
 _info_construccion AS (
  SELECT col_uebaunit.baunit,
		JSON_AGG(JSON_BUILD_OBJECT('id', lc_construccion.t_id,
						  'attributes', JSON_BUILD_OBJECT('Área construcción', lc_construccion.area_construccion,
														  'Número de pisos', lc_construccion.numero_pisos,
														  'lc_unidadconstruccion', COALESCE(_info_uc._unidadconstruccion_, '[]'),
														  'lc_fuenteespacial', COALESCE(_c_fuente_espacial._fuenteespacial_, '[]')
														 )) ORDER BY lc_construccion.t_id) FILTER(WHERE lc_construccion.t_id IS NOT NULL) AS _construccion_
  FROM test_ladm_col_queries.lc_construccion LEFT JOIN _c_fuente_espacial ON lc_construccion.t_id = _c_fuente_espacial.ue_lc_construccion
  LEFT JOIN _info_uc ON lc_construccion.t_id = _info_uc.lc_construccion
  LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.ue_lc_construccion = lc_construccion.t_id
  WHERE lc_construccion.t_id IN (SELECT * FROM _construcciones_seleccionadas)
  GROUP BY col_uebaunit.baunit
 ),
 _info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_predio.t_id,
							  'attributes', JSON_BUILD_OBJECT('Nombre', lc_predio.nombre,
															  'Id operación', lc_predio.id_operacion,
															  'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria),
															  'Número predial', lc_predio.numero_predial,
															  'Número predial anterior', lc_predio.numero_predial_anterior,
															  'lc_construccion', COALESCE(_info_construccion._construccion_, '[]')
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) AS _predio_
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN _info_construccion ON lc_predio.t_id = _info_construccion.baunit
     LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = _info_construccion.baunit
	 WHERE lc_predio.t_id = _info_construccion.baunit
	 AND col_uebaunit.ue_lc_terreno IS NOT NULL
	 AND col_uebaunit.ue_lc_construccion IS NULL
	 AND col_uebaunit.ue_lc_unidadconstruccion IS NULL
	 GROUP BY col_uebaunit.ue_lc_terreno
 ),
 _t_fuente_espacial AS (
	SELECT col_uefuente.ue_lc_terreno,
		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_fuenteespacial.t_id,
									   'attributes', JSON_BUILD_OBJECT('Tipo de fuente espacial', (SELECT dispname FROM test_ladm_col_queries.col_fuenteespacialtipo WHERE t_id = lc_fuenteespacial.tipo),
																	   'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteespacial.estado_disponibilidad),
																	   'Tipo principal', (SELECT dispname FROM test_ladm_col_queries.ci_forma_presentacion_codigo WHERE t_id = lc_fuenteespacial.tipo_principal),
																	   'Fecha documento', lc_fuenteespacial.fecha_documento_fuente,
																	   'Archivo fuente', extarchivo.datos))
		ORDER BY lc_fuenteespacial.t_id) FILTER(WHERE col_uefuente.fuente_espacial IS NOT NULL) AS _fuenteespacial_
	FROM test_ladm_col_queries.col_uefuente LEFT JOIN test_ladm_col_queries.lc_fuenteespacial ON col_uefuente.fuente_espacial = lc_fuenteespacial.t_id
    LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteespacial_ext_archivo_id = lc_fuenteespacial.t_id
	WHERE col_uefuente.ue_lc_terreno IN (SELECT * FROM _terrenos_seleccionados)
	GROUP BY col_uefuente.ue_lc_terreno
 ),
 _info_linderos_externos AS (
	SELECT col_masccl.ue_mas_lc_terreno,
		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_lindero.t_id,
									   'attributes', JSON_BUILD_OBJECT(CONCAT('Longitud' , (SELECT * FROM _unidad_longitud_lindero)), lc_lindero.longitud))
		ORDER BY lc_lindero.t_id) FILTER(WHERE lc_lindero.t_id IS NOT NULL) AS _lindero_
	FROM test_ladm_col_queries.lc_lindero JOIN test_ladm_col_queries.col_masccl ON lc_lindero.t_id = col_masccl.ccl_mas
    WHERE col_masccl.ue_mas_lc_terreno IN (SELECT * FROM _terrenos_seleccionados)
	GROUP BY col_masccl.ue_mas_lc_terreno
 ),
 _info_linderos_internos AS (
	SELECT col_menosccl.ue_menos_lc_terreno,
		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_lindero.t_id,
									   'attributes', JSON_BUILD_OBJECT(CONCAT('Longitud' , (SELECT * FROM _unidad_longitud_lindero)), lc_lindero.longitud))
		ORDER BY lc_lindero.t_id) FILTER(WHERE lc_lindero.t_id IS NOT NULL) AS _lindero_
	FROM test_ladm_col_queries.lc_lindero JOIN test_ladm_col_queries.col_menosccl ON lc_lindero.t_id = col_menosccl.ccl_menos
	WHERE col_menosccl.ue_menos_lc_terreno IN (SELECT * FROM _terrenos_seleccionados)
	GROUP BY col_menosccl.ue_menos_lc_terreno
 ),
_info_punto_lindero_externos AS (
	SELECT _punto_lindero_externos_seleccionados.ue_mas_lc_terreno,
	 		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_puntolindero.t_id,
									   'attributes', JSON_BUILD_OBJECT('Nombre', lc_puntolindero.id_punto_lindero,
																	   'Coordenadas', concat(st_x(lc_puntolindero.geometria),
																					 ' ', st_y(lc_puntolindero.geometria),
																					 CASE WHEN st_z(lc_puntolindero.geometria) IS NOT NULL THEN concat(' ', st_z(lc_puntolindero.geometria)) END))
			) ORDER BY lc_puntolindero.t_id) FILTER(WHERE lc_puntolindero.t_id IS NOT NULL) AS _puntolindero_
	FROM test_ladm_col_queries.lc_puntolindero JOIN _punto_lindero_externos_seleccionados ON lc_puntolindero.t_id = _punto_lindero_externos_seleccionados.t_id
	WHERE _punto_lindero_externos_seleccionados.ue_mas_lc_terreno IS NOT NULL
	GROUP BY _punto_lindero_externos_seleccionados.ue_mas_lc_terreno
 ),
 _info_punto_lindero_internos AS (
	 SELECT _punto_lindero_internos_seleccionados.ue_menos_lc_terreno,
	 		JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_puntolindero.t_id,
									   'attributes', JSON_BUILD_OBJECT('Nombre', lc_puntolindero.id_punto_lindero,
																	   'Coordenadas', concat(st_x(lc_puntolindero.geometria),
																					 ' ', st_y(lc_puntolindero.geometria),
																					 CASE WHEN st_z(lc_puntolindero.geometria) IS NOT NULL THEN concat(' ', st_z(lc_puntolindero.geometria)) END))
			) ORDER BY lc_puntolindero.t_id) FILTER(WHERE lc_puntolindero.t_id IS NOT NULL) AS _puntolindero_
	 FROM test_ladm_col_queries.lc_puntolindero JOIN _punto_lindero_internos_seleccionados ON lc_puntolindero.t_id = _punto_lindero_internos_seleccionados.t_id
     WHERE _punto_lindero_internos_seleccionados.ue_menos_lc_terreno IS NOT NULL
	 GROUP BY _punto_lindero_internos_seleccionados.ue_menos_lc_terreno
 ),
_info_puntolevantamiento AS (
	SELECT _t_id_terreno_,
            JSON_AGG(
                    JSON_BUILD_OBJECT('id', _puntoslevantamiento_seleccionados._t_id_puntolevantamiento_,
                                           'attributes', JSON_BUILD_OBJECT('Coordenadas', concat(st_x(_puntoslevantamiento_seleccionados._geometria_),
                                                                                     ' ', st_y(_puntoslevantamiento_seleccionados._geometria_),
                                                                                     CASE WHEN st_z(_puntoslevantamiento_seleccionados._geometria_) IS NOT NULL THEN concat(' ', st_z(_puntoslevantamiento_seleccionados._geometria_)) END)
                                                                          ))
            ORDER BY _puntoslevantamiento_seleccionados._t_id_puntolevantamiento_) FILTER(WHERE _puntoslevantamiento_seleccionados._t_id_puntolevantamiento_ IS NOT NULL) AS _puntolevantamiento_
    FROM
    (
        SELECT lc_puntolevantamiento.t_id AS _t_id_puntolevantamiento_, lc_puntolevantamiento.geometria as _geometria_, lc_terreno.t_id AS _t_id_terreno_
        FROM test_ladm_col_queries.lc_terreno, test_ladm_col_queries.lc_puntolevantamiento
        WHERE ST_Intersects(lc_terreno.geometria, lc_puntolevantamiento.geometria) AND lc_terreno.t_id IN (SELECT * FROM _terrenos_seleccionados)
    ) AS _puntoslevantamiento_seleccionados
    GROUP BY _t_id_terreno_
),
 _info_terreno AS (
	SELECT lc_terreno.t_id,
      JSON_BUILD_OBJECT('id', lc_terreno.t_id,
						'attributes', JSON_BUILD_OBJECT(CONCAT('Área' , (SELECT * FROM _unidad_area_terreno)), lc_terreno.area_terreno,
														'lc_predio', COALESCE(_info_predio._predio_, '[]'),
														'lc_lindero externos', COALESCE(_info_linderos_externos._lindero_, '[]'),
														'lc_puntolindero externos', COALESCE(_info_punto_lindero_externos._puntolindero_, '[]'),
														'lc_lindero internos', COALESCE(_info_linderos_internos._lindero_, '[]'),
														'lc_puntolindero internos', COALESCE(_info_punto_lindero_internos._puntolindero_, '[]'),
														'lc_puntolevantamiento', COALESCE(_info_puntolevantamiento._puntolevantamiento_, '[]'),
														'lc_fuenteespacial', COALESCE(_t_fuente_espacial._fuenteespacial_, '[]')
													   )) AS _terreno_
    FROM test_ladm_col_queries.lc_terreno LEFT JOIN _info_predio ON _info_predio.ue_lc_terreno = lc_terreno.t_id
	LEFT JOIN _t_fuente_espacial ON lc_terreno.t_id = _t_fuente_espacial.ue_lc_terreno
	LEFT JOIN _info_linderos_externos ON lc_terreno.t_id = _info_linderos_externos.ue_mas_lc_terreno
	LEFT JOIN _info_linderos_internos ON lc_terreno.t_id = _info_linderos_internos.ue_menos_lc_terreno
    LEFT JOIN _info_punto_lindero_externos ON lc_terreno.t_id = _info_punto_lindero_externos.ue_mas_lc_terreno
	LEFT JOIN _info_punto_lindero_internos ON lc_terreno.t_id = _info_punto_lindero_internos.ue_menos_lc_terreno
    LEFT JOIN _info_puntolevantamiento ON lc_terreno.t_id = _info_puntolevantamiento._t_id_terreno_
	WHERE lc_terreno.t_id IN (SELECT * FROM _terrenos_seleccionados)
  ORDER BY lc_terreno.t_id
 )
 SELECT JSON_BUILD_OBJECT('lc_terreno', JSON_AGG(_info_terreno._terreno_)) FROM _info_terreno
