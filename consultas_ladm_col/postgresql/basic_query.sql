WITH
 unidad_area_calculada_terreno AS (
	 SELECT ' [' || setting || ']' FROM fdm.t_ili2db_column_prop WHERE tablename = 'terreno' AND columnname = 'area_calculada' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM fdm.t_ili2db_column_prop WHERE tablename = 'unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
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
 construcciones_seleccionadas AS (
	 SELECT ue_construccion FROM fdm.uebaunit WHERE uebaunit.baunit_predio IN (SELECT predios_seleccionados.t_id FROM predios_seleccionados WHERE predios_seleccionados.t_id IS NOT NULL) AND ue_construccion IS NOT NULL
 ),
 unidadesconstruccion_seleccionadas AS (
	 SELECT unidadconstruccion.t_id FROM fdm.unidadconstruccion WHERE unidadconstruccion.construccion IN (SELECT ue_construccion FROM construcciones_seleccionadas)
 ),
 uc_extdireccion AS (
	SELECT extdireccion.unidadconstruccion_ext_direccion_id,
		json_agg(
				json_build_object('id', extdireccion.t_id,
									   'attributes', json_build_object('País', extdireccion.pais,
																	   'Departamento', extdireccion.departamento,
																	   'Ciudad', extdireccion.ciudad,
																	   'Código postal', extdireccion.codigo_postal,
																	   'Apartado correo', extdireccion.apartado_correo,
																	   'Nombre calle', extdireccion.nombre_calle))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM fdm.extdireccion WHERE unidadconstruccion_ext_direccion_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	GROUP BY extdireccion.unidadconstruccion_ext_direccion_id
 ),
 info_uc AS (
	 SELECT unidadconstruccion.construccion,
			json_agg(json_build_object('id', unidadconstruccion.t_id,
							  'attributes', json_build_object('Número de pisos', unidadconstruccion.numero_pisos,
															  CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), unidadconstruccion.area_construida,
															  'Número de habitaciones', unidad_construccion.num_habitaciones,
															  'Número de baños', unidad_construccion.num_banios,
															  'Número de locales', unidad_construccion.num_locales,
															  'Uso', unidad_construccion.uso,
															  'Puntuación', unidad_construccion.puntuacion,
															  'extdireccion', COALESCE(uc_extdireccion.extdireccion, '[]')
															 )) ORDER BY unidadconstruccion.t_id) FILTER(WHERE unidadconstruccion.t_id IS NOT NULL)  as unidadconstruccion
	 FROM fdm.unidadconstruccion LEFT JOIN uc_extdireccion ON unidadconstruccion.t_id = uc_extdireccion.unidadconstruccion_ext_direccion_id
	 LEFT JOIN fdm.avaluounidadconstruccion ON unidadconstruccion.t_id = avaluounidadconstruccion.ucons
	 LEFT JOIN fdm.unidad_construccion ON avaluounidadconstruccion.aucons = unidad_construccion.t_id
	 WHERE unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	 GROUP BY unidadconstruccion.construccion
 ),
 c_extdireccion AS (
	SELECT extdireccion.construccion_ext_direccion_id,
		json_agg(
				json_build_object('id', extdireccion.t_id,
									   'attributes', json_build_object('País', extdireccion.pais,
																	   'Departamento', extdireccion.departamento,
																	   'Ciudad', extdireccion.ciudad,
																	   'Código postal', extdireccion.codigo_postal,
																	   'Apartado correo', extdireccion.apartado_correo,
																	   'Nombre calle', extdireccion.nombre_calle))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM fdm.extdireccion WHERE construccion_ext_direccion_id IN (SELECT * FROM construcciones_seleccionadas)
	GROUP BY extdireccion.construccion_ext_direccion_id
 ),
 info_construccion as (
	 SELECT uebaunit.baunit_predio,
			json_agg(json_build_object('id', construccion.t_id,
							  'attributes', json_build_object('Área construcción', construccion.area_construccion,
															  'extdireccion', COALESCE(c_extdireccion.extdireccion, '[]'),
															  'unidadconstruccion', COALESCE(info_uc.unidadconstruccion, '[]')
															 )) ORDER BY construccion.t_id) FILTER(WHERE construccion.t_id IS NOT NULL) as construccion
	 FROM fdm.construccion LEFT JOIN c_extdireccion ON construccion.t_id = c_extdireccion.construccion_ext_direccion_id
	 LEFT JOIN info_uc ON construccion.t_id = info_uc.construccion
     LEFT JOIN fdm.uebaunit ON uebaunit.ue_construccion = construccion.t_id
	 WHERE construccion.t_id IN (SELECT * FROM construcciones_seleccionadas)
	 GROUP BY uebaunit.baunit_predio
 ),
 info_predio AS (
	 SELECT uebaunit.ue_terreno,
			json_agg(json_build_object('id', predio.t_id,
							  'attributes', json_build_object('Nombre', predio.nombre,
															  'Departamento', predio.departamento,
															  'Municipio', predio.municipio,
															  'Zona', predio.zona,
															  'NUPRE', predio.nupre,
															  'FMI', predio.fmi,
															  'Número predial', predio.numero_predial,
															  'Número predial anterior', predio.numero_predial_anterior,
															  'Tipo', predio.tipo,
																'Destinación económica', predio_ficha.destinacion_economica,
															  'construccion', COALESCE(info_construccion.construccion, '[]')
															 )) ORDER BY predio.t_id) FILTER(WHERE predio.t_id IS NOT NULL) as predio
	 FROM fdm.predio LEFT JOIN fdm.uebaunit ON uebaunit.baunit_predio = predio.t_id
	 LEFT JOIN info_construccion ON predio.t_id = info_construccion.baunit_predio
	 LEFT JOIN fdm.predio_ficha ON predio_ficha.crpredio = predio.t_id
	 WHERE predio.t_id IN (SELECT * FROM predios_seleccionados)
		AND uebaunit.ue_terreno IS NOT NULL
		AND uebaunit.ue_construccion IS NULL
		AND uebaunit.ue_unidadconstruccion IS NULL
		GROUP BY uebaunit.ue_terreno
 ),
 t_extdireccion AS (
	SELECT extdireccion.terreno_ext_direccion_id,
		json_agg(
				json_build_object('id', extdireccion.t_id,
									   'attributes', json_build_object('País', extdireccion.pais,
																	   'Departamento', extdireccion.departamento,
																	   'Ciudad', extdireccion.ciudad,
																	   'Código postal', extdireccion.codigo_postal,
																	   'Apartado correo', extdireccion.apartado_correo,
																	   'Nombre calle', extdireccion.nombre_calle))
		ORDER BY extdireccion.t_id) FILTER(WHERE extdireccion.t_id IS NOT NULL) AS extdireccion
	FROM fdm.extdireccion WHERE terreno_ext_direccion_id IN (SELECT * FROM terrenos_seleccionados)
	GROUP BY extdireccion.terreno_ext_direccion_id
 ),
 info_terreno AS (
	SELECT terreno.t_id,
      json_build_object('id', terreno.t_id,
						'attributes', json_build_object(CONCAT('Área de terreno' , (SELECT * FROM unidad_area_calculada_terreno)), terreno.area_calculada,
														'extdireccion', COALESCE(t_extdireccion.extdireccion, '[]'),
														'predio', COALESCE(info_predio.predio, '[]')
													   )) as terreno
    FROM fdm.terreno LEFT JOIN info_predio ON info_predio.ue_terreno = terreno.t_id
	LEFT JOIN t_extdireccion ON terreno.t_id = t_extdireccion.terreno_ext_direccion_id
	WHERE terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY terreno.t_id
 )
SELECT json_agg(info_terreno.terreno) AS terreno FROM info_terreno

