# ADR 005: Usar Liquibase para versionar cambios de base de datos

## Estado
Aceptado

## Contexto
El proyecto necesita controlar los cambios de base de datos de forma ordenada, repetible y trazable. Si los scripts SQL se ejecutan manualmente sin versionamiento, es facil perder el orden de ejecucion, repetir cambios o generar diferencias entre ambientes.

## Decision
Se decide usar Liquibase como herramienta para gestionar migraciones de base de datos. Los cambios se documentaran mediante changelogs y changesets, permitiendo ejecutar la estructura de la base de datos de forma controlada.

## Consecuencias
- Cada cambio importante de base de datos debe quedar registrado como changeset.
- El equipo puede saber que scripts ya fueron ejecutados.
- Se reduce el riesgo de inconsistencias entre ambientes.
- Los scripts deben mantenerse compatibles con PostgreSQL y con la configuracion de Liquibase.
