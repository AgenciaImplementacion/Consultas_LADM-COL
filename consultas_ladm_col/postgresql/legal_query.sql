WITH
 unidad_area_calculada_terreno AS (
	 SELECT ' [' || setting || ']' FROM fdm.t_ili2db_column_prop WHERE tablename = 'terreno' AND columnname = 'area_calculada' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 13117 AS ue_terreno WHERE '13117' <> 'NULL'
		UNION
	SELECT uebaunit.ue_terreno FROM fdm.predio LEFT JOIN fdm.uebaunit ON predio.t_id = uebaunit.baunit_predio  WHERE uebaunit.ue_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.fmi = 'NULL' END
		UNION
	SELECT uebaunit.ue_terreno FROM fdm.predio LEFT JOIN fdm.uebaunit ON predio.t_id = uebaunit.baunit_predio  WHERE uebaunit.ue_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial = 'NULL' END
		UNION
	SELECT uebaunit.ue_terreno FROM fdm.predio LEFT JOIN fdm.uebaunit ON predio.t_id = uebaunit.baunit_predio  WHERE uebaunit.ue_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT uebaunit.baunit_predio as t_id FROM fdm.uebaunit WHERE uebaunit.ue_terreno = 13117 AND '13117' <> 'NULL'
		UNION
	SELECT t_id FROM fdm.predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.fmi = 'NULL' END
		UNION
	SELECT t_id FROM fdm.predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM fdm.predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE predio.numero_predial_anterior = 'NULL' END
 ),
 derechos_seleccionados AS (
	 SELECT DISTINCT col_derecho.t_id FROM fdm.col_derecho WHERE col_derecho.unidad_predio IN (SELECT * FROM predios_seleccionados)
 ),
 derecho_interesados AS (
	 SELECT DISTINCT col_derecho.interesado_col_interesado, col_derecho.t_id FROM fdm.col_derecho WHERE col_derecho.t_id IN (SELECT * FROM derechos_seleccionados) AND col_derecho.interesado_col_interesado IS NOT NULL
 ),
 derecho_agrupacion_interesados AS (
	 SELECT DISTINCT col_derecho.interesado_la_agrupacion_interesados, miembros.interesados_col_interesado
	 FROM fdm.col_derecho LEFT JOIN fdm.miembros ON col_derecho.interesado_la_agrupacion_interesados = miembros.agrupacion
	 WHERE col_derecho.t_id IN (SELECT * FROM derechos_seleccionados) AND col_derecho.interesado_la_agrupacion_interesados IS NOT NULL
 ),
  restricciones_seleccionadas AS (
	 SELECT DISTINCT col_restriccion.t_id FROM fdm.col_restriccion WHERE col_restriccion.unidad_predio IN (SELECT * FROM predios_seleccionados)
 ),
 restriccion_interesados AS (
	 SELECT DISTINCT col_restriccion.interesado_col_interesado, col_restriccion.t_id FROM fdm.col_restriccion WHERE col_restriccion.t_id IN (SELECT * FROM restricciones_seleccionadas) AND col_restriccion.interesado_col_interesado IS NOT NULL
 ),
 restriccion_agrupacion_interesados AS (
	 SELECT DISTINCT col_restriccion.interesado_la_agrupacion_interesados, miembros.interesados_col_interesado
	 FROM fdm.col_restriccion LEFT JOIN fdm.miembros ON col_restriccion.interesado_la_agrupacion_interesados = miembros.agrupacion
	 WHERE col_restriccion.t_id IN (SELECT * FROM restricciones_seleccionadas) AND col_restriccion.interesado_la_agrupacion_interesados IS NOT NULL
 ),
 responsabilidades_seleccionadas AS (
	 SELECT DISTINCT col_responsabilidad.t_id FROM fdm.col_responsabilidad WHERE col_responsabilidad.unidad_predio IN (SELECT * FROM predios_seleccionados)
 ),
 responsabilidades_interesados AS (
	 SELECT DISTINCT col_responsabilidad.interesado_col_interesado, col_responsabilidad.t_id FROM fdm.col_responsabilidad WHERE col_responsabilidad.t_id IN (SELECT * FROM responsabilidades_seleccionadas) AND col_responsabilidad.interesado_col_interesado IS NOT NULL
 ),
 responsabilidades_agrupacion_interesados AS (
	 SELECT DISTINCT col_responsabilidad.interesado_la_agrupacion_interesados, miembros.interesados_col_interesado
	 FROM fdm.col_responsabilidad LEFT JOIN fdm.miembros ON col_responsabilidad.interesado_la_agrupacion_interesados = miembros.agrupacion
	 WHERE col_responsabilidad.t_id IN (SELECT * FROM responsabilidades_seleccionadas) AND col_responsabilidad.interesado_la_agrupacion_interesados IS NOT NULL
 ),
 hipotecas_seleccionadas AS (
	 SELECT DISTINCT col_hipoteca.t_id FROM fdm.col_hipoteca WHERE col_hipoteca.unidad_predio IN (SELECT * FROM predios_seleccionados)
 ),
 hipotecas_interesados AS (
	 SELECT DISTINCT col_hipoteca.interesado_col_interesado, col_hipoteca.t_id FROM fdm.col_hipoteca WHERE col_hipoteca.t_id IN (SELECT * FROM hipotecas_seleccionadas) AND col_hipoteca.interesado_col_interesado IS NOT NULL
 ),
 hipotecas_agrupacion_interesados AS (
	 SELECT DISTINCT col_hipoteca.interesado_la_agrupacion_interesados, miembros.interesados_col_interesado
	 FROM fdm.col_hipoteca LEFT JOIN fdm.miembros ON col_hipoteca.interesado_la_agrupacion_interesados = miembros.agrupacion
	 WHERE col_hipoteca.t_id IN (SELECT * FROM hipotecas_seleccionadas) AND col_hipoteca.interesado_la_agrupacion_interesados IS NOT NULL
 ),
------------------------------------------------------------------------------------------
-- INFO DERECHOS
------------------------------------------------------------------------------------------
 info_contacto_interesados_derecho AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN derecho_interesados ON derecho_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT derecho_interesados.interesado_col_interesado FROM derecho_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_derecho AS (
	 SELECT derecho_interesados.t_id,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Tipo', col_interesado.tipo,
														  'Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesados_derecho.interesado_contacto, '[]')))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM derecho_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = derecho_interesados.interesado_col_interesado
	 LEFT JOIN info_contacto_interesados_derecho ON info_contacto_interesados_derecho.interesado = col_interesado.t_id
	 GROUP BY derecho_interesados.t_id
 ),
 info_contacto_interesado_agrupacion_interesados_derecho AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN derecho_interesados ON derecho_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT DISTINCT derecho_agrupacion_interesados.interesados_col_interesado FROM derecho_agrupacion_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_agrupacion_interesados_derecho AS (
	 SELECT derecho_agrupacion_interesados.interesado_la_agrupacion_interesados,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesado_agrupacion_interesados_derecho.interesado_contacto, '[]'),
														  'fraccion', ROUND((fraccion.numerador::numeric/fraccion.denominador::numeric)*100,2) ))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM derecho_agrupacion_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = derecho_agrupacion_interesados.interesados_col_interesado
	 LEFT JOIN info_contacto_interesado_agrupacion_interesados_derecho ON info_contacto_interesado_agrupacion_interesados_derecho.interesado = col_interesado.t_id
	 LEFT JOIN fdm.miembros ON (miembros.agrupacion::text || miembros.interesados_col_interesado::text) = (derecho_agrupacion_interesados.interesado_la_agrupacion_interesados::text|| col_interesado.t_id::text)
	 LEFT JOIN fdm.fraccion ON miembros.t_id = fraccion.miembros_participacion
	 GROUP BY derecho_agrupacion_interesados.interesado_la_agrupacion_interesados
 ),
 info_agrupacion_interesados AS (
	 SELECT col_derecho.t_id,
	 json_agg(
		json_build_object('id', la_agrupacion_interesados.t_id,
						  'attributes', json_build_object('Tipo de agrupación de interesados', la_agrupacion_interesados.ai_tipo,
														  'Nombre', la_agrupacion_interesados.nombre,
														  'col_interesado', COALESCE(info_interesados_agrupacion_interesados_derecho.col_interesado, '[]')))
	 ) FILTER (WHERE la_agrupacion_interesados.t_id IS NOT NULL) AS la_agrupacion_interesados
	 FROM fdm.la_agrupacion_interesados LEFT JOIN fdm.col_derecho ON la_agrupacion_interesados.t_id = col_derecho.interesado_la_agrupacion_interesados
	 LEFT JOIN info_interesados_agrupacion_interesados_derecho ON info_interesados_agrupacion_interesados_derecho.interesado_la_agrupacion_interesados = la_agrupacion_interesados.t_id
	 WHERE la_agrupacion_interesados.t_id IN (SELECT DISTINCT derecho_agrupacion_interesados.interesado_la_agrupacion_interesados FROM derecho_agrupacion_interesados)
	 AND col_derecho.t_id IN (SELECT derechos_seleccionados.t_id FROM derechos_seleccionados)
	 GROUP BY col_derecho.t_id
 ),
 info_fuentes_administrativas_derecho AS (
	SELECT col_derecho.t_id,
	 json_agg(
		json_build_object('id', col_fuenteadministrativa.t_id,
						  'attributes', json_build_object('Tipo de fuente administrativa', col_fuenteadministrativa.tipo,
														  'Estado disponibilidad', col_fuenteadministrativa.estado_disponibilidad,
														  'Archivo fuente', extarchivo.datos))
	 ) FILTER (WHERE col_fuenteadministrativa.t_id IS NOT NULL) AS col_fuenteadministrativa
	FROM fdm.col_derecho
	LEFT JOIN fdm.rrrfuente ON col_derecho.t_id = rrrfuente.rrr_col_derecho
	LEFT JOIN fdm.col_fuenteadministrativa ON rrrfuente.rfuente = col_fuenteadministrativa.t_id
	LEFT JOIN fdm.extarchivo ON extarchivo.col_fuenteadminstrtiva_ext_archivo_id = col_fuenteadministrativa.t_id
	WHERE col_derecho.t_id IN (SELECT derechos_seleccionados.t_id FROM derechos_seleccionados)
    GROUP BY col_derecho.t_id
 ),
info_derecho AS (
  SELECT col_derecho.unidad_predio,
	json_agg(
		json_build_object('id', col_derecho.t_id,
						  'attributes', json_build_object('Tipo de derecho', col_derecho.tipo,
														  'Código registral', col_derecho.codigo_registral_derecho,
														  'Descripción', col_derecho.descripcion,
														  'col_fuenteadministrativa', COALESCE(info_fuentes_administrativas_derecho.col_fuenteadministrativa, '[]'),
														  CASE WHEN info_agrupacion_interesados.la_agrupacion_interesados IS NOT NULL THEN 'la_agrupacion_interesados' ELSE 'col_interesado' END, CASE WHEN info_agrupacion_interesados.la_agrupacion_interesados IS NOT NULL THEN COALESCE(info_agrupacion_interesados.la_agrupacion_interesados, '[]') ELSE COALESCE(info_interesados_derecho.col_interesado, '[]') END))
	 ) FILTER (WHERE col_derecho.t_id IS NOT NULL) AS col_derecho
  FROM fdm.col_derecho LEFT JOIN info_fuentes_administrativas_derecho ON col_derecho.t_id = info_fuentes_administrativas_derecho.t_id
  LEFT JOIN info_interesados_derecho ON col_derecho.t_id = info_interesados_derecho.t_id
  LEFT JOIN info_agrupacion_interesados ON col_derecho.t_id = info_agrupacion_interesados.t_id
  WHERE col_derecho.t_id IN (SELECT * FROM derechos_seleccionados)
  GROUP BY col_derecho.unidad_predio
),
------------------------------------------------------------------------------------------
-- INFO RESTRICCIONES
------------------------------------------------------------------------------------------
 info_contacto_interesados_restriccion AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN restriccion_interesados ON restriccion_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT restriccion_interesados.interesado_col_interesado FROM restriccion_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_restriccion AS (
	 SELECT restriccion_interesados.t_id,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Tipo', col_interesado.tipo,
														  'Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesados_restriccion.interesado_contacto, '[]')))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM restriccion_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = restriccion_interesados.interesado_col_interesado
	 LEFT JOIN info_contacto_interesados_restriccion ON info_contacto_interesados_restriccion.interesado = col_interesado.t_id
	 GROUP BY restriccion_interesados.t_id
 ),
 info_contacto_interesado_agrupacion_interesados_restriccion AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN restriccion_interesados ON restriccion_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT DISTINCT restriccion_agrupacion_interesados.interesados_col_interesado FROM restriccion_agrupacion_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_agrupacion_interesados_restriccion AS (
	 SELECT restriccion_agrupacion_interesados.interesado_la_agrupacion_interesados,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesado_agrupacion_interesados_restriccion.interesado_contacto, '[]'),
														  'fraccion', ROUND((fraccion.numerador::numeric/fraccion.denominador::numeric)*100,2) ))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM restriccion_agrupacion_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = restriccion_agrupacion_interesados.interesados_col_interesado
	 LEFT JOIN info_contacto_interesado_agrupacion_interesados_restriccion ON info_contacto_interesado_agrupacion_interesados_restriccion.interesado = col_interesado.t_id
	 LEFT JOIN fdm.miembros ON (miembros.agrupacion::text || miembros.interesados_col_interesado::text) = (restriccion_agrupacion_interesados.interesado_la_agrupacion_interesados::text|| col_interesado.t_id::text)
	 LEFT JOIN fdm.fraccion ON miembros.t_id = fraccion.miembros_participacion
	 GROUP BY restriccion_agrupacion_interesados.interesado_la_agrupacion_interesados
 ),
 info_agrupacion_interesados_restriccion AS (
	 SELECT col_restriccion.t_id,
	 json_agg(
		json_build_object('id', la_agrupacion_interesados.t_id,
						  'attributes', json_build_object('Tipo de agrupación de interesados', la_agrupacion_interesados.ai_tipo,
														  'Nombre', la_agrupacion_interesados.nombre,
														  'col_interesado', COALESCE(info_interesados_agrupacion_interesados_restriccion.col_interesado, '[]')))
	 ) FILTER (WHERE la_agrupacion_interesados.t_id IS NOT NULL) AS la_agrupacion_interesados
	 FROM fdm.la_agrupacion_interesados LEFT JOIN fdm.col_restriccion ON la_agrupacion_interesados.t_id = col_restriccion.interesado_la_agrupacion_interesados
	 LEFT JOIN info_interesados_agrupacion_interesados_restriccion ON info_interesados_agrupacion_interesados_restriccion.interesado_la_agrupacion_interesados = la_agrupacion_interesados.t_id
	 WHERE la_agrupacion_interesados.t_id IN (SELECT DISTINCT restriccion_agrupacion_interesados.interesado_la_agrupacion_interesados FROM restriccion_agrupacion_interesados)
	 AND col_restriccion.t_id IN (SELECT restricciones_seleccionadas.t_id FROM restricciones_seleccionadas)
	 GROUP BY col_restriccion.t_id
 ),
 info_fuentes_administrativas_restriccion AS (
	SELECT col_restriccion.t_id,
	 json_agg(
		json_build_object('id', col_fuenteadministrativa.t_id,
						  'attributes', json_build_object('Tipo de fuente administrativa', col_fuenteadministrativa.tipo,
														  'Estado disponibilidad', col_fuenteadministrativa.estado_disponibilidad,
														  'Archivo fuente', extarchivo.datos))
	 ) FILTER (WHERE col_fuenteadministrativa.t_id IS NOT NULL) AS col_fuenteadministrativa
	FROM fdm.col_restriccion
	LEFT JOIN fdm.rrrfuente ON col_restriccion.t_id = rrrfuente.rrr_col_restriccion
	LEFT JOIN fdm.col_fuenteadministrativa ON rrrfuente.rfuente = col_fuenteadministrativa.t_id
	LEFT JOIN fdm.extarchivo ON extarchivo.col_fuenteadminstrtiva_ext_archivo_id = col_fuenteadministrativa.t_id
	WHERE col_restriccion.t_id IN (SELECT restricciones_seleccionadas.t_id FROM restricciones_seleccionadas)
    GROUP BY col_restriccion.t_id
 ),
info_restriccion AS (
  SELECT col_restriccion.unidad_predio,
	json_agg(
		json_build_object('id', col_restriccion.t_id,
						  'attributes', json_build_object('Tipo de restricción', col_restriccion.tipo,
														  'Código registral', col_restriccion.codigo_registral_restriccion,
														  'Descripción', col_restriccion.descripcion,
														  'col_fuenteadministrativa', COALESCE(info_fuentes_administrativas_restriccion.col_fuenteadministrativa, '[]'),
														  CASE WHEN info_agrupacion_interesados_restriccion.la_agrupacion_interesados IS NOT NULL THEN 'la_agrupacion_interesados' ELSE 'col_interesado' END, CASE WHEN info_agrupacion_interesados_restriccion.la_agrupacion_interesados IS NOT NULL THEN COALESCE(info_agrupacion_interesados_restriccion.la_agrupacion_interesados, '[]') ELSE COALESCE(info_interesados_restriccion.col_interesado, '[]') END))
	 ) FILTER (WHERE col_restriccion.t_id IS NOT NULL) AS col_restriccion
  FROM fdm.col_restriccion LEFT JOIN info_fuentes_administrativas_restriccion ON col_restriccion.t_id = info_fuentes_administrativas_restriccion.t_id
  LEFT JOIN info_interesados_restriccion ON col_restriccion.t_id = info_interesados_restriccion.t_id
  LEFT JOIN info_agrupacion_interesados_restriccion ON col_restriccion.t_id = info_agrupacion_interesados_restriccion.t_id
  WHERE col_restriccion.t_id IN (SELECT * FROM restricciones_seleccionadas)
  GROUP BY col_restriccion.unidad_predio
),
------------------------------------------------------------------------------------------
-- INFO RESTRICCIONES
------------------------------------------------------------------------------------------
 info_contacto_interesados_responsabilidad AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN responsabilidades_interesados ON responsabilidades_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT responsabilidades_interesados.interesado_col_interesado FROM responsabilidades_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_responsabilidad AS (
	 SELECT responsabilidades_interesados.t_id,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Tipo', col_interesado.tipo,
														  'Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesados_responsabilidad.interesado_contacto, '[]')))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM responsabilidades_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = responsabilidades_interesados.interesado_col_interesado
	 LEFT JOIN info_contacto_interesados_responsabilidad ON info_contacto_interesados_responsabilidad.interesado = col_interesado.t_id
	 GROUP BY responsabilidades_interesados.t_id
 ),
 info_contacto_interesado_agrupacion_interesados_responsabilidad AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN responsabilidades_interesados ON responsabilidades_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT DISTINCT responsabilidades_agrupacion_interesados.interesados_col_interesado FROM responsabilidades_agrupacion_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_agrupacion_interesados_responsabilidad AS (
	 SELECT responsabilidades_agrupacion_interesados.interesado_la_agrupacion_interesados,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesado_agrupacion_interesados_responsabilidad.interesado_contacto, '[]'),
														  'fraccion', ROUND((fraccion.numerador::numeric/fraccion.denominador::numeric)*100,2) ))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM responsabilidades_agrupacion_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = responsabilidades_agrupacion_interesados.interesados_col_interesado
	 LEFT JOIN info_contacto_interesado_agrupacion_interesados_responsabilidad ON info_contacto_interesado_agrupacion_interesados_responsabilidad.interesado = col_interesado.t_id
	 LEFT JOIN fdm.miembros ON (miembros.agrupacion::text || miembros.interesados_col_interesado::text) = (responsabilidades_agrupacion_interesados.interesado_la_agrupacion_interesados::text|| col_interesado.t_id::text)
	 LEFT JOIN fdm.fraccion ON miembros.t_id = fraccion.miembros_participacion
	 GROUP BY responsabilidades_agrupacion_interesados.interesado_la_agrupacion_interesados
 ),
 info_agrupacion_interesados_responsabilidad AS (
	 SELECT col_responsabilidad.t_id,
	 json_agg(
		json_build_object('id', la_agrupacion_interesados.t_id,
						  'attributes', json_build_object('Tipo de agrupación de interesados', la_agrupacion_interesados.ai_tipo,
														  'Nombre', la_agrupacion_interesados.nombre,
														  'col_interesado', COALESCE(info_interesados_agrupacion_interesados_responsabilidad.col_interesado, '[]')))
	 ) FILTER (WHERE la_agrupacion_interesados.t_id IS NOT NULL) AS la_agrupacion_interesados
	 FROM fdm.la_agrupacion_interesados LEFT JOIN fdm.col_responsabilidad ON la_agrupacion_interesados.t_id = col_responsabilidad.interesado_la_agrupacion_interesados
	 LEFT JOIN info_interesados_agrupacion_interesados_responsabilidad ON info_interesados_agrupacion_interesados_responsabilidad.interesado_la_agrupacion_interesados = la_agrupacion_interesados.t_id
	 WHERE la_agrupacion_interesados.t_id IN (SELECT DISTINCT responsabilidades_agrupacion_interesados.interesado_la_agrupacion_interesados FROM responsabilidades_agrupacion_interesados)
	 AND col_responsabilidad.t_id IN (SELECT responsabilidades_seleccionadas.t_id FROM responsabilidades_seleccionadas)
	 GROUP BY col_responsabilidad.t_id
 ),
 info_fuentes_administrativas_responsabilidad AS (
	SELECT col_responsabilidad.t_id,
	 json_agg(
		json_build_object('id', col_fuenteadministrativa.t_id,
						  'attributes', json_build_object('Tipo de fuente administrativa', col_fuenteadministrativa.tipo,
														  'Estado disponibilidad', col_fuenteadministrativa.estado_disponibilidad,
														  'Archivo fuente', extarchivo.datos))
	 ) FILTER (WHERE col_fuenteadministrativa.t_id IS NOT NULL) AS col_fuenteadministrativa
	FROM fdm.col_responsabilidad
	LEFT JOIN fdm.rrrfuente ON col_responsabilidad.t_id = rrrfuente.rrr_col_responsabilidad
	LEFT JOIN fdm.col_fuenteadministrativa ON rrrfuente.rfuente = col_fuenteadministrativa.t_id
	LEFT JOIN fdm.extarchivo ON extarchivo.col_fuenteadminstrtiva_ext_archivo_id = col_fuenteadministrativa.t_id
	WHERE col_responsabilidad.t_id IN (SELECT responsabilidades_seleccionadas.t_id FROM responsabilidades_seleccionadas)
    GROUP BY col_responsabilidad.t_id
 ),
info_responsabilidad AS (
  SELECT col_responsabilidad.unidad_predio,
	json_agg(
		json_build_object('id', col_responsabilidad.t_id,
						  'attributes', json_build_object('Tipo de responsabilidad', col_responsabilidad.tipo,
														  'Código registral', col_responsabilidad.codigo_registral_responsabilidad,
														  'Descripción', col_responsabilidad.descripcion,
														  'col_fuenteadministrativa', COALESCE(info_fuentes_administrativas_responsabilidad.col_fuenteadministrativa, '[]'),
														  CASE WHEN info_agrupacion_interesados_responsabilidad.la_agrupacion_interesados IS NOT NULL THEN 'la_agrupacion_interesados' ELSE 'col_interesado' END, CASE WHEN info_agrupacion_interesados_responsabilidad.la_agrupacion_interesados IS NOT NULL THEN COALESCE(info_agrupacion_interesados_responsabilidad.la_agrupacion_interesados, '[]') ELSE COALESCE(info_interesados_responsabilidad.col_interesado, '[]') END))
	 ) FILTER (WHERE col_responsabilidad.t_id IS NOT NULL) AS col_responsabilidad
  FROM fdm.col_responsabilidad LEFT JOIN info_fuentes_administrativas_responsabilidad ON col_responsabilidad.t_id = info_fuentes_administrativas_responsabilidad.t_id
  LEFT JOIN info_interesados_responsabilidad ON col_responsabilidad.t_id = info_interesados_responsabilidad.t_id
  LEFT JOIN info_agrupacion_interesados_responsabilidad ON col_responsabilidad.t_id = info_agrupacion_interesados_responsabilidad.t_id
  WHERE col_responsabilidad.t_id IN (SELECT * FROM responsabilidades_seleccionadas)
  GROUP BY col_responsabilidad.unidad_predio
),
------------------------------------------------------------------------------------------
-- INFO HIPOTECA
------------------------------------------------------------------------------------------
 info_contacto_interesados_hipoteca AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN hipotecas_interesados ON hipotecas_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT hipotecas_interesados.interesado_col_interesado FROM hipotecas_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_hipoteca AS (
	 SELECT hipotecas_interesados.t_id,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Tipo', col_interesado.tipo,
														  'Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesados_hipoteca.interesado_contacto, '[]')))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM hipotecas_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = hipotecas_interesados.interesado_col_interesado
	 LEFT JOIN info_contacto_interesados_hipoteca ON info_contacto_interesados_hipoteca.interesado = col_interesado.t_id
	 GROUP BY hipotecas_interesados.t_id
 ),
 info_contacto_interesado_agrupacion_interesados_hipoteca AS (
		SELECT interesado_contacto.interesado,
		  json_agg(
				json_build_object('id', interesado_contacto.t_id,
									   'attributes', json_build_object('Teléfono 1', interesado_contacto.telefono1,
																	   'Teléfono 2', interesado_contacto.telefono2,
																	   'Domicilio notificación', interesado_contacto.domicilio_notificacion,
																	   'Correo_Electrónico', interesado_contacto.correo_electronico,
																	   'Origen_de_datos', interesado_contacto.origen_datos)))
		FILTER(WHERE interesado_contacto.t_id IS NOT NULL) AS interesado_contacto
		FROM fdm.interesado_contacto LEFT JOIN hipotecas_interesados ON hipotecas_interesados.interesado_col_interesado = interesado_contacto.interesado
		WHERE interesado_contacto.interesado IN (SELECT DISTINCT hipotecas_agrupacion_interesados.interesados_col_interesado FROM hipotecas_agrupacion_interesados)
		GROUP BY interesado_contacto.interesado
 ),
 info_interesados_agrupacion_interesados_hipoteca AS (
	 SELECT hipotecas_agrupacion_interesados.interesado_la_agrupacion_interesados,
	  json_agg(
		json_build_object('id', col_interesado.t_id,
						  'attributes', json_build_object('Documento de identidad', col_interesado.documento_identidad,
														  'Tipo de documento', col_interesado.tipo_documento,
														  CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN 'Tipo interesado jurídico' ELSE 'Género' END, CASE WHEN col_interesado.tipo = 'Persona_No_Natural' THEN col_interesado.tipo_interesado_juridico ELSE col_interesado.genero END,
														  'Nombre', col_interesado.nombre,
														  'interesado_contacto', COALESCE(info_contacto_interesado_agrupacion_interesados_hipoteca.interesado_contacto, '[]'),
														  'fraccion', ROUND((fraccion.numerador::numeric/fraccion.denominador::numeric)*100,2) ))
	 ) FILTER (WHERE col_interesado.t_id IS NOT NULL) AS col_interesado
	 FROM hipotecas_agrupacion_interesados LEFT JOIN fdm.col_interesado ON col_interesado.t_id = hipotecas_agrupacion_interesados.interesados_col_interesado
	 LEFT JOIN info_contacto_interesado_agrupacion_interesados_hipoteca ON info_contacto_interesado_agrupacion_interesados_hipoteca.interesado = col_interesado.t_id
	 LEFT JOIN fdm.miembros ON (miembros.agrupacion::text || miembros.interesados_col_interesado::text) = (hipotecas_agrupacion_interesados.interesado_la_agrupacion_interesados::text|| col_interesado.t_id::text)
	 LEFT JOIN fdm.fraccion ON miembros.t_id = fraccion.miembros_participacion
	 GROUP BY hipotecas_agrupacion_interesados.interesado_la_agrupacion_interesados
 ),
 info_agrupacion_interesados_hipoteca AS (
	 SELECT col_hipoteca.t_id,
	 json_agg(
		json_build_object('id', la_agrupacion_interesados.t_id,
						  'attributes', json_build_object('Tipo de agrupación de interesados', la_agrupacion_interesados.ai_tipo,
														  'Nombre', la_agrupacion_interesados.nombre,
														  'col_interesado', COALESCE(info_interesados_agrupacion_interesados_hipoteca.col_interesado, '[]')))
	 ) FILTER (WHERE la_agrupacion_interesados.t_id IS NOT NULL) AS la_agrupacion_interesados
	 FROM fdm.la_agrupacion_interesados LEFT JOIN fdm.col_hipoteca ON la_agrupacion_interesados.t_id = col_hipoteca.interesado_la_agrupacion_interesados
	 LEFT JOIN info_interesados_agrupacion_interesados_hipoteca ON info_interesados_agrupacion_interesados_hipoteca.interesado_la_agrupacion_interesados = la_agrupacion_interesados.t_id
	 WHERE la_agrupacion_interesados.t_id IN (SELECT DISTINCT hipotecas_agrupacion_interesados.interesado_la_agrupacion_interesados FROM hipotecas_agrupacion_interesados)
	 AND col_hipoteca.t_id IN (SELECT hipotecas_seleccionadas.t_id FROM hipotecas_seleccionadas)
	 GROUP BY col_hipoteca.t_id
 ),
 info_fuentes_administrativas_hipoteca AS (
	SELECT col_hipoteca.t_id,
	 json_agg(
		json_build_object('id', col_fuenteadministrativa.t_id,
						  'attributes', json_build_object('Tipo de fuente administrativa', col_fuenteadministrativa.tipo,
														  'Estado disponibilidad', col_fuenteadministrativa.estado_disponibilidad,
														  'Archivo fuente', extarchivo.datos))
	 ) FILTER (WHERE col_fuenteadministrativa.t_id IS NOT NULL) AS col_fuenteadministrativa
	FROM fdm.col_hipoteca
	LEFT JOIN fdm.rrrfuente ON col_hipoteca.t_id = rrrfuente.rrr_col_hipoteca
	LEFT JOIN fdm.col_fuenteadministrativa ON rrrfuente.rfuente = col_fuenteadministrativa.t_id
	LEFT JOIN fdm.extarchivo ON extarchivo.col_fuenteadminstrtiva_ext_archivo_id = col_fuenteadministrativa.t_id
	WHERE col_hipoteca.t_id IN (SELECT hipotecas_seleccionadas.t_id FROM hipotecas_seleccionadas)
    GROUP BY col_hipoteca.t_id
 ),
info_hipoteca AS (
  SELECT col_hipoteca.unidad_predio,
	json_agg(
		json_build_object('id', col_hipoteca.t_id,
						  'attributes', json_build_object('Tipo de hipoteca', col_hipoteca.tipo,
														  'Código registral', col_hipoteca.codigo_registral_hipoteca,
														  'Descripción', col_hipoteca.descripcion,
														  'col_fuenteadministrativa', COALESCE(info_fuentes_administrativas_hipoteca.col_fuenteadministrativa, '[]'),
														  CASE WHEN info_agrupacion_interesados_hipoteca.la_agrupacion_interesados IS NOT NULL THEN 'la_agrupacion_interesados' ELSE 'col_interesado' END, CASE WHEN info_agrupacion_interesados_hipoteca.la_agrupacion_interesados IS NOT NULL THEN COALESCE(info_agrupacion_interesados_hipoteca.la_agrupacion_interesados, '[]') ELSE COALESCE(info_interesados_hipoteca.col_interesado, '[]') END))
	 ) FILTER (WHERE col_hipoteca.t_id IS NOT NULL) AS col_hipoteca
  FROM fdm.col_hipoteca LEFT JOIN info_fuentes_administrativas_hipoteca ON col_hipoteca.t_id = info_fuentes_administrativas_hipoteca.t_id
  LEFT JOIN info_interesados_hipoteca ON col_hipoteca.t_id = info_interesados_hipoteca.t_id
  LEFT JOIN info_agrupacion_interesados_hipoteca ON col_hipoteca.t_id = info_agrupacion_interesados_hipoteca.t_id
  WHERE col_hipoteca.t_id IN (SELECT * FROM hipotecas_seleccionadas)
  GROUP BY col_hipoteca.unidad_predio
),
 info_predio AS (
	 SELECT uebaunit.ue_terreno,
			json_agg(json_build_object('id', predio.t_id,
							  'attributes', json_build_object('Nombre', predio.nombre,
															  'NUPRE', predio.nupre,
															  'FMI', predio.fmi,
															  'Número predial', predio.numero_predial,
															  'Número predial anterior', predio.numero_predial_anterior,
															  'col_derecho', COALESCE(info_derecho.col_derecho, '[]'),
															  'col_restriccion', COALESCE(info_restriccion.col_restriccion, '[]'),
															  'col_responsabilidad', COALESCE(info_responsabilidad.col_responsabilidad, '[]'),
															  'col_hipoteca', COALESCE(info_hipoteca.col_hipoteca, '[]')
															 ))) FILTER(WHERE predio.t_id IS NOT NULL) as predio
	 FROM fdm.predio LEFT JOIN fdm.uebaunit ON uebaunit.baunit_predio = predio.t_id
     LEFT JOIN info_derecho ON info_derecho.unidad_predio = predio.t_id
	 LEFT JOIN info_restriccion ON info_restriccion.unidad_predio = predio.t_id
     LEFT JOIN info_responsabilidad ON info_responsabilidad.unidad_predio = predio.t_id
     LEFT JOIN info_hipoteca ON info_hipoteca.unidad_predio = predio.t_id
	 WHERE predio.t_id IN (SELECT * FROM predios_seleccionados)
		AND uebaunit.ue_terreno IS NOT NULL
		AND uebaunit.ue_construccion IS NULL
		AND uebaunit.ue_unidadconstruccion IS NULL
     GROUP BY uebaunit.ue_terreno
 ),
 info_terreno AS (
	 SELECT terreno.t_id,
	 json_build_object('id', terreno.t_id,
						'attributes', json_build_object(CONCAT('Área de terreno' , (SELECT * FROM unidad_area_calculada_terreno)), terreno.area_calculada,
														'predio', COALESCE(info_predio.predio, '[]')
													   )) as terreno
	 FROM fdm.terreno LEFT JOIN info_predio ON terreno.t_id = info_predio.ue_terreno
	 WHERE terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
 )
SELECT json_agg(info_terreno.terreno) AS terreno FROM info_terreno