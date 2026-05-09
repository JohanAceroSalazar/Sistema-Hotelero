# ADR 002: Usar UUID como identificador principal

## Estado
Aceptado

## Contexto
El modelo usaba identificadores numericos autoincrementales con `BIGSERIAL`. Aunque son simples, exponen secuencias, dependen de generacion centralizada y pueden ser menos convenientes cuando se integran datos entre modulos, ambientes o servicios.

## Decision
Se decide usar `UUID` para los identificadores principales de las tablas y para las columnas que referencian dichos identificadores. En PostgreSQL se usara `gen_random_uuid()` mediante la extension `pgcrypto`.

## Consecuencias
- Los campos `id` se definen como `UUID PRIMARY KEY DEFAULT gen_random_uuid()`.
- Las llaves foraneas y campos de auditoria relacionados con usuarios o registros se modelan como `UUID`.
- Se requiere habilitar `CREATE EXTENSION IF NOT EXISTS pgcrypto;`.
- Los datos semilla deben insertar UUID explicitamente o permitir que PostgreSQL los genere.
