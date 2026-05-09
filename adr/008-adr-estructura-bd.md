# ADR 008: Organizar scripts SQL por tipo de operacion

## Estado
Aceptado

## Contexto
El proyecto contiene diferentes tipos de scripts SQL: definicion de estructura, datos iniciales, permisos, transacciones y rollbacks. Mezclar todos estos scripts en una sola ubicacion dificulta el mantenimiento y la revision del trabajo en equipo.

## Decision
Se decide organizar los scripts SQL por tipo de operacion usando carpetas separadas, por ejemplo: `01_ddl`, `02_dml`, `03_dcl`, `04_tcl` y `05_rollbacks`.

## Consecuencias
- Los scripts quedan clasificados segun su responsabilidad.
- Es mas facil ubicar cambios de estructura, datos, permisos, transacciones y reversiones.
- El equipo debe respetar la organizacion de carpetas al crear nuevos scripts.
- La documentacion y los changelogs deben apuntar a la ubicacion correcta de cada script.
