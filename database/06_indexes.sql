USE CRM_Innovacion;
GO

/* ============================================================
   ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
   ============================================================ */

/* 
   Índice para búsquedas frecuentes de clientes por nombre comercial.
   Útil para pantallas de búsqueda y filtros por cliente.
*/
CREATE INDEX idx_cliente_nombre_comercial
ON cliente(nombre_comercial);
GO


/*
   Índice para buscar contactos por cliente.
   Útil cuando se selecciona un cliente y se listan sus contactos.
*/
CREATE INDEX idx_contacto_cliente_id
ON contacto(cliente_id);
GO


/*
   Índice para consultar oportunidades por cliente.
   Útil para ver el historial comercial de un cliente.
*/
CREATE INDEX idx_oportunidad_cliente_id
ON oportunidad(cliente_id);
GO


/*
   Índice para consultar oportunidades por gestor comercial.
   Útil para reportes por vendedor o ejecutivo comercial.
*/
CREATE INDEX idx_oportunidad_gestor_id
ON oportunidad(gestor_id);
GO


/*
   Índice para consultar oportunidades por estado:
   ABIERTA, GANADA o PERDIDA.
*/
CREATE INDEX idx_oportunidad_estado
ON oportunidad(estado);
GO


/*
   Índice para consultar oportunidades por fecha de inicio.
   Útil para reportes por rango de fechas.
*/
CREATE INDEX idx_oportunidad_fecha_inicio
ON oportunidad(fecha_inicio);
GO


/*
   Índice compuesto para reportes por estado y fecha.
   Útil para consultas como:
   oportunidades ganadas entre dos fechas.
*/
CREATE INDEX idx_oportunidad_estado_fecha
ON oportunidad(estado, fecha_inicio);
GO


/*
   Índice para consultar oportunidades por etapa.
   Útil para analizar el avance del canal de ventas.
*/
CREATE INDEX idx_oportunidad_etapa_id
ON oportunidad(etapa_id);
GO


/*
   Índice para consultar actividades por cliente.
*/
CREATE INDEX idx_actividad_cliente_id
ON actividad(cliente_id);
GO


/*
   Índice para consultar actividades por responsable.
*/
CREATE INDEX idx_actividad_responsable_id
ON actividad(responsable_id);
GO


/*
   Índice para consultar actividades por fecha.
   Útil para agenda comercial y reportes de seguimiento.
*/
CREATE INDEX idx_actividad_fecha
ON actividad(fecha);
GO


/*
   Índice compuesto para consultar actividades por responsable y fecha.
*/
CREATE INDEX idx_actividad_responsable_fecha
ON actividad(responsable_id, fecha);
GO


/*
   Índice para consultar auditoría por tabla afectada.
*/
CREATE INDEX idx_auditoria_tabla_afectada
ON auditoria(tabla_afectada);
GO


/*
   Índice para consultar auditoría por fecha.
*/
CREATE INDEX idx_auditoria_fecha
ON auditoria(fecha);
GO