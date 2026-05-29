const { sql, getConnection } = require('../config/db');

async function listarClientes(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request()
      .execute('sp_listar_clientes');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al listar clientes',
      error: error.message
    });
  }
}

async function obtenerClientePorId(req, res) {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    const result = await pool.request()
      .input('cliente_id', sql.Int, Number(id))
      .execute('sp_obtener_cliente_por_id');

    if (result.recordset.length === 0) {
      return res.status(404).json({
        message: 'Cliente no encontrado'
      });
    }

    res.json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al obtener cliente',
      error: error.message
    });
  }
}

async function crearCliente(req, res) {
  try {
    const {
      nombre_comercial,
      direccion,
      telefono,
      celular,
      correo,
      division_cliente
    } = req.body;

    const pool = await getConnection();

    const result = await pool.request()
      .input('nombre_comercial', sql.VarChar(150), nombre_comercial)
      .input('direccion', sql.VarChar(250), direccion)
      .input('telefono', sql.VarChar(20), telefono || null)
      .input('celular', sql.VarChar(20), celular || null)
      .input('correo', sql.VarChar(120), correo || null)
      .input('division_cliente', sql.VarChar(30), division_cliente)
      .execute('sp_crear_cliente');

    res.status(201).json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al crear cliente',
      error: error.message
    });
  }
}

async function actualizarCliente(req, res) {
  try {
    const { id } = req.params;

    const {
      nombre_comercial,
      direccion,
      telefono,
      celular,
      correo,
      division_cliente
    } = req.body;

    const pool = await getConnection();

    const result = await pool.request()
      .input('cliente_id', sql.Int, Number(id))
      .input('nombre_comercial', sql.VarChar(150), nombre_comercial)
      .input('direccion', sql.VarChar(250), direccion)
      .input('telefono', sql.VarChar(20), telefono || null)
      .input('celular', sql.VarChar(20), celular || null)
      .input('correo', sql.VarChar(120), correo || null)
      .input('division_cliente', sql.VarChar(30), division_cliente)
      .execute('sp_actualizar_cliente');

    res.json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al actualizar cliente',
      error: error.message
    });
  }
}

async function eliminarCliente(req, res) {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    const result = await pool.request()
      .input('cliente_id', sql.Int, Number(id))
      .execute('sp_eliminar_cliente');

    res.json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al eliminar cliente',
      error: error.message
    });
  }
}

module.exports = {
  listarClientes,
  obtenerClientePorId,
  crearCliente,
  actualizarCliente,
  eliminarCliente
};