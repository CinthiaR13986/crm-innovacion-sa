USE master;
GO

IF DB_ID('CRM_Innovacion_Replica') IS NOT NULL
BEGIN
    ALTER DATABASE CRM_Innovacion_Replica SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CRM_Innovacion_Replica;
END;
GO

CREATE DATABASE CRM_Innovacion_Replica;
GO

USE CRM_Innovacion_Replica;
GO

/* ============================================================
   CREACIÓN DE TABLAS EN BASE RÉPLICA
   ============================================================ */

CREATE TABLE cliente (
    cliente_id INT PRIMARY KEY,
    nombre_comercial VARCHAR(150) NOT NULL,
    direccion VARCHAR(250) NOT NULL,
    telefono VARCHAR(20) NULL,
    celular VARCHAR(20) NULL,
    correo VARCHAR(120) NULL,
    division_cliente VARCHAR(30) NOT NULL,
    estado BIT NOT NULL,
    fecha_creacion DATETIME NOT NULL
);
GO

CREATE TABLE contacto (
    contacto_id INT PRIMARY KEY,
    cliente_id INT NOT NULL,
    nombre_contacto VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(120) NULL,
    cargo VARCHAR(100) NULL,
    estado BIT NOT NULL
);
GO

CREATE TABLE empleado_comercial (
    empleado_id INT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    correo VARCHAR(120) NULL,
    estado BIT NOT NULL
);
GO

CREATE TABLE etapa_oportunidad (
    etapa_id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    porcentaje INT NOT NULL
);
GO

CREATE TABLE oportunidad (
    oportunidad_id INT PRIMARY KEY,
    numero_oportunidad VARCHAR(30) NOT NULL,
    cliente_id INT NOT NULL,
    contacto_id INT NOT NULL,
    gestor_id INT NOT NULL,
    asistente_id INT NULL,
    gerente_id INT NULL,
    etapa_id INT NOT NULL,
    nombre_oportunidad VARCHAR(150) NOT NULL,
    tipo_oportunidad VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_cierre DATE NULL,
    cierre_planificado_dias INT NOT NULL,
    fecha_cierre_prevista DATE NOT NULL,
    monto_potencial DECIMAL(12,2) NOT NULL,
    monto_ponderado DECIMAL(12,2) NOT NULL,
    comentario_cierre VARCHAR(300) NULL
);
GO

CREATE TABLE actividad (
    actividad_id INT PRIMARY KEY,
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
    sala VARCHAR(100) NULL
);
GO

CREATE TABLE auditoria (
    auditoria_id INT PRIMARY KEY,
    tabla_afectada VARCHAR(100) NOT NULL,
    operacion VARCHAR(20) NOT NULL,
    registro_id INT NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha DATETIME NOT NULL,
    descripcion VARCHAR(500) NULL
);
GO

/* ============================================================
   CARGA DE DATOS DESDE BASE PRINCIPAL
   ============================================================ */

INSERT INTO cliente
SELECT *
FROM CRM_Innovacion.dbo.cliente;
GO

INSERT INTO contacto
SELECT *
FROM CRM_Innovacion.dbo.contacto;
GO

INSERT INTO empleado_comercial
SELECT *
FROM CRM_Innovacion.dbo.empleado_comercial;
GO

INSERT INTO etapa_oportunidad
SELECT *
FROM CRM_Innovacion.dbo.etapa_oportunidad;
GO

INSERT INTO oportunidad
SELECT *
FROM CRM_Innovacion.dbo.oportunidad;
GO

INSERT INTO actividad
SELECT *
FROM CRM_Innovacion.dbo.actividad;
GO

INSERT INTO auditoria
SELECT *
FROM CRM_Innovacion.dbo.auditoria;
GO