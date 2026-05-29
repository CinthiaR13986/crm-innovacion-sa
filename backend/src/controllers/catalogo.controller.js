const { getConnection } = require('../config/db');

async function listarEtapas(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request().query(`
      SELECT 
        etapa_id,
        nombre,
        porcentaje
      FROM etapa_oportunidad
      ORDER BY porcentaje ASC
    `);

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al listar etapas',
      error: error.message
    });
  }
}

async function listarEmpleados(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request().query(`
      SELECT 
        empleado_id,
        nombre,
        rol,
        correo
      FROM empleado_comercial
      WHERE estado = 1
      ORDER BY nombre ASC
    `);

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al listar empleados',
      error: error.message
    });
  }
}

async function listarContactos(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request().query(`
      SELECT 
        co.contacto_id,
        co.cliente_id,
        co.nombre_contacto,
        c.nombre_comercial AS cliente
      FROM contacto co
      INNER JOIN cliente c
        ON co.cliente_id = c.cliente_id
      WHERE co.estado = 1
      ORDER BY co.nombre_contacto ASC
    `);

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al listar contactos',
      error: error.message
    });
  }
}

module.exports = {
  listarEtapas,
  listarEmpleados,
  listarContactos
};