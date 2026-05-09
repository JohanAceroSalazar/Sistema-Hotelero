# ADR 001: Migrar la base de datos de MySQL a PostgreSQL

## Estado
Aceptado

## Contexto
El modelo inicial del sistema hotelero estaba escrito con sintaxis MySQL, usando elementos como `AUTO_INCREMENT`, `UNSIGNED`, `TINYINT(1)`, `ENGINE`, `CHARSET`, `COLLATE` y `ON UPDATE`. El proyecto necesita una base de datos compatible con PostgreSQL para facilitar el uso de esquemas, extensiones, tipos nativos y herramientas como Liquibase.

## Decision
Se decide migrar el script de base de datos a PostgreSQL, reemplazando la sintaxis propia de MySQL por tipos y construcciones compatibles con PostgreSQL.

## Consecuencias
- Los scripts deben ejecutarse en PostgreSQL.
- Los tipos booleanos se modelan con `BOOLEAN`.
- Las fechas y horas se modelan con `TIMESTAMP`.
- Los valores monetarios se mantienen con `NUMERIC(12,2)`.
- Los scripts semilla o consultas antiguas de MySQL deben ajustarse antes de ejecutarse.
