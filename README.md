# Consultas LADM_COL

Consultas SQL que permiten obtener la información del modelo [LADM_COL](https://github.com/AgenciaImplementacion/LADM_COL).

## Revisión por componentes

La revisión por componentes es una herramienta que permite la consulta de los datos alfanuméricos registrados en la base de datos conforme al modelo [LADM_COL](https://github.com/AgenciaImplementacion/LADM_COL), facilitando a los usuarios el acceso a la información.

- Información básica.
- Información física.
- Información ficha predial.
- Información jurídica.
- Información económica.

## ¿Cómo consultar la información?

Las consultas estan diseñadas para soportar diferentes filtros, entre los criterios soportados se encuentran:

* t_id de un terreno
* Consultar por matrícula Inmobiliaria
* Consultar por número predial
* Consultar por número predial anterior


## Resultado obtenido

Las consultas estan diseñadas para retornar el resultado en formato [JSON](https://www.json.org/). Y la información se encuentra agrupada de forma lógica conforme a la definición del modelo [LADM_COL](https://github.com/AgenciaImplementacion/LADM_COL), por ejemplo las unidades de construcción se encuentran agrupadas por su respectiva construcción.

```js
"parent": [
    {
    "id": 1,
    "attributes": {
        "field_1": 1,
        ...
        "field_2": "test"
        }
    }
]
```