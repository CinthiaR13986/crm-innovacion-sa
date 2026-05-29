/* ============================================================
   DATA WAREHOUSE Y ETL - CRM INNOVACIÓN S.A.
   ============================================================ */

USE master;
GO

IF DB_ID('DW_CRM_Innovacion') IS NULL
BEGIN
    CREATE DATABASE DW_CRM_Innovacion;
END;
GO

USE DW_CRM_Innovacion;
GO


/* ============================================================
   LIMPIEZA DE TABLAS SI YA EXISTEN
   ============================================================ */

IF OBJECT_ID('fact_oportunidad', 'U') IS NOT NULL
    DROP TABLE fact_oportunidad;
GO

IF OBJECT_ID('dim_tiempo', 'U') IS NOT NULL
    DROP TABLE dim_tiempo;
GO

IF OBJECT_ID('dim_etapa', 'U') IS NOT NULL
    DROP TABLE dim_etapa;
GO

IF OBJECT_ID('dim_empleado', 'U') IS NOT NULL
    DROP TABLE dim_empleado;
GO

IF OBJECT_ID('dim_cliente', 'U') IS NOT NULL
    DROP TABLE dim_cliente;
GO


/* ============================================================
   CREACIÓN DE DIMENSIONES
   ============================================================ */

CREATE TABLE dim_cliente (
    cliente_key INT IDENTITY(1,1) PRIMARY KEY,
    cliente_id INT NOT NULL,
    nombre_comercial VARCHAR(150) NOT NULL,
    division_cliente VARCHAR(30) NOT NULL,
    estado BIT NOT NULL
);
GO


CREATE TABLE dim_empleado (
    empleado_key INT IDENTITY(1,1) PRIMARY KEY,
    empleado_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    estado BIT NOT NULL
);
GO


CREATE TABLE dim_etapa (
    etapa_key INT IDENTITY(1,1) PRIMARY KEY,
    etapa_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    porcentaje INT NOT NULL
);
GO


CREATE TABLE dim_tiempo (
    tiempo_key INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    anio INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    dia INT NOT NULL,
    trimestre INT NOT NULL
);
GO


/* ============================================================
   CREACIÓN DE TABLA DE HECHOS
   ============================================================ */

CREATE TABLE fact_oportunidad (
    fact_oportunidad_id INT IDENTITY(1,1) PRIMARY KEY,
    oportunidad_id INT NOT NULL,
    cliente_key INT NOT NULL,
    empleado_key INT NOT NULL,
    etapa_key INT NOT NULL,
    tiempo_key INT NOT NULL,
    numero_oportunidad VARCHAR(30) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    tipo_oportunidad VARCHAR(20) NOT NULL,
    monto_potencial DECIMAL(12,2) NOT NULL,
    monto_ponderado DECIMAL(12,2) NOT NULL,
    porcentaje_avance INT NOT NULL,

    CONSTRAINT fk_fact_cliente
    FOREIGN KEY (cliente_key) REFERENCES dim_cliente(cliente_key),

    CONSTRAINT fk_fact_empleado
    FOREIGN KEY (empleado_key) REFERENCES dim_empleado(empleado_key),

    CONSTRAINT fk_fact_etapa
    FOREIGN KEY (etapa_key) REFERENCES dim_etapa(etapa_key),

    CONSTRAINT fk_fact_tiempo
    FOREIGN KEY (tiempo_key) REFERENCES dim_tiempo(tiempo_key)
);
GO


/* ============================================================
   ETL - EXTRACCIÓN Y CARGA DE DIMENSIONES
   ============================================================ */

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
GO


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
GO


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
GO


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
GO


/* ============================================================
   ETL - CARGA DE TABLA DE HECHOS
   ============================================================ */

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
GO


/* ============================================================
   ÍNDICES DEL DATA WAREHOUSE
   ============================================================ */

CREATE INDEX idx_fact_oportunidad_estado
ON fact_oportunidad(estado);
GO

CREATE INDEX idx_fact_oportunidad_cliente
ON fact_oportunidad(cliente_key);
GO

CREATE INDEX idx_fact_oportunidad_empleado
ON fact_oportunidad(empleado_key);
GO

CREATE INDEX idx_fact_oportunidad_tiempo
ON fact_oportunidad(tiempo_key);
GO


/* ============================================================
   VISTAS ANALÍTICAS PARA REPORTES DEL DATA WAREHOUSE
   ============================================================ */

CREATE OR ALTER VIEW vw_dw_oportunidades_resumen
AS
SELECT 
    ft.fact_oportunidad_id,
    ft.numero_oportunidad,
    dc.nombre_comercial AS cliente,
    dc.division_cliente,
    de.nombre AS gestor_comercial,
    de.rol,
    det.nombre AS etapa,
    det.porcentaje,
    dt.fecha,
    dt.anio,
    dt.mes,
    dt.nombre_mes,
    dt.trimestre,
    ft.estado,
    ft.tipo_oportunidad,
    ft.monto_potencial,
    ft.monto_ponderado
FROM fact_oportunidad ft
INNER JOIN dim_cliente dc
    ON ft.cliente_key = dc.cliente_key
INNER JOIN dim_empleado de
    ON ft.empleado_key = de.empleado_key
INNER JOIN dim_etapa det
    ON ft.etapa_key = det.etapa_key
INNER JOIN dim_tiempo dt
    ON ft.tiempo_key = dt.tiempo_key;
GO


CREATE OR ALTER VIEW vw_dw_resumen_por_estado
AS
SELECT 
    estado,
    COUNT(*) AS total_oportunidades,
    SUM(monto_potencial) AS total_monto_potencial,
    SUM(monto_ponderado) AS total_monto_ponderado,
    AVG(monto_potencial) AS promedio_monto_potencial
FROM fact_oportunidad
GROUP BY estado;
GO


CREATE OR ALTER VIEW vw_dw_resumen_por_gestor
AS
SELECT 
    de.nombre AS gestor_comercial,
    COUNT(*) AS total_oportunidades,
    SUM(ft.monto_potencial) AS total_monto_potencial,
    SUM(ft.monto_ponderado) AS total_monto_ponderado
FROM fact_oportunidad ft
INNER JOIN dim_empleado de
    ON ft.empleado_key = de.empleado_key
GROUP BY de.nombre;
GO