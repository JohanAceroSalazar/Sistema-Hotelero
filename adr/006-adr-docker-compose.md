# ADR 006: Usar Docker Compose para el ambiente local

## Estado
Aceptado

## Contexto
El equipo necesita levantar la base de datos y las herramientas relacionadas de forma sencilla y consistente. Instalar PostgreSQL o dependencias manualmente en cada maquina puede generar diferencias de version, configuracion y credenciales.

## Decision
Se decide usar Docker Compose para definir y ejecutar el ambiente local del proyecto. Este ambiente puede incluir PostgreSQL y los servicios necesarios para probar la base de datos y las migraciones.

## Consecuencias
- El equipo puede levantar el ambiente con un comando estandar.
- La configuracion queda documentada en `docker-compose.yml`.
- Las variables sensibles o configurables deben manejarse mediante `.env` o archivos de ejemplo como `.env.example`.
- Se requiere que los integrantes tengan Docker instalado para usar este flujo local.
