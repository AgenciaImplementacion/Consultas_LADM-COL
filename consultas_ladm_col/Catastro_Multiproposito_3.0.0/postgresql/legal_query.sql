WITH
 _unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM test_ladm_col_queries.t_ili2db_column_prop WHERE tablename = 'lc_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 _terrenos_seleccionados AS (
	SELECT 897 AS ue_terreno WHERE '897' <> 'NULL'
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
 _derechos_seleccionados AS (
	 SELECT DISTINCT lc_derecho.t_id FROM test_ladm_col_queries.lc_derecho WHERE lc_derecho.unidad IN (SELECT * FROM _predios_seleccionados)
 ),
 _derecho_interesados AS (
	 SELECT DISTINCT lc_derecho.interesado_lc_interesado, lc_derecho.t_id FROM test_ladm_col_queries.lc_derecho WHERE lc_derecho.t_id IN (SELECT * FROM _derechos_seleccionados) AND lc_derecho.interesado_lc_interesado IS NOT NULL
 ),
 _derecho_agrupacion_interesados AS (
	 SELECT DISTINCT lc_derecho.interesado_lc_agrupacioninteresados, col_miembros.interesado_lc_interesado
	 FROM test_ladm_col_queries.lc_derecho LEFT JOIN test_ladm_col_queries.col_miembros ON lc_derecho.interesado_lc_agrupacioninteresados = col_miembros.agrupacion
	 WHERE lc_derecho.t_id IN (SELECT * FROM _derechos_seleccionados) AND lc_derecho.interesado_lc_agrupacioninteresados IS NOT NULL
 ),
  _restricciones_seleccionadas AS (
	 SELECT DISTINCT lc_restriccion.t_id FROM test_ladm_col_queries.lc_restriccion WHERE lc_restriccion.unidad IN (SELECT * FROM _predios_seleccionados)
 ),
 _restriccion_interesados AS (
	 SELECT DISTINCT lc_restriccion.interesado_lc_interesado, lc_restriccion.t_id FROM test_ladm_col_queries.lc_restriccion WHERE lc_restriccion.t_id IN (SELECT * FROM _restricciones_seleccionadas) AND lc_restriccion.interesado_lc_interesado IS NOT NULL
 ),
 _restriccion_agrupacion_interesados AS (
	 SELECT DISTINCT lc_restriccion.interesado_lc_agrupacioninteresados, col_miembros.interesado_lc_interesado
	 FROM test_ladm_col_queries.lc_restriccion LEFT JOIN test_ladm_col_queries.col_miembros ON lc_restriccion.interesado_lc_agrupacioninteresados = col_miembros.agrupacion
	 WHERE lc_restriccion.t_id IN (SELECT * FROM _restricciones_seleccionadas) AND lc_restriccion.interesado_lc_agrupacioninteresados IS NOT NULL
 ),
 _info_contacto_interesados_derecho AS (
		SELECT lc_interesadocontacto.lc_interesado,
		  JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_interesadocontacto.t_id,
									   'attributes', JSON_BUILD_OBJECT('Teléfono 1', lc_interesadocontacto.telefono1,
																	   'Teléfono 2', lc_interesadocontacto.telefono2,
																	   'Domicilio notificación', lc_interesadocontacto.domicilio_notificacion,
																	   'Correo electrónico', lc_interesadocontacto.correo_electronico)) ORDER BY lc_interesadocontacto.t_id)
		FILTER(WHERE lc_interesadocontacto.t_id IS NOT NULL) AS _interesado_contacto_
		FROM test_ladm_col_queries.lc_interesadocontacto
		WHERE lc_interesadocontacto.lc_interesado IN (SELECT _derecho_interesados.interesado_lc_interesado FROM _derecho_interesados)
		GROUP BY lc_interesadocontacto.lc_interesado
 ),
 _info_interesados_derecho AS (
	 SELECT _derecho_interesados.t_id,
	  JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_interesado.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_interesadotipo WHERE t_id = lc_interesado.tipo),
														  lc_interesadodocumentotipo.dispname, lc_interesado.documento_identidad,
														  'Nombre', lc_interesado.nombre,
														  CASE WHEN lc_interesado.tipo = 9 THEN 'Tipo interesado jurídico' ELSE 'Género' END,
														  CASE WHEN lc_interesado.tipo = 9 THEN (SELECT dispname FROM test_ladm_col_queries.lc_interesadotipo WHERE t_id = lc_interesado.tipo) ELSE (SELECT dispname FROM test_ladm_col_queries.lc_sexotipo WHERE t_id = lc_interesado.sexo) END,
														  'lc_interesadocontacto', COALESCE(_info_contacto_interesados_derecho._interesado_contacto_, '[]')))
	 ORDER BY lc_interesado.t_id) FILTER (WHERE lc_interesado.t_id IS NOT NULL) AS _interesado_
	 FROM _derecho_interesados LEFT JOIN test_ladm_col_queries.lc_interesado ON lc_interesado.t_id = _derecho_interesados.interesado_lc_interesado
   LEFT JOIN test_ladm_col_queries.lc_interesadodocumentotipo ON lc_interesadodocumentotipo.t_id = lc_interesado.tipo_documento
	 LEFT JOIN _info_contacto_interesados_derecho ON _info_contacto_interesados_derecho.lc_interesado = lc_interesado.t_id
	 GROUP BY _derecho_interesados.t_id
 ),
 _info_contacto_interesado_agrupacion_interesados_derecho AS (
		SELECT lc_interesadocontacto.lc_interesado,
		  JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_interesadocontacto.t_id,
									   'attributes', JSON_BUILD_OBJECT('Teléfono 1', lc_interesadocontacto.telefono1,
																	   'Teléfono 2', lc_interesadocontacto.telefono2,
																	   'Domicilio notificación', lc_interesadocontacto.domicilio_notificacion,
																	   'Correo electrónico', lc_interesadocontacto.correo_electronico)) ORDER BY lc_interesadocontacto.t_id)
		FILTER(WHERE lc_interesadocontacto.t_id IS NOT NULL) AS _interesado_contacto_
		FROM test_ladm_col_queries.lc_interesadocontacto LEFT JOIN _derecho_interesados ON _derecho_interesados.interesado_lc_interesado = lc_interesadocontacto.lc_interesado
		WHERE lc_interesadocontacto.lc_interesado IN (SELECT DISTINCT _derecho_agrupacion_interesados.interesado_lc_interesado FROM _derecho_agrupacion_interesados)
		GROUP BY lc_interesadocontacto.lc_interesado
 ),
 _info_interesados_agrupacion_interesados_derecho AS (
	 SELECT _derecho_agrupacion_interesados.interesado_lc_agrupacioninteresados,
	  JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_interesado.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_interesadotipo WHERE t_id = lc_interesado.tipo),
						                                  lc_interesadodocumentotipo.dispname, lc_interesado.documento_identidad,
														  'Nombre', lc_interesado.nombre,
														  'Género', (SELECT dispname FROM test_ladm_col_queries.lc_sexotipo WHERE t_id = lc_interesado.sexo),
														  'lc_interesadocontacto', COALESCE(_info_contacto_interesado_agrupacion_interesados_derecho._interesado_contacto_, '[]'),
														  'fraccion', ROUND((fraccion.numerador::numeric/fraccion.denominador::numeric)*100,2) ))
	 ORDER BY lc_interesado.t_id) FILTER (WHERE lc_interesado.t_id IS NOT NULL) AS _interesado_
	 FROM _derecho_agrupacion_interesados LEFT JOIN test_ladm_col_queries.lc_interesado ON lc_interesado.t_id = _derecho_agrupacion_interesados.interesado_lc_interesado
   LEFT JOIN test_ladm_col_queries.lc_interesadodocumentotipo ON lc_interesadodocumentotipo.t_id = lc_interesado.tipo_documento
	 LEFT JOIN _info_contacto_interesado_agrupacion_interesados_derecho ON _info_contacto_interesado_agrupacion_interesados_derecho.lc_interesado = lc_interesado.t_id
	 LEFT JOIN test_ladm_col_queries.col_miembros ON (col_miembros.agrupacion::text || col_miembros.interesado_lc_interesado::text) = (_derecho_agrupacion_interesados.interesado_lc_agrupacioninteresados::text|| lc_interesado.t_id::text)
	 LEFT JOIN test_ladm_col_queries.fraccion ON col_miembros.t_id = fraccion.col_miembros_participacion
	 GROUP BY _derecho_agrupacion_interesados.interesado_lc_agrupacioninteresados
 ),
 _info_agrupacion_interesados AS (
	 SELECT lc_derecho.t_id,
	 JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_agrupacioninteresados.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo de agrupación de interesados', (SELECT dispname FROM test_ladm_col_queries.col_grupointeresadotipo WHERE t_id = lc_agrupacioninteresados.tipo),
														  'Nombre', lc_agrupacioninteresados.nombre,
														  'lc_interesado', COALESCE(_info_interesados_agrupacion_interesados_derecho._interesado_, '[]')))
	 ORDER BY lc_agrupacioninteresados.t_id) FILTER (WHERE lc_agrupacioninteresados.t_id IS NOT NULL) AS _agrupacioninteresados_
	 FROM test_ladm_col_queries.lc_agrupacioninteresados LEFT JOIN test_ladm_col_queries.lc_derecho ON lc_agrupacioninteresados.t_id = lc_derecho.interesado_lc_agrupacioninteresados
	 LEFT JOIN _info_interesados_agrupacion_interesados_derecho ON _info_interesados_agrupacion_interesados_derecho.interesado_lc_agrupacioninteresados = lc_agrupacioninteresados.t_id
	 WHERE lc_agrupacioninteresados.t_id IN (SELECT DISTINCT _derecho_agrupacion_interesados.interesado_lc_agrupacioninteresados FROM _derecho_agrupacion_interesados)
	 AND lc_derecho.t_id IN (SELECT _derechos_seleccionados.t_id FROM _derechos_seleccionados)
	 GROUP BY lc_derecho.t_id
 ),
 _info_fuentes_administrativas_derecho AS (
	SELECT lc_derecho.t_id,
	 JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_fuenteadministrativa.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo de fuente administrativa', (SELECT dispname FROM test_ladm_col_queries.lc_fuenteadministrativatipo WHERE t_id = lc_fuenteadministrativa.tipo),
														  'Ente emisor', lc_fuenteadministrativa.ente_emisor,
														  'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteadministrativa.estado_disponibilidad),
														  'Archivo fuente', extarchivo.datos))
	 ORDER BY lc_fuenteadministrativa.t_id) FILTER (WHERE lc_fuenteadministrativa.t_id IS NOT NULL) AS _fuenteadministrativa_
	FROM test_ladm_col_queries.lc_derecho
	LEFT JOIN test_ladm_col_queries.col_rrrfuente ON lc_derecho.t_id = col_rrrfuente.rrr_lc_derecho
	LEFT JOIN test_ladm_col_queries.lc_fuenteadministrativa ON col_rrrfuente.fuente_administrativa = lc_fuenteadministrativa.t_id
	LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteadministrtiva_ext_archivo_id = lc_fuenteadministrativa.t_id
	WHERE lc_derecho.t_id IN (SELECT _derechos_seleccionados.t_id FROM _derechos_seleccionados)
    GROUP BY lc_derecho.t_id
 ),
_info_derecho AS (
  SELECT lc_derecho.unidad,
	JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_derecho.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo de derecho', (SELECT dispname FROM test_ladm_col_queries.lc_derechotipo WHERE t_id = lc_derecho.tipo),
														  'Descripción', lc_derecho.descripcion,
														  'lc_fuenteadministrativa', COALESCE(_info_fuentes_administrativas_derecho._fuenteadministrativa_, '[]'),
														  'lc_interesado', COALESCE(_info_interesados_derecho._interesado_, '[]'),
														  'lc_agrupacioninteresados', COALESCE(_info_agrupacion_interesados._agrupacioninteresados_, '[]')))
	 ORDER BY lc_derecho.t_id) FILTER (WHERE lc_derecho.t_id IS NOT NULL) AS _derecho_
  FROM test_ladm_col_queries.lc_derecho LEFT JOIN _info_fuentes_administrativas_derecho ON lc_derecho.t_id = _info_fuentes_administrativas_derecho.t_id
  LEFT JOIN _info_interesados_derecho ON lc_derecho.t_id = _info_interesados_derecho.t_id
  LEFT JOIN _info_agrupacion_interesados ON lc_derecho.t_id = _info_agrupacion_interesados.t_id
  WHERE lc_derecho.t_id IN (SELECT * FROM _derechos_seleccionados)
  GROUP BY lc_derecho.unidad
),
 _info_contacto_interesados_restriccion AS (
		SELECT lc_interesadocontacto.lc_interesado,
		  JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_interesadocontacto.t_id,
									   'attributes', JSON_BUILD_OBJECT('Teléfono 1', lc_interesadocontacto.telefono1,
																	   'Teléfono 2', lc_interesadocontacto.telefono2,
																	   'Domicilio notificación', lc_interesadocontacto.domicilio_notificacion,
																	   'Correo electrónico', lc_interesadocontacto.correo_electronico)) ORDER BY lc_interesadocontacto.t_id)
		FILTER(WHERE lc_interesadocontacto.t_id IS NOT NULL) AS _interesado_contacto_
		FROM test_ladm_col_queries.lc_interesadocontacto
		WHERE lc_interesadocontacto.lc_interesado IN (SELECT _restriccion_interesados.interesado_lc_interesado FROM _restriccion_interesados)
		GROUP BY lc_interesadocontacto.lc_interesado
 ),
 _info_interesados_restriccion AS (
	 SELECT _restriccion_interesados.t_id,
	  JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_interesado.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo', lc_interesado.tipo,
														  lc_interesadodocumentotipo.dispname, lc_interesado.documento_identidad,
														  'Nombre', lc_interesado.nombre,
														  CASE WHEN lc_interesado.tipo = (SELECT t_id FROM test_ladm_col_queries.lc_interesadotipo WHERE ilicode LIKE 'Persona_Juridica') THEN 'Tipo interesado jurídico' ELSE 'Género' END,
														  CASE WHEN lc_interesado.tipo = (SELECT t_id FROM test_ladm_col_queries.lc_interesadotipo WHERE ilicode LIKE 'Persona_Juridica') THEN (SELECT dispname FROM test_ladm_col_queries.lc_interesadotipo WHERE t_id = lc_interesado.tipo) ELSE (SELECT dispname FROM test_ladm_col_queries.lc_sexotipo WHERE t_id = lc_interesado.sexo) END,
														  'lc_interesadocontacto', COALESCE(_info_contacto_interesados_restriccion._interesado_contacto_, '[]')))
	 ORDER BY lc_interesado.t_id) FILTER (WHERE lc_interesado.t_id IS NOT NULL) AS _interesado_
	 FROM _restriccion_interesados LEFT JOIN test_ladm_col_queries.lc_interesado ON lc_interesado.t_id = _restriccion_interesados.interesado_lc_interesado
	 LEFT JOIN test_ladm_col_queries.lc_interesadodocumentotipo ON lc_interesadodocumentotipo.t_id = lc_interesado.tipo_documento
	 LEFT JOIN _info_contacto_interesados_restriccion ON _info_contacto_interesados_restriccion.lc_interesado = lc_interesado.t_id
	 GROUP BY _restriccion_interesados.t_id
 ),
 _info_contacto_interesado_agrupacion_interesados_restriccion AS (
		SELECT lc_interesadocontacto.lc_interesado,
		  JSON_AGG(
				JSON_BUILD_OBJECT('id', lc_interesadocontacto.t_id,
									   'attributes', JSON_BUILD_OBJECT('Teléfono 1', lc_interesadocontacto.telefono1,
																	   'Teléfono 2', lc_interesadocontacto.telefono2,
																	   'Domicilio notificación', lc_interesadocontacto.domicilio_notificacion,
																	   'Correo electrónico', lc_interesadocontacto.correo_electronico)) ORDER BY lc_interesadocontacto.t_id)
		FILTER(WHERE lc_interesadocontacto.t_id IS NOT NULL) AS _interesado_contacto_
		FROM test_ladm_col_queries.lc_interesadocontacto LEFT JOIN _restriccion_interesados ON _restriccion_interesados.interesado_lc_interesado = lc_interesadocontacto.lc_interesado
		WHERE lc_interesadocontacto.lc_interesado IN (SELECT DISTINCT _restriccion_agrupacion_interesados.interesado_lc_interesado FROM _restriccion_agrupacion_interesados)
		GROUP BY lc_interesadocontacto.lc_interesado
 ),
 _info_interesados_agrupacion_interesados_restriccion AS (
	 SELECT _restriccion_agrupacion_interesados.interesado_lc_agrupacioninteresados,
	  JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_interesado.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo', (SELECT dispname FROM test_ladm_col_queries.lc_interesadotipo WHERE t_id = lc_interesado.tipo),
						                                  lc_interesadodocumentotipo.dispname, lc_interesado.documento_identidad,
														  'Nombre', lc_interesado.nombre,
														  'Género', (SELECT dispname FROM test_ladm_col_queries.lc_sexotipo WHERE t_id = lc_interesado.sexo),
														  'lc_interesadocontacto', COALESCE(_info_contacto_interesado_agrupacion_interesados_restriccion._interesado_contacto_, '[]'),
														  'fraccion', ROUND((fraccion.numerador::numeric/fraccion.denominador::numeric)*100,2) ))
	 ORDER BY lc_interesado.t_id) FILTER (WHERE lc_interesado.t_id IS NOT NULL) AS _interesado_
	 FROM _restriccion_agrupacion_interesados LEFT JOIN test_ladm_col_queries.lc_interesado ON lc_interesado.t_id = _restriccion_agrupacion_interesados.interesado_lc_interesado
   LEFT JOIN test_ladm_col_queries.lc_interesadodocumentotipo ON lc_interesadodocumentotipo.t_id = lc_interesado.tipo_documento
	 LEFT JOIN _info_contacto_interesado_agrupacion_interesados_restriccion ON _info_contacto_interesado_agrupacion_interesados_restriccion.lc_interesado = lc_interesado.t_id
	 LEFT JOIN test_ladm_col_queries.col_miembros ON (col_miembros.agrupacion::text || col_miembros.interesado_lc_interesado::text) = (_restriccion_agrupacion_interesados.interesado_lc_agrupacioninteresados::text|| lc_interesado.t_id::text)
	 LEFT JOIN test_ladm_col_queries.fraccion ON col_miembros.t_id = fraccion.col_miembros_participacion
	 GROUP BY _restriccion_agrupacion_interesados.interesado_lc_agrupacioninteresados
 ),
 _info_agrupacion_interesados_restriccion AS (
	 SELECT lc_restriccion.t_id,
	 JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_agrupacioninteresados.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo de agrupación de interesados', (SELECT dispname FROM test_ladm_col_queries.col_grupointeresadotipo WHERE t_id = lc_agrupacioninteresados.tipo),
														  'Nombre', lc_agrupacioninteresados.nombre,
														  'lc_interesado', COALESCE(_info_interesados_agrupacion_interesados_restriccion._interesado_, '[]')))
	 ORDER BY lc_agrupacioninteresados.t_id) FILTER (WHERE lc_agrupacioninteresados.t_id IS NOT NULL) AS _agrupacioninteresados_
	 FROM test_ladm_col_queries.lc_agrupacioninteresados LEFT JOIN test_ladm_col_queries.lc_restriccion ON lc_agrupacioninteresados.t_id = lc_restriccion.interesado_lc_agrupacioninteresados
	 LEFT JOIN _info_interesados_agrupacion_interesados_restriccion ON _info_interesados_agrupacion_interesados_restriccion.interesado_lc_agrupacioninteresados = lc_agrupacioninteresados.t_id
	 WHERE lc_agrupacioninteresados.t_id IN (SELECT DISTINCT _restriccion_agrupacion_interesados.interesado_lc_agrupacioninteresados FROM _restriccion_agrupacion_interesados)
	 AND lc_restriccion.t_id IN (SELECT _restricciones_seleccionadas.t_id FROM _restricciones_seleccionadas)
	 GROUP BY lc_restriccion.t_id
 ),
 _info_fuentes_administrativas_restriccion AS (
	SELECT lc_restriccion.t_id,
	 JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_fuenteadministrativa.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo de fuente administrativa', (SELECT dispname FROM test_ladm_col_queries.lc_fuenteadministrativatipo WHERE t_id = lc_fuenteadministrativa.tipo),
														  'Ente emisor', lc_fuenteadministrativa.ente_emisor,
														  'Estado disponibilidad', (SELECT dispname FROM test_ladm_col_queries.col_estadodisponibilidadtipo WHERE t_id = lc_fuenteadministrativa.estado_disponibilidad),
														  'Archivo fuente', extarchivo.datos))
	 ORDER BY lc_fuenteadministrativa.t_id) FILTER (WHERE lc_fuenteadministrativa.t_id IS NOT NULL) AS _fuenteadministrativa_
	FROM test_ladm_col_queries.lc_restriccion
	LEFT JOIN test_ladm_col_queries.col_rrrfuente ON lc_restriccion.t_id =col_rrrfuente.rrr_lc_restriccion
	LEFT JOIN test_ladm_col_queries.lc_fuenteadministrativa ON col_rrrfuente.fuente_administrativa = lc_fuenteadministrativa.t_id
	LEFT JOIN test_ladm_col_queries.extarchivo ON extarchivo.lc_fuenteadministrtiva_ext_archivo_id = lc_fuenteadministrativa.t_id
	WHERE lc_restriccion.t_id IN (SELECT _restricciones_seleccionadas.t_id FROM _restricciones_seleccionadas)
    GROUP BY lc_restriccion.t_id
 ),
_info_restriccion AS (
  SELECT lc_restriccion.unidad,
	JSON_AGG(
		JSON_BUILD_OBJECT('id', lc_restriccion.t_id,
						  'attributes', JSON_BUILD_OBJECT('Tipo de restricción', (SELECT dispname FROM test_ladm_col_queries.lc_restricciontipo WHERE t_id = lc_restriccion.tipo),
														  'Descripción', lc_restriccion.descripcion,
														  'lc_fuenteadministrativa', COALESCE(_info_fuentes_administrativas_restriccion._fuenteadministrativa_, '[]'),
														  'lc_interesado', COALESCE(_info_interesados_restriccion._interesado_, '[]'),
														  'lc_agrupacioninteresados', COALESCE(_info_agrupacion_interesados_restriccion._agrupacioninteresados_, '[]')))
	 ORDER BY lc_restriccion.t_id) FILTER (WHERE lc_restriccion.t_id IS NOT NULL) AS _restriccion_
  FROM test_ladm_col_queries.lc_restriccion LEFT JOIN _info_fuentes_administrativas_restriccion ON lc_restriccion.t_id = _info_fuentes_administrativas_restriccion.t_id
  LEFT JOIN _info_interesados_restriccion ON lc_restriccion.t_id = _info_interesados_restriccion.t_id
  LEFT JOIN _info_agrupacion_interesados_restriccion ON lc_restriccion.t_id = _info_agrupacion_interesados_restriccion.t_id
  WHERE lc_restriccion.t_id IN (SELECT * FROM _restricciones_seleccionadas)
  GROUP BY lc_restriccion.unidad
),
 _info_predio AS (
	 SELECT col_uebaunit.ue_lc_terreno,
			JSON_AGG(JSON_BUILD_OBJECT('id', lc_predio.t_id,
							  'attributes', JSON_BUILD_OBJECT('Nombre', lc_predio.nombre,
															  'Id operación', lc_predio.id_operacion,
															  'FMI', (lc_predio.codigo_orip || '-'|| lc_predio.matricula_inmobiliaria),
															  'Número predial', lc_predio.numero_predial,
															  'Número predial anterior', lc_predio.numero_predial_anterior,
															  'lc_derecho', COALESCE(_info_derecho._derecho_, '[]'),
															  'lc_restriccion', COALESCE(_info_restriccion._restriccion_, '[]')
															 )) ORDER BY lc_predio.t_id) FILTER(WHERE lc_predio.t_id IS NOT NULL) AS _predio_
	 FROM test_ladm_col_queries.lc_predio LEFT JOIN test_ladm_col_queries.col_uebaunit ON col_uebaunit.baunit = lc_predio.t_id
     LEFT JOIN _info_derecho ON _info_derecho.unidad = lc_predio.t_id
	 LEFT JOIN _info_restriccion ON _info_restriccion.unidad = lc_predio.t_id
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
	 FROM test_ladm_col_queries.lc_terreno LEFT JOIN _info_predio ON lc_terreno.t_id = _info_predio.ue_lc_terreno
	 WHERE lc_terreno.t_id IN (SELECT * FROM _terrenos_seleccionados)
	 ORDER BY lc_terreno.t_id
 )
SELECT JSON_BUILD_OBJECT('lc_terreno', JSON_AGG(_info_terreno._terreno_)) FROM _info_terreno