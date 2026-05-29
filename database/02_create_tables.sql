USE CRM_Innovacion;
GO

CREATE TABLE cliente (
    cliente_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_comercial VARCHAR(150) NOT NULL,
    direccion VARCHAR(250) NOT NULL,
    telefono VARCHAR(20) NULL,
    celular VARCHAR(20) NULL,
    correo VARCHAR(120) NULL,
    division_cliente VARCHAR(30) NOT NULL,
    estado BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT chk_cliente_division
    CHECK (division_cliente IN ('CLIENTE_POTENCIAL', 'CLIENTE_FINAL'))
);
GO

CREATE TABLE contacto (
    contacto_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    nombre_contacto VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(120) NULL,
    cargo VARCHAR(100) NULL,
    estado BIT NOT NULL DEFAULT 1,

    CONSTRAINT fk_contacto_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
);
GO

CREATE TABLE empleado_comercial (
    empleado_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    correo VARCHAR(120) NULL,
    estado BIT NOT NULL DEFAULT 1,

    CONSTRAINT chk_empleado_rol
    CHECK (rol IN ('GESTOR_COMERCIAL', 'ASISTENTE_COMERCIAL', 'GERENTE_COMERCIAL'))
);
GO

CREATE TABLE etapa_oportunidad (
    etapa_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    porcentaje INT NOT NULL,

    CONSTRAINT chk_etapa_porcentaje
    CHECK (porcentaje BETWEEN 0 AND 100)
);
GO

CREATE TABLE oportunidad (
    oportunidad_id INT IDENTITY(1,1) PRIMARY KEY,
    numero_oportunidad VARCHAR(30) NOT NULL,
    cliente_id INT NOT NULL,
    contacto_id INT NOT NULL,
    gestor_id INT NOT NULL,
    asistente_id INT NULL,
    gerente_id INT NULL,
    etapa_id INT NOT NULL,
    nombre_oportunidad VARCHAR(150) NOT NULL,
    tipo_oportunidad VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ABIERTA',
    fecha_inicio DATE NOT NULL,
    fecha_cierre DATE NULL,
    cierre_planificado_dias INT NOT NULL,
    fecha_cierre_prevista DATE NOT NULL,
    monto_potencial DECIMAL(12,2) NOT NULL,
    monto_ponderado DECIMAL(12,2) NOT NULL,
    comentario_cierre VARCHAR(300) NULL,

    CONSTRAINT uq_oportunidad_numero UNIQUE (numero_oportunidad),

    CONSTRAINT fk_oportunidad_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),

    CONSTRAINT fk_oportunidad_contacto
    FOREIGN KEY (contacto_id) REFERENCES contacto(contacto_id),

    CONSTRAINT fk_oportunidad_gestor
    FOREIGN KEY (gestor_id) REFERENCES empleado_comercial(empleado_id),

    CONSTRAINT fk_oportunidad_asistente
    FOREIGN KEY (asistente_id) REFERENCES empleado_comercial(empleado_id),

    CONSTRAINT fk_oportunidad_gerente
    FOREIGN KEY (gerente_id) REFERENCES empleado_comercial(empleado_id),

    CONSTRAINT fk_oportunidad_etapa
    FOREIGN KEY (etapa_id) REFERENCES etapa_oportunidad(etapa_id),

    CONSTRAINT chk_oportunidad_tipo
    CHECK (tipo_oportunidad IN ('VENTA', 'COMPRA')),

    CONSTRAINT chk_oportunidad_estado
    CHECK (estado IN ('ABIERTA', 'GANADA', 'PERDIDA'))
);
GO

CREATE TABLE actividad (
    actividad_id INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    contacto_id INT NULL,
    oportunidad_id INT NULL,
    responsable_id INT NOT NULL,
    tipo_actividad VARCHAR(30) NOT NULL,
    asunto VARCHAR(150) NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NULL,
    hora_final TIME NULL,
    duracion_minutos INT NULL,
    prioridad VARCHAR(20) NOT NULL,
    comentario VARCHAR(300) NULL,
    estado VARCHAR(30) NOT NULL,
    calle VARCHAR(150) NULL,
    ciudad VARCHAR(100) NULL,
    sala VARCHAR(100) NULL,

    CONSTRAINT fk_actividad_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),

    CONSTRAINT fk_actividad_contacto
    FOREIGN KEY (contacto_id) REFERENCES contacto(contacto_id),

    CONSTRAINT fk_actividad_oportunidad
    FOREIGN KEY (oportunidad_id) REFERENCES oportunidad(oportunidad_id),

    CONSTRAINT fk_actividad_responsable
    FOREIGN KEY (responsable_id) REFERENCES empleado_comercial(empleado_id),

    CONSTRAINT chk_actividad_tipo
    CHECK (tipo_actividad IN ('LLAMADA', 'REUNION', 'TAREA', 'NOTA')),

    CONSTRAINT chk_actividad_prioridad
    CHECK (prioridad IN ('BAJA', 'NORMAL', 'ALTA')),

    CONSTRAINT chk_actividad_estado
    CHECK (estado IN ('NO_INICIADO', 'EN_PROCESO', 'EN_ESPERA', 'CONCLUIDO', 'NO_CONCLUIDO', 'CERRADO', 'INACTIVO'))
);
GO

CREATE TABLE auditoria (
    auditoria_id INT IDENTITY(1,1) PRIMARY KEY,
    tabla_afectada VARCHAR(100) NOT NULL,
    operacion VARCHAR(20) NOT NULL,
    registro_id INT NOT NULL,
    usuario VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    descripcion VARCHAR(500) NULL
);
GO