WITH
 unidad_avaluo_predio AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename LIKE 'op_predio' AND columnname LIKE 'avaluo_predio' LIMIT 1
 ),
 unidad_avaluo_terreno AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename = 'op_terreno' AND columnname = 'avaluo_terreno' LIMIT 1
 ),
 unidad_area_terreno AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename = 'op_terreno' AND columnname = 'area_terreno' LIMIT 1
 ),
 unidad_avaluo_construccion AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename = 'op_construccion' AND columnname = 'avaluo_construccion' LIMIT 1
 ),
 unidad_area_construida_uc AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename = 'op_unidadconstruccion' AND columnname = 'area_construida' LIMIT 1
 ),
 unidad_avaluo_uc AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename = 'op_unidadconstruccion' AND columnname = 'avaluo_unidad_construccion' LIMIT 1
 ),
 unidad_valor_m2_construccion_u_c AS (
	 SELECT ' [' || setting || ']' FROM operacion.t_ili2db_column_prop WHERE tablename = 'av_unidad_construccion' AND columnname = 'valor_m2_construccion' LIMIT 1
 ),
 terrenos_seleccionados AS (
	SELECT 764 AS ue_op_terreno WHERE '764' <> 'NULL'
		UNION
	SELECT uebaunit.ue_op_terreno FROM operacion.op_predio LEFT JOIN operacion.uebaunit ON op_predio.t_id = uebaunit.baunit  WHERE uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT uebaunit.ue_op_terreno FROM operacion.op_predio LEFT JOIN operacion.uebaunit ON op_predio.t_id = uebaunit.baunit  WHERE uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial = 'NULL' END
		UNION
	SELECT uebaunit.ue_op_terreno FROM operacion.op_predio LEFT JOIN operacion.uebaunit ON op_predio.t_id = uebaunit.baunit  WHERE uebaunit.ue_op_terreno IS NOT NULL AND CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial_anterior = 'NULL' END
 ),
 predios_seleccionados AS (
	SELECT uebaunit.baunit as t_id FROM operacion.uebaunit WHERE uebaunit.ue_op_terreno = 764 AND '764' <> 'NULL'
		UNION
	SELECT t_id FROM operacion.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria) = 'NULL' END
		UNION
	SELECT t_id FROM operacion.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial = 'NULL' END
		UNION
	SELECT t_id FROM operacion.op_predio WHERE CASE WHEN 'NULL' = 'NULL' THEN  1 = 2 ELSE op_predio.numero_predial_anterior = 'NULL' END
 ),
 construcciones_seleccionadas AS (
	 SELECT ue_op_construccion FROM operacion.uebaunit WHERE uebaunit.baunit IN (SELECT predios_seleccionados.t_id FROM predios_seleccionados WHERE predios_seleccionados.t_id IS NOT NULL) AND ue_op_construccion IS NOT NULL
 ),
 unidadesconstruccion_seleccionadas AS (
	 SELECT op_unidadconstruccion.t_id FROM operacion.op_unidadconstruccion WHERE op_unidadconstruccion.construccion IN (SELECT ue_op_construccion FROM construcciones_seleccionadas)
 ),
 info_uc AS (
	 SELECT op_unidadconstruccion.construccion,
			json_agg(json_build_object('id', op_unidadconstruccion.t_id,
							  'attributes', json_build_object(CONCAT('Avalúo' , (SELECT * FROM unidad_avaluo_uc)), op_unidadconstruccion.avaluo_unidad_construccion
															  , CONCAT('Área construida' , (SELECT * FROM unidad_area_construida_uc)), op_unidadconstruccion.area_construida
															  , CONCAT('Área privada construida' , (SELECT * FROM unidad_area_construida_uc)), op_unidadconstruccion.area_privada_construida
															  , 'Número de pisos', op_unidadconstruccion.numero_pisos
															  , 'Ubicación en el piso', op_unidadconstruccion.piso_ubicacion
															  , 'Uso',  op_unidadconstruccion.uso
															  , 'Tipología',  av_unidad_construccion.tipo_unidad_construccion
															  , 'Puntuación',  av_unidad_construccion.puntuacion
															  , CONCAT('Valor m2 construcción' , (SELECT * FROM unidad_valor_m2_construccion_u_c)),  av_unidad_construccion.valor_m2_construccion
															  , 'Año construcción',  av_unidad_construccion.anio_construccion
															 )) ORDER BY op_unidadconstruccion.t_id) FILTER(WHERE op_unidadconstruccion.t_id IS NOT NULL)  as op_unidadconstruccion
	 FROM operacion.op_unidadconstruccion
	 LEFT JOIN operacion.av_unidad_construccion ON op_unidadconstruccion.t_id = av_unidad_construccion.op_unidad_construccion
	 WHERE op_unidadconstruccion.t_id IN (SELECT * FROM unidadesconstruccion_seleccionadas)
	 GROUP BY op_unidadconstruccion.construccion
 ),
 info_construccion as (
	 SELECT uebaunit.baunit,
			json_agg(json_build_object('id', op_construccion.t_id,
							  'attributes', json_build_object(CONCAT('Avalúo' , (SELECT * FROM unidad_avaluo_construccion)), op_construccion.avaluo_construccion,
															  'Área construcción', op_construccion.area_construccion,
															  'op_unidadconstruccion', COALESCE(info_uc.op_unidadconstruccion, '[]')
															 )) ORDER BY op_construccion.t_id) FILTER(WHERE op_construccion.t_id IS NOT NULL) as op_construccion
	 FROM operacion.op_construccion
	 LEFT JOIN info_uc ON op_construccion.t_id = info_uc.construccion
     LEFT JOIN operacion.uebaunit ON uebaunit.ue_op_construccion = op_construccion.t_id
	 WHERE op_construccion.t_id IN (SELECT * FROM construcciones_seleccionadas)
	 GROUP BY uebaunit.baunit
 ),
info_predio AS (
	 SELECT uebaunit.ue_op_terreno,
			json_agg(json_build_object('id', op_predio.t_id,
							  'attributes', json_build_object('Nombre', op_predio.nombre,
															  'Departamento', op_predio.departamento,
															  'Municipio', op_predio.municipio,
															  'NUPRE', op_predio.nupre,
															  'FMI', (op_predio.codigo_orip || '-'|| op_predio.matricula_inmobiliaria),
															  'Número predial', op_predio.numero_predial,
															  'Número predial anterior', op_predio.numero_predial_anterior,
															  CONCAT('Avalúo predio' , (select * from unidad_avaluo_predio)), op_predio.avaluo_predio,
															  'Tipo', op_predio.tipo,
															  'Destinación económica', fcm_formulario_unico_cm.destinacion_economica,
															  'op_construccion', COALESCE(info_construccion.op_construccion, '[]')
															 )) ORDER BY op_predio.t_id) FILTER(WHERE op_predio.t_id IS NOT NULL) as op_predio
	 FROM operacion.op_predio LEFT JOIN operacion.uebaunit ON uebaunit.baunit = op_predio.t_id
	 LEFT JOIN info_construccion ON op_predio.t_id = info_construccion.baunit
	 LEFT JOIN operacion.fcm_formulario_unico_cm ON fcm_formulario_unico_cm.op_predio = op_predio.t_id
	 WHERE op_predio.t_id IN (SELECT * FROM predios_seleccionados)
	 AND uebaunit.ue_op_terreno IS NOT NULL
	 AND uebaunit.ue_op_construccion IS NULL
	 AND uebaunit.ue_op_unidadconstruccion IS NULL
	 GROUP BY uebaunit.ue_op_terreno
 ),
 info_zona_homogenea_geoeconomica AS (
	SELECT op_terreno.t_id,
		json_agg(
				json_build_object('id', av_zona_homogenea_geoeconomica.t_id,
									   'attributes', json_build_object('Porcentaje', ROUND((st_area(st_intersection(op_terreno.poligono_creado, av_zona_homogenea_geoeconomica.geometria))/ st_area(op_terreno.poligono_creado))::numeric * 100,2),
									                                   'Valor', av_zona_homogenea_geoeconomica.valor,
																	   'Identificador', av_zona_homogenea_geoeconomica.identificador))
		ORDER BY av_zona_homogenea_geoeconomica.t_id) FILTER(WHERE av_zona_homogenea_geoeconomica.t_id IS NOT NULL) AS zona_homogenea_geoeconomica
	FROM operacion.op_terreno, operacion.av_zona_homogenea_geoeconomica
    WHERE op_terreno.t_id IN (SELECT * FROM terrenos_seleccionados) AND
		  st_intersects(op_terreno.poligono_creado, av_zona_homogenea_geoeconomica.geometria) = True AND
		  st_area(st_intersection(op_terreno.poligono_creado, av_zona_homogenea_geoeconomica.geometria)) > 0
	GROUP BY op_terreno.t_id
 ),
 info_zona_homogenea_fisica AS (
	SELECT op_terreno.t_id,
		json_agg(
				json_build_object('id', av_zona_homogenea_fisica.t_id,
									   'attributes', json_build_object('Porcentaje', ROUND((st_area(st_intersection(op_terreno.poligono_creado, av_zona_homogenea_fisica.geometria))/ st_area(op_terreno.poligono_creado))::numeric * 100, 2),
																	   'Identificador', av_zona_homogenea_fisica.identificador))
		ORDER BY av_zona_homogenea_fisica.t_id) FILTER(WHERE av_zona_homogenea_fisica.t_id IS NOT NULL) AS zona_homogenea_fisica
	FROM operacion.op_terreno, operacion.av_zona_homogenea_fisica
    WHERE op_terreno.t_id IN (SELECT * FROM terrenos_seleccionados) AND
		  st_intersects(op_terreno.poligono_creado, av_zona_homogenea_fisica.geometria) = True AND
		  st_area(st_intersection(op_terreno.poligono_creado, av_zona_homogenea_fisica.geometria)) > 0
	GROUP BY op_terreno.t_id
 ),
 info_terreno AS (
	SELECT op_terreno.t_id,
      json_build_object('id', op_terreno.t_id,
						'attributes', json_build_object(CONCAT('Avalúo terreno', (SELECT * FROM unidad_avaluo_terreno)), op_terreno.Avaluo_Terreno
													    , CONCAT('Área de terreno' , (SELECT * FROM unidad_area_terreno)), op_terreno.area_terreno
														, 'zona_homogenea_geoeconomica', COALESCE(info_zona_homogenea_geoeconomica.zona_homogenea_geoeconomica, '[]')
														, 'zona_homogenea_fisica', COALESCE(info_zona_homogenea_fisica.zona_homogenea_fisica, '[]')
														, 'predio', COALESCE(info_predio.op_predio, '[]')
													   )) as op_terreno
    FROM operacion.op_terreno LEFT JOIN info_predio ON info_predio.ue_op_terreno = op_terreno.t_id
    LEFT JOIN info_zona_homogenea_geoeconomica ON info_zona_homogenea_geoeconomica.t_id = op_terreno.t_id
    LEFT JOIN info_zona_homogenea_fisica ON info_zona_homogenea_fisica.t_id = op_terreno.t_id
	WHERE op_terreno.t_id IN (SELECT * FROM terrenos_seleccionados)
	ORDER BY op_terreno.t_id
 )
SELECT json_agg(info_terreno.op_terreno) AS terreno FROM info_terreno
