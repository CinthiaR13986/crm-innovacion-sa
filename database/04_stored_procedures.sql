USE CRM_Innovacion;
GO

/* ============================================================
   STORED PROCEDURES - CLIENTE
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_crear_cliente
    @nombre_comercial VARCHAR(150),
    @direccion VARCHAR(250),
    @telefono VARCHAR(20) = NULL,
    @celular VARCHAR(20) = NULL,
    @correo VARCHAR(120) = NULL,
    @division_cliente VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO cliente (
            nombre_comercial,
            direccion,
            telefono,
            celular,
            correo,
            division_cliente
        )
        VALUES (
            @nombre_comercial,
            @direccion,
            @telefono,
            @celular,
            @correo,
            @division_cliente
        );

        COMMIT TRANSACTION;

        SELECT 
            SCOPE_IDENTITY() AS nuevo_cliente_id,
            'Cliente creado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_listar_clientes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        cliente_id,
        nombre_comercial,
        direccion,
        telefono,
        celular,
        correo,
        division_cliente,
        estado,
        fecha_creacion
    FROM cliente
    WHERE estado = 1
    ORDER BY cliente_id DESC;
END;
GO


CREATE OR ALTER PROCEDURE sp_obtener_cliente_por_id
    @cliente_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        cliente_id,
        nombre_comercial,
        direccion,
        telefono,
        celular,
        correo,
        division_cliente,
        estado,
        fecha_creacion
    FROM cliente
    WHERE cliente_id = @cliente_id;
END;
GO


CREATE OR ALTER PROCEDURE sp_actualizar_cliente
    @cliente_id INT,
    @nombre_comercial VARCHAR(150),
    @direccion VARCHAR(250),
    @telefono VARCHAR(20) = NULL,
    @celular VARCHAR(20) = NULL,
    @correo VARCHAR(120) = NULL,
    @division_cliente VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 
            FROM cliente 
            WHERE cliente_id = @cliente_id
        )
        BEGIN
            THROW 50001, 'El cliente no existe.', 1;
        END;

        UPDATE cliente
        SET 
            nombre_comercial = @nombre_comercial,
            direccion = @direccion,
            telefono = @telefono,
            celular = @celular,
            correo = @correo,
            division_cliente = @division_cliente
        WHERE cliente_id = @cliente_id;

        COMMIT TRANSACTION;

        SELECT 'Cliente actualizado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_eliminar_cliente
    @cliente_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 
            FROM cliente 
            WHERE cliente_id = @cliente_id
        )
        BEGIN
            THROW 50002, 'El cliente no existe.', 1;
        END;

        UPDATE cliente
        SET estado = 0
        WHERE cliente_id = @cliente_id;

        COMMIT TRANSACTION;

        SELECT 'Cliente eliminado lógicamente correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


/* ============================================================
   STORED PROCEDURES - CONTACTO
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_crear_contacto
    @cliente_id INT,
    @nombre_contacto VARCHAR(150),
    @telefono VARCHAR(20) = NULL,
    @correo VARCHAR(120) = NULL,
    @cargo VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 
            FROM cliente 
            WHERE cliente_id = @cliente_id 
              AND estado = 1
        )
        BEGIN
            THROW 50003, 'El cliente no existe o está inactivo.', 1;
        END;

        INSERT INTO contacto (
            cliente_id,
            nombre_contacto,
            telefono,
            correo,
            cargo
        )
        VALUES (
            @cliente_id,
            @nombre_contacto,
            @telefono,
            @correo,
            @cargo
        );

        COMMIT TRANSACTION;

        SELECT 
            SCOPE_IDENTITY() AS nuevo_contacto_id,
            'Contacto creado correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_listar_contactos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        co.contacto_id,
        co.nombre_contacto,
        co.telefono,
        co.correo,
        co.cargo,
        co.estado,
        c.cliente_id,
        c.nombre_comercial AS cliente
    FROM contacto co
    INNER JOIN cliente c 
        ON co.cliente_id = c.cliente_id
    WHERE co.estado = 1
    ORDER BY co.contacto_id DESC;
END;
GO


/* ============================================================
   STORED PROCEDURES - OPORTUNIDAD
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_crear_oportunidad
    @numero_oportunidad VARCHAR(30),
    @cliente_id INT,
    @contacto_id INT,
    @gestor_id INT,
    @asistente_id INT = NULL,
    @gerente_id INT = NULL,
    @etapa_id INT,
    @nombre_oportunidad VARCHAR(150),
    @tipo_oportunidad VARCHAR(20),
    @fecha_inicio DATE,
    @cierre_planificado_dias INT,
    @monto_potencial DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @porcentaje INT;
    DECLARE @monto_ponderado DECIMAL(12,2);
    DECLARE @fecha_cierre_prevista DATE;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1 
            FROM oportunidad 
            WHERE numero_oportunidad = @numero_oportunidad
        )
        BEGIN
            THROW 50004, 'Ya existe una oportunidad con ese número.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 
            FROM cliente 
            WHERE cliente_id = @cliente_id 
              AND estado = 1
        )
        BEGIN
            THROW 50005, 'El cliente no existe o está inactivo.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 
            FROM contacto 
            WHERE contacto_id = @contacto_id 
              AND cliente_id = @cliente_id
              AND estado = 1
        )
        BEGIN
            THROW 50006, 'El contacto no existe o no pertenece al cliente seleccionado.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 
            FROM empleado_comercial 
            WHERE empleado_id = @gestor_id
              AND rol = 'GESTOR_COMERCIAL'
              AND estado = 1
        )
        BEGIN
            THROW 50007, 'El gestor comercial no existe o no tiene el rol correcto.', 1;
        END;

        SELECT @porcentaje = porcentaje
        FROM etapa_oportunidad
        WHERE etapa_id = @etapa_id;

        IF @porcentaje IS NULL
        BEGIN
            THROW 50008, 'La etapa de oportunidad no existe.', 1;
        END;

        SET @monto_ponderado = @monto_potencial * (@porcentaje / 100.0);
        SET @fecha_cierre_prevista = DATEADD(DAY, @cierre_planificado_dias, @fecha_inicio);

        INSERT INTO oportunidad (
            numero_oportunidad,
            cliente_id,
            contacto_id,
            gestor_id,
            asistente_id,
            gerente_id,
            etapa_id,
            nombre_oportunidad,
            tipo_oportunidad,
            estado,
            fecha_inicio,
            cierre_planificado_dias,
            fecha_cierre_prevista,
            monto_potencial,
            monto_ponderado
        )
        VALUES (
            @numero_oportunidad,
            @cliente_id,
            @contacto_id,
            @gestor_id,
            @asistente_id,
            @gerente_id,
            @etapa_id,
            @nombre_oportunidad,
            @tipo_oportunidad,
            'ABIERTA',
            @fecha_inicio,
            @cierre_planificado_dias,
            @fecha_cierre_prevista,
            @monto_potencial,
            @monto_ponderado
        );

        COMMIT TRANSACTION;

        SELECT 
            SCOPE_IDENTITY() AS nueva_oportunidad_id,
            'Oportunidad creada correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_listar_oportunidades
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
        etapa.nombre AS etapa,
        etapa.porcentaje,
        o.tipo_oportunidad,
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
    INNER JOIN contacto co 
        ON o.contacto_id = co.contacto_id
    INNER JOIN empleado_comercial gestor 
        ON o.gestor_id = gestor.empleado_id
    INNER JOIN etapa_oportunidad etapa 
        ON o.etapa_id = etapa.etapa_id
    ORDER BY o.oportunidad_id DESC;
END;
GO


CREATE OR ALTER PROCEDURE sp_actualizar_etapa_oportunidad
    @oportunidad_id INT,
    @etapa_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @porcentaje INT;
    DECLARE @monto_potencial DECIMAL(12,2);
    DECLARE @monto_ponderado DECIMAL(12,2);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 
            FROM oportunidad 
            WHERE oportunidad_id = @oportunidad_id
        )
        BEGIN
            THROW 50009, 'La oportunidad no existe.', 1;
        END;

        SELECT @porcentaje = porcentaje
        FROM etapa_oportunidad
        WHERE etapa_id = @etapa_id;

        IF @porcentaje IS NULL
        BEGIN
            THROW 50010, 'La etapa no existe.', 1;
        END;

        SELECT @monto_potencial = monto_potencial
        FROM oportunidad
        WHERE oportunidad_id = @oportunidad_id;

        SET @monto_ponderado = @monto_potencial * (@porcentaje / 100.0);

        UPDATE oportunidad
        SET 
            etapa_id = @etapa_id,
            monto_ponderado = @monto_ponderado
        WHERE oportunidad_id = @oportunidad_id;

        COMMIT TRANSACTION;

        SELECT 'Etapa de oportunidad actualizada correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_cerrar_oportunidad
    @oportunidad_id INT,
    @estado VARCHAR(20),
    @comentario_cierre VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @porcentaje INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @estado NOT IN ('GANADA', 'PERDIDA')
        BEGIN
            THROW 50011, 'El estado debe ser GANADA o PERDIDA.', 1;
        END;

        IF @comentario_cierre IS NULL OR LTRIM(RTRIM(@comentario_cierre)) = ''
        BEGIN
            THROW 50012, 'Debe ingresar un comentario de cierre.', 1;
        END;

        SELECT @porcentaje = e.porcentaje
        FROM oportunidad o
        INNER JOIN etapa_oportunidad e 
            ON o.etapa_id = e.etapa_id
        WHERE o.oportunidad_id = @oportunidad_id;

        IF @porcentaje IS NULL
        BEGIN
            THROW 50013, 'La oportunidad no existe.', 1;
        END;

        IF @porcentaje < 100
        BEGIN
            THROW 50014, 'No se puede cerrar la oportunidad porque la etapa no está al 100%.', 1;
        END;

        UPDATE oportunidad
        SET 
            estado = @estado,
            comentario_cierre = @comentario_cierre,
            fecha_cierre = GETDATE()
        WHERE oportunidad_id = @oportunidad_id;

        COMMIT TRANSACTION;

        SELECT 'Oportunidad cerrada correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


/* ============================================================
   STORED PROCEDURES - ACTIVIDAD
   ============================================================ */

CREATE OR ALTER PROCEDURE sp_crear_actividad
    @cliente_id INT,
    @contacto_id INT = NULL,
    @oportunidad_id INT = NULL,
    @responsable_id INT,
    @tipo_actividad VARCHAR(30),
    @asunto VARCHAR(150),
    @fecha DATE,
    @hora_inicio TIME = NULL,
    @hora_final TIME = NULL,
    @prioridad VARCHAR(20),
    @comentario VARCHAR(300) = NULL,
    @estado VARCHAR(30),
    @calle VARCHAR(150) = NULL,
    @ciudad VARCHAR(100) = NULL,
    @sala VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @duracion_minutos INT = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 
            FROM cliente 
            WHERE cliente_id = @cliente_id 
              AND estado = 1
        )
        BEGIN
            THROW 50015, 'El cliente no existe o está inactivo.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 
            FROM empleado_comercial 
            WHERE empleado_id = @responsable_id 
              AND estado = 1
        )
        BEGIN
            THROW 50016, 'El responsable no existe o está inactivo.', 1;
        END;

        IF @hora_inicio IS NOT NULL AND @hora_final IS NOT NULL
        BEGIN
            SET @duracion_minutos = DATEDIFF(MINUTE, @hora_inicio, @hora_final);
        END;

        INSERT INTO actividad (
            cliente_id,
            contacto_id,
            oportunidad_id,
            responsable_id,
            tipo_actividad,
            asunto,
            fecha,
            hora_inicio,
            hora_final,
            duracion_minutos,
            prioridad,
            comentario,
            estado,
            calle,
            ciudad,
            sala
        )
        VALUES (
            @cliente_id,
            @contacto_id,
            @oportunidad_id,
            @responsable_id,
            @tipo_actividad,
            @asunto,
            @fecha,
            @hora_inicio,
            @hora_final,
            @duracion_minutos,
            @prioridad,
            @comentario,
            @estado,
            @calle,
            @ciudad,
            @sala
        );

        COMMIT TRANSACTION;

        SELECT 
            SCOPE_IDENTITY() AS nueva_actividad_id,
            'Actividad creada correctamente' AS mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_listar_actividades
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.actividad_id,
        c.nombre_comercial AS cliente,
        co.nombre_contacto AS contacto,
        o.numero_oportunidad,
        e.nombre AS responsable,
        a.tipo_actividad,
        a.asunto,
        a.fecha,
        a.hora_inicio,
        a.hora_final,
        a.duracion_minutos,
        a.prioridad,
        a.estado,
        a.comentario,
        a.calle,
        a.ciudad,
        a.sala
    FROM actividad a
    INNER JOIN cliente c 
        ON a.cliente_id = c.cliente_id
    LEFT JOIN contacto co 
        ON a.contacto_id = co.contacto_id
    LEFT JOIN oportunidad o 
        ON a.oportunidad_id = o.oportunidad_id
    INNER JOIN empleado_comercial e 
        ON a.responsable_id = e.empleado_id
    ORDER BY a.actividad_id DESC;
END;
GO