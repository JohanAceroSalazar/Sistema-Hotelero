# ADR 003: Usar nombres en ingles para tablas y columnas

## Estado
Aceptado

## Contexto
El modelo original tenia nombres de tablas y columnas en espanol. Para mejorar consistencia tecnica, compatibilidad con convenciones comunes y lectura por herramientas externas, se requiere una nomenclatura uniforme en ingles.

## Decision
Se decide nombrar tablas, columnas, indices y restricciones en ingles usando `snake_case`. Cuando un nombre puede entrar en conflicto con palabras reservadas o conceptos propios de PostgreSQL, se usara un prefijo aclaratorio, por ejemplo `app_user`, `app_role` y `app_view`.

## Consecuencias
- La base de datos queda alineada con convenciones tecnicas internacionales.
- El equipo debe usar los nombres en ingles en consultas, seeds, documentacion tecnica y futuras migraciones.
- Los scripts antiguos en espanol deben actualizarse antes de integrarse.
