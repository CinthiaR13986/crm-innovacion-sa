USE CRM_Innovacion;
GO

INSERT INTO etapa_oportunidad (nombre, porcentaje)
VALUES
('Toma de Decisión', 20),
('Proceso Toma de Decisión', 30),
('Análisis de Proyecto', 50),
('Presentación de Cotización', 80),
('Validación de Cotización', 95),
('Acuerdo de Cierre', 100);
GO

INSERT INTO empleado_comercial (nombre, rol, correo)
VALUES
('Sandra Aroche', 'GESTOR_COMERCIAL', 'sandra.aroche@innovacion.com'),
('Carlos Méndez', 'ASISTENTE_COMERCIAL', 'carlos.mendez@innovacion.com'),
('María López', 'GERENTE_COMERCIAL', 'maria.lopez@innovacion.com');
GO

INSERT INTO cliente (
    nombre_comercial,
    direccion,
    telefono,
    celular,
    correo,
    division_cliente
)
VALUES
('Comercial Los Andes', 'Zona 10, Ciudad de Guatemala', '2222-1000', '5555-1000', 'contacto@losandes.com', 'CLIENTE_POTENCIAL'),
('Distribuidora El Roble', 'Zona 4, Mixco', '2222-2000', '5555-2000', 'ventas@elroble.com', 'CLIENTE_FINAL');
GO

INSERT INTO contacto (
    cliente_id,
    nombre_contacto,
    telefono,
    correo,
    cargo
)
VALUES
(1, 'Juan Pérez', '2222-1010', 'juan.perez@losandes.com', 'Gerente de Compras'),
(2, 'Ana Gómez', '2222-2020', 'ana.gomez@elroble.com', 'Administradora');
GO

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
VALUES
(
    'OP-2025-001',
    1,
    1,
    1,
    2,
    3,
    1,
    'Venta de sistema CRM comercial',
    'VENTA',
    'ABIERTA',
    GETDATE(),
    30,
    DATEADD(DAY, 30, GETDATE()),
    60000.00,
    12000.00
),
(
    'OP-2025-002',
    2,
    2,
    1,
    2,
    3,
    4,
    'Venta de licenciamiento anual',
    'VENTA',
    'ABIERTA',
    GETDATE(),
    15,
    DATEADD(DAY, 15, GETDATE()),
    27000.00,
    21600.00
);
GO

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
    estado
)
VALUES
(
    1,
    1,
    1,
    1,
    'LLAMADA',
    'Seguimiento inicial de oportunidad',
    GETDATE(),
    '09:00',
    '09:30',
    30,
    'NORMAL',
    'Se realizó llamada inicial al cliente.',
    'CONCLUIDO'
),
(
    2,
    2,
    2,
    1,
    'REUNION',
    'Presentación de cotización',
    GETDATE(),
    '10:00',
    '11:00',
    60,
    'ALTA',
    'Reunión para presentar propuesta comercial.',
    'EN_PROCESO'
);
GO