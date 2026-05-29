USE CRM_Innovacion_Replica;
GO

CREATE OR ALTER PROCEDURE sp_refrescar_replica_local
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM auditoria;
        DELETE FROM actividad;
        DELETE FROM oportunidad;
        DELETE FROM contacto;
        DELETE FROM etapa_oportunidad;
        DELETE FROM empleado_comercial;
        DELETE FROM cliente;

        INSERT INTO cliente
        SELECT *
        FROM CRM_Innovacion.dbo.cliente;

        INSERT INTO empleado_comercial
        SELECT *
        FROM CRM_Innovacion.dbo.empleado_comercial;

        INSERT INTO etapa_oportunidad
        SELECT *
        FROM CRM_Innovacion.dbo.etapa_oportunidad;

        INSERT INTO contacto
        SELECT *
        FROM CRM_Innovacion.dbo.contacto;

        INSERT INTO oportunidad
        SELECT *
        FROM CRM_Innovacion.dbo.oportunidad;

        INSERT INTO actividad
        SELECT *
        FROM CRM_Innovacion.dbo.actividad;

        INSERT INTO auditoria
        SELECT *
        FROM CRM_Innovacion.dbo.auditoria;

        COMMIT TRANSACTION;

        SELECT 'Réplica local actualizada correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO