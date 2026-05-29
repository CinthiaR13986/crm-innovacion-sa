USE CRM_Innovacion;
GO

/* ============================================================
   REPORTES DEL SISTEMA CRM INNOVACIÓN S.A.
   ============================================================ */


/* ============================================================
   REPORTE 1: OPORTUNIDADES POR RANGO DE FECHAS
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_oportunidades_por_fecha
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.oportunidad_id,
        o.numero_oportunidad,
        o.nombre_oportunidad,
        c.nombre_comercial AS cliente,
        co.nombre_contacto AS contacto,
        gestor.nombre AS gestor_comercial,
        asistente.nombre AS asistente_comercial,
        gerente.nombre AS gerente_comercial,
        etapa.nombre AS etapa,
        etapa.porcentaje AS porcentaje_avance,
        o.tipo_oportunidad,
        o.estado,
        o.fecha_inicio,
        o.fecha_cierre_prevista,
        o.fecha_cierre,
        o.cierre_planificado_dias,
        o.monto_potencial,
        o.monto_ponderado,
        o.comentario_cierre
    FROM oportunidad o
    INNER JOIN cliente c
        ON o.cliente_id = c.cliente_id
    INNER JOIN contacto co
        ON o.contacto_id = co.contacto_id
    INNER JOIN empleado_comercial gestor
        ON o.gestor_id = gestor.empleado_id
    LEFT JOIN empleado_comercial asistente
        ON o.asistente_id = asistente.empleado_id
    LEFT JOIN empleado_comercial gerente
        ON o.gerente_id = gerente.empleado_id
    INNER JOIN etapa_oportunidad etapa
        ON o.etapa_id = etapa.etapa_id
    WHERE o.fecha_inicio BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY o.fecha_inicio DESC, o.oportunidad_id DESC;
END;
GO


/* ============================================================
   REPORTE 2: OPORTUNIDADES POR GESTOR COMERCIAL
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_oportunidades_por_gestor
    @gestor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        gestor.empleado_id AS gestor_id,
        gestor.nombre AS gestor_comercial,
        o.oportunidad_id,
        o.numero_oportunidad,
        o.nombre_oportunidad,
        c.nombre_comercial AS cliente,
        co.nombre_contacto AS contacto,
        etapa.nombre AS etapa,
        etapa.porcentaje AS porcentaje_avance,
        o.estado,
        o.fecha_inicio,
        o.fecha_cierre_prevista,
        o.fecha_cierre,
        o.monto_potencial,
        o.monto_ponderado,
        o.comentario_cierre
    FROM oportunidad o
    INNER JOIN empleado_comercial gestor
        ON o.gestor_id = gestor.empleado_id
    INNER JOIN cliente c
        ON o.cliente_id = c.cliente_id
    INNER JOIN contacto co
        ON o.contacto_id = co.contacto_id
    INNER JOIN etapa_oportunidad etapa
        ON o.etapa_id = etapa.etapa_id
    WHERE o.gestor_id = @gestor_id
    ORDER BY o.fecha_inicio DESC, o.oportunidad_id DESC;
END;
GO


/* ============================================================
   REPORTE 3: OPORTUNIDADES POR ESTADO
   ABIERTA / GANADA / PERDIDA
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_oportunidades_por_estado
    @estado VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF @estado NOT IN ('ABIERTA', 'GANADA', 'PERDIDA')
    BEGIN
        THROW 50100, 'El estado debe ser ABIERTA, GANADA o PERDIDA.', 1;
    END;

    SELECT 
        o.oportunidad_id,
        o.numero_oportunidad,
        o.nombre_oportunidad,
        c.nombre_comercial AS cliente,
        gestor.nombre AS gestor_comercial,
        etapa.nombre AS etapa,
        etapa.porcentaje AS porcentaje_avance,
        o.estado,
        o.fecha_inicio,
        o.fecha_cierre_prevista,
        o.fecha_cierre,
        o.monto_potencial,
        o.monto_ponderado,
        o.comentario_cierre
    FROM oportunidad o
    INNER JOIN cliente c
        ON o.cliente_id = c.cliente_id
    INNER JOIN empleado_comercial gestor
        ON o.gestor_id = gestor.empleado_id
    INNER JOIN etapa_oportunidad etapa
        ON o.etapa_id = etapa.etapa_id
    WHERE o.estado = @estado
    ORDER BY o.fecha_inicio DESC, o.oportunidad_id DESC;
END;
GO


/* ============================================================
   REPORTE 4: RESUMEN GERENCIAL DE OPORTUNIDADES
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_resumen_gerencial
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.estado,
        COUNT(*) AS total_oportunidades,
        SUM(o.monto_potencial) AS total_monto_potencial,
        SUM(o.monto_ponderado) AS total_monto_ponderado,
        AVG(o.monto_potencial) AS promedio_monto_potencial
    FROM oportunidad o
    GROUP BY o.estado
    ORDER BY o.estado;
END;
GO


/* ============================================================
   REPORTE 5: OPORTUNIDADES POR ETAPA
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_oportunidades_por_etapa
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        etapa.nombre AS etapa,
        etapa.porcentaje,
        COUNT(o.oportunidad_id) AS total_oportunidades,
        ISNULL(SUM(o.monto_potencial), 0) AS total_monto_potencial,
        ISNULL(SUM(o.monto_ponderado), 0) AS total_monto_ponderado
    FROM etapa_oportunidad etapa
    LEFT JOIN oportunidad o
        ON etapa.etapa_id = o.etapa_id
    GROUP BY 
        etapa.nombre,
        etapa.porcentaje
    ORDER BY etapa.porcentaje ASC;
END;
GO


/* ============================================================
   REPORTE 6: ACTIVIDADES POR RESPONSABLE Y FECHA
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_actividades_por_responsable
    @responsable_id INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.actividad_id,
        responsable.nombre AS responsable,
        c.nombre_comercial AS cliente,
        co.nombre_contacto AS contacto,
        o.numero_oportunidad,
        a.tipo_actividad,
        a.asunto,
        a.fecha,
        a.hora_inicio,
        a.hora_final,
        a.duracion_minutos,
        a.prioridad,
        a.estado,
        a.comentario
    FROM actividad a
    INNER JOIN empleado_comercial responsable
        ON a.responsable_id = responsable.empleado_id
    INNER JOIN cliente c
        ON a.cliente_id = c.cliente_id
    LEFT JOIN contacto co
        ON a.contacto_id = co.contacto_id
    LEFT JOIN oportunidad o
        ON a.oportunidad_id = o.oportunidad_id
    WHERE a.responsable_id = @responsable_id
      AND a.fecha BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY a.fecha DESC, a.hora_inicio DESC;
END;
GO


/* ============================================================
   REPORTE 7: AUDITORÍA POR FECHA
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_reporte_auditoria_por_fecha
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        auditoria_id,
        tabla_afectada,
        operacion,
        registro_id,
        usuario,
        fecha,
        descripcion
    FROM auditoria
    WHERE CAST(fecha AS DATE) BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY fecha DESC, auditoria_id DESC;
END;
GO