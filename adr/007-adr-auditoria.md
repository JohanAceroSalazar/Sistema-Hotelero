# ADR 007: Usar campos de auditoria y eliminacion logica

## Estado
Aceptado

## Contexto
El sistema hotelero maneja informacion operativa importante como reservas, facturas, pagos, usuarios, habitaciones, inventario y mantenimiento. En estos casos no siempre conviene eliminar registros fisicamente, porque se puede perder trazabilidad historica o afectar reportes.

## Decision
Se decide incluir campos de auditoria y eliminacion logica en las tablas principales: `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at` y `status`.

## Consecuencias
- Se puede conocer quien creo, modifico o elimino logicamente un registro.
- La eliminacion logica permite conservar historial sin borrar fisicamente datos importantes.
- Las consultas funcionales deben filtrar registros activos cuando corresponda.
- Los campos `created_by`, `updated_by` y `deleted_by` usan UUID para mantener consistencia con el modelo de identificadores.
