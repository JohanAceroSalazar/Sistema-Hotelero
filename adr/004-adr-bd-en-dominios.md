# ADR 004: Organizar la base de datos por dominios

## Estado
Aceptado

## Contexto
El sistema hotelero tiene varios grupos funcionales: seguridad, parametrizacion, distribucion, inventario, prestacion de servicio, facturacion, notificacion y mantenimiento. Organizar el script sin dominios dificulta la lectura, division del trabajo y mantenimiento.

## Decision
Se decide organizar la base de datos por dominios funcionales. Cada dominio agrupa sus tablas, drops e indices, respetando las dependencias necesarias para que el script pueda ejecutarse correctamente.

## Consecuencias
- El script es mas facil de revisar por modulo funcional.
- El equipo puede asignar trabajo por dominio.
- Las dependencias entre dominios deben respetarse al crear tablas y changesets.
- Los indices y drops tambien deben mantenerse agrupados por dominio para facilitar mantenimiento.
