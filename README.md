# CRM Innovación S.A.

El proyecto fue desarrollado como prototipo académico para la gestión comercial y demostración de conceptos de Base de Datos, incluyendo procedimientos almacenados, triggers, índices, consultas avanzadas, ETL y Data Warehouse.

---

## Tecnologías utilizadas

* **SQL Server Developer Edition**
* **SQL Server Management Studio**
* **Node.js**
* **Express.js**
* **JavaScript**
* **HTML5**
* **CSS3**
* **Git / GitHub**

---

## Estructura del proyecto

```text
crm-innovacion-sa/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── routes/
│   │   └── app.js
│   ├── package.json
│   ├── package-lock.json
│   └── .env.example
│
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_catalogs.sql
│   ├── 04_stored_procedures.sql
│   ├── 05_triggers.sql
│   ├── 06_indexes.sql
│   ├── 07_reports.sql
│   ├── 08_datawarehouse_etl.sql
│   ├── 09_replica_local.sql
│   ├── 10_refresh_replica.sql
│   └── 11_refresh_datawarehouse.sql
│
├── frontend/
│   ├── index.html
│   ├── clientes.html
│   ├── oportunidades.html
│   ├── actividades.html
│   ├── reportes.html
│   ├── css/
│   └── js/
│
├── .gitignore
└── README.md
```

---

## Bases de datos utilizadas

El proyecto utiliza tres bases de datos en SQL Server:

### 1. CRM_Innovacion

Base de datos transaccional principal del sistema.

Contiene las tablas:

* `cliente`
* `contacto`
* `empleado_comercial`
* `etapa_oportunidad`
* `oportunidad`
* `actividad`
* `auditoria`

### 2. DW_CRM_Innovacion

Base de datos analítica utilizada como Data Warehouse.

Contiene:

* `dim_cliente`
* `dim_empleado`
* `dim_etapa`
* `dim_tiempo`
* `fact_oportunidad`

### 3. CRM_Innovacion_Replica

Base de datos secundaria utilizada como réplica local simulada para demostrar disponibilidad y respaldo operativo de información.

---

## Ejecución de scripts SQL

Abrir **SQL Server Management Studio** y ejecutar los scripts de la carpeta `database` en el siguiente orden:

```text
1. 01_create_database.sql
2. 02_create_tables.sql
3. 03_insert_catalogs.sql
4. 04_stored_procedures.sql
5. 05_triggers.sql
6. 06_indexes.sql
7. 07_reports.sql
8. 08_datawarehouse_etl.sql
9. 09_replica_local.sql
10. 10_refresh_replica.sql
11. 11_refresh_datawarehouse.sql
```

---

## Funcionalidades principales

### Gestión de clientes

* Crear clientes.
* Consultar clientes.
* Actualizar clientes.
* Eliminar clientes de forma lógica.
* Clasificar clientes como potenciales o finales.

### Gestión de oportunidades

* Crear oportunidades comerciales.
* Visualizar oportunidades en vista tipo pipeline CRM.
* Avanzar oportunidades por etapa.
* Calcular monto ponderado según porcentaje de avance.
* Cerrar oportunidades como ganadas o perdidas.
* Validar que una oportunidad solo pueda cerrarse al llegar al 100%.

### Gestión de actividades

* Crear actividades relacionadas con clientes, contactos y oportunidades.
* Registrar llamadas, reuniones, tareas y notas.
* Habilitar campos dinámicos según el tipo de actividad.
* Registrar prioridad, fecha, hora y estado.
* Registrar ubicación para reuniones.

### Reportes

* Resumen gerencial de oportunidades.
* Reporte de oportunidades por estado.
* Reporte de oportunidades por gestor comercial.
* Reporte de oportunidades por rango de fechas.
* Consulta de información analítica desde el Data Warehouse.

### Auditoría

El sistema registra automáticamente operaciones importantes mediante triggers en la tabla `auditoria`.

Se auditan operaciones como:

* Inserción de clientes.
* Actualización de clientes.
* Eliminación lógica de clientes.
* Creación de oportunidades.
* Actualización de oportunidades.
* Creación de actividades.

### Data Warehouse y ETL

El proyecto incluye un proceso ETL que extrae información desde la base transaccional `CRM_Innovacion`, la transforma y la carga en la base analítica `DW_CRM_Innovacion`.

El modelo analítico permite consultar oportunidades por:

* Cliente.
* Gestor comercial.
* Etapa.
* Tiempo.
* Estado.
* Monto potencial.
* Monto ponderado.

### Réplica local

El proyecto incluye una base secundaria `CRM_Innovacion_Replica`, utilizada para simular una réplica local de la información principal.

---

## Configuración del backend

Entrar a la carpeta `backend`:

```bash
cd backend
```

Instalar dependencias:

```bash
npm install
```

Crear un archivo `.env` basado en `.env.example`:

```env
PORT=3000

DB_USER=sa
DB_PASSWORD=TU_PASSWORD
DB_SERVER=127.0.0.1
DB_DATABASE=CRM_Innovacion
DB_PORT=1433
```

Ejecutar el backend en modo desarrollo:

```bash
npm run dev
```

El servidor se ejecutará en:

```text
http://localhost:3000
```

---

## Endpoints principales

### Clientes

```text
GET    /api/clientes
GET    /api/clientes/:id
POST   /api/clientes
PUT    /api/clientes/:id
DELETE /api/clientes/:id
```

### Oportunidades

```text
GET   /api/oportunidades
POST  /api/oportunidades
PATCH /api/oportunidades/:id/etapa
PATCH /api/oportunidades/:id/cerrar
```

### Actividades

```text
GET  /api/actividades
POST /api/actividades
```

### Reportes

```text
GET /api/reportes/resumen-gerencial
GET /api/reportes/oportunidades/estado/:estado
GET /api/reportes/oportunidades/gestor/:gestor_id
GET /api/reportes/oportunidades/fecha
GET /api/reportes/datawarehouse
```

### Catálogos

```text
GET /api/catalogos/etapas
GET /api/catalogos/empleados
GET /api/catalogos/contactos
```

### Procesos

```text
POST /api/procesos/refrescar-replica
```

---

## Ejecución del frontend

El frontend se encuentra en la carpeta `frontend`.

Puede abrirse directamente desde el navegador o utilizando la extensión **Live Server** de Visual Studio Code.

Archivo principal:

```text
frontend/index.html
```

---

## Flujo general del sistema

1. Se crean clientes y contactos.
2. Se crean oportunidades comerciales asociadas a clientes.
3. Las oportunidades avanzan por etapas del pipeline comercial.
4. Al llegar al 100%, pueden cerrarse como ganadas o perdidas.
5. Se registran actividades como llamadas, reuniones, tareas y notas.
6. Los triggers generan auditoría automáticamente.
7. Los reportes permiten analizar la información comercial.
8. El ETL carga datos al Data Warehouse.
9. La réplica local permite demostrar disponibilidad de información.

---

## Seguridad

El archivo `.env` no debe subirse a GitHub porque contiene credenciales locales.

Por eso se incluye únicamente:

```text
backend/.env.example
```

---

## Autor

Proyecto académico desarrollado para el curso de Base de Datos.
