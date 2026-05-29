USE CRM_Innovacion;
GO

/* ============================================================
   TRIGGERS DE AUDITORÍA - CLIENTE
   ============================================================ */

CREATE OR ALTER TRIGGER trg_auditoria_cliente_insert
ON cliente
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'cliente',
        'INSERT',
        cliente_id,
        CONCAT('Se creó el cliente: ', nombre_comercial)
    FROM inserted;
END;
GO


CREATE OR ALTER TRIGGER trg_auditoria_cliente_update
ON cliente
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'cliente',
        CASE 
            WHEN i.estado = 0 AND d.estado = 1 THEN 'DELETE_LOGICO'
            ELSE 'UPDATE'
        END,
        i.cliente_id,
        CASE 
            WHEN i.estado = 0 AND d.estado = 1 
                THEN CONCAT('Se eliminó lógicamente el cliente: ', i.nombre_comercial)
            ELSE CONCAT('Se actualizó el cliente: ', i.nombre_comercial)
        END
    FROM inserted i
    INNER JOIN deleted d
        ON i.cliente_id = d.cliente_id;
END;
GO


/* ============================================================
   TRIGGERS DE AUDITORÍA - CONTACTO
   ============================================================ */

CREATE OR ALTER TRIGGER trg_auditoria_contacto_insert
ON contacto
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'contacto',
        'INSERT',
        contacto_id,
        CONCAT('Se creó el contacto: ', nombre_contacto)
    FROM inserted;
END;
GO


CREATE OR ALTER TRIGGER trg_auditoria_contacto_update
ON contacto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'contacto',
        CASE 
            WHEN i.estado = 0 AND d.estado = 1 THEN 'DELETE_LOGICO'
            ELSE 'UPDATE'
        END,
        i.contacto_id,
        CASE 
            WHEN i.estado = 0 AND d.estado = 1 
                THEN CONCAT('Se eliminó lógicamente el contacto: ', i.nombre_contacto)
            ELSE CONCAT('Se actualizó el contacto: ', i.nombre_contacto)
        END
    FROM inserted i
    INNER JOIN deleted d
        ON i.contacto_id = d.contacto_id;
END;
GO


/* ============================================================
   TRIGGERS DE AUDITORÍA - OPORTUNIDAD
   ============================================================ */

CREATE OR ALTER TRIGGER trg_auditoria_oportunidad_insert
ON oportunidad
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'oportunidad',
        'INSERT',
        oportunidad_id,
        CONCAT('Se creó la oportunidad: ', numero_oportunidad, ' - ', nombre_oportunidad)
    FROM inserted;
END;
GO


CREATE OR ALTER TRIGGER trg_auditoria_oportunidad_update
ON oportunidad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'oportunidad',
        'UPDATE',
        i.oportunidad_id,
        CONCAT(
            'Se actualizó la oportunidad: ', 
            i.numero_oportunidad,
            '. Estado anterior: ',
            d.estado,
            ', estado nuevo: ',
            i.estado
        )
    FROM inserted i
    INNER JOIN deleted d
        ON i.oportunidad_id = d.oportunidad_id;
END;
GO


/* ============================================================
   TRIGGERS DE AUDITORÍA - ACTIVIDAD
   ============================================================ */

CREATE OR ALTER TRIGGER trg_auditoria_actividad_insert
ON actividad
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'actividad',
        'INSERT',
        actividad_id,
        CONCAT('Se creó la actividad: ', asunto)
    FROM inserted;
END;
GO


CREATE OR ALTER TRIGGER trg_auditoria_actividad_update
ON actividad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO auditoria (
        tabla_afectada,
        operacion,
        registro_id,
        descripcion
    )
    SELECT 
        'actividad',
        'UPDATE',
        i.actividad_id,
        CONCAT(
            'Se actualizó la actividad: ',
            i.asunto,
            '. Estado anterior: ',
            d.estado,
            ', estado nuevo: ',
            i.estado
        )
    FROM inserted i
    INNER JOIN deleted d
        ON i.actividad_id = d.actividad_id;
END;
GO