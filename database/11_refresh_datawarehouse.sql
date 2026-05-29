USE DW_CRM_Innovacion;
GO

CREATE OR ALTER PROCEDURE sp_refrescar_datawarehouse
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM fact_oportunidad;
        DELETE FROM dim_tiempo;
        DELETE FROM dim_etapa;
        DELETE FROM dim_empleado;
        DELETE FROM dim_cliente;

        INSERT INTO dim_cliente (
            cliente_id,
            nombre_comercial,
            division_cliente,
            estado
        )
        SELECT 
            cliente_id,
            nombre_comercial,
            division_cliente,
            estado
        FROM CRM_Innovacion.dbo.cliente;

        INSERT INTO dim_empleado (
            empleado_id,
            nombre,
            rol,
            estado
        )
        SELECT 
            empleado_id,
            nombre,
            rol,
            estado
        FROM CRM_Innovacion.dbo.empleado_comercial;

        INSERT INTO dim_etapa (
            etapa_id,
            nombre,
            porcentaje
        )
        SELECT 
            etapa_id,
            nombre,
            porcentaje
        FROM CRM_Innovacion.dbo.etapa_oportunidad;

        INSERT INTO dim_tiempo (
            fecha,
            anio,
            mes,
            nombre_mes,
            dia,
            trimestre
        )
        SELECT DISTINCT
            fecha_inicio AS fecha,
            YEAR(fecha_inicio) AS anio,
            MONTH(fecha_inicio) AS mes,
            DATENAME(MONTH, fecha_inicio) AS nombre_mes,
            DAY(fecha_inicio) AS dia,
            DATEPART(QUARTER, fecha_inicio) AS trimestre
        FROM CRM_Innovacion.dbo.oportunidad;

        INSERT INTO fact_oportunidad (
            oportunidad_id,
            cliente_key,
            empleado_key,
            etapa_key,
            tiempo_key,
            numero_oportunidad,
            estado,
            tipo_oportunidad,
            monto_potencial,
            monto_ponderado,
            porcentaje_avance
        )
        SELECT 
            o.oportunidad_id,
            dc.cliente_key,
            de.empleado_key,
            det.etapa_key,
            dt.tiempo_key,
            o.numero_oportunidad,
            o.estado,
            o.tipo_oportunidad,
            o.monto_potencial,
            o.monto_ponderado,
            det.porcentaje
        FROM CRM_Innovacion.dbo.oportunidad o
        INNER JOIN dim_cliente dc
            ON o.cliente_id = dc.cliente_id
        INNER JOIN dim_empleado de
            ON o.gestor_id = de.empleado_id
        INNER JOIN dim_etapa det
            ON o.etapa_id = det.etapa_id
        INNER JOIN dim_tiempo dt
            ON o.fecha_inicio = dt.fecha;

        COMMIT TRANSACTION;

        SELECT 
            'Data Warehouse actualizado correctamente' AS mensaje,
            GETDATE() AS fecha_actualizacion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO