const { sql, getConnection } = require('../config/db');

async function listarOportunidades(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request()
      .execute('sp_listar_oportunidades');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al listar oportunidades',
      error: error.message
    });
  }
}

async function crearOportunidad(req, res) {
  try {
    const {
      numero_oportunidad,
      cliente_id,
      contacto_id,
      gestor_id,
      asistente_id,
      gerente_id,
      etapa_id,
      nombre_oportunidad,
      tipo_oportunidad,
      fecha_inicio,
      cierre_planificado_dias,
      monto_potencial
    } = req.body;

    const pool = await getConnection();

    const result = await pool.request()
      .input('numero_oportunidad', sql.VarChar(30), numero_oportunidad)
      .input('cliente_id', sql.Int, Number(cliente_id))
      .input('contacto_id', sql.Int, Number(contacto_id))
      .input('gestor_id', sql.Int, Number(gestor_id))
      .input('asistente_id', sql.Int, asistente_id ? Number(asistente_id) : null)
      .input('gerente_id', sql.Int, gerente_id ? Number(gerente_id) : null)
      .input('etapa_id', sql.Int, Number(etapa_id))
      .input('nombre_oportunidad', sql.VarChar(150), nombre_oportunidad)
      .input('tipo_oportunidad', sql.VarChar(20), tipo_oportunidad)
      .input('fecha_inicio', sql.Date, fecha_inicio)
      .input('cierre_planificado_dias', sql.Int, Number(cierre_planificado_dias))
      .input('monto_potencial', sql.Decimal(12, 2), Number(monto_potencial))
      .execute('sp_crear_oportunidad');

    res.status(201).json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al crear oportunidad',
      error: error.message
    });
  }
}

async function actualizarEtapaOportunidad(req, res) {
  try {
    const { id } = req.params;
    const { etapa_id } = req.body;

    const pool = await getConnection();

    const result = await pool.request()
      .input('oportunidad_id', sql.Int, Number(id))
      .input('etapa_id', sql.Int, Number(etapa_id))
      .execute('sp_actualizar_etapa_oportunidad');

    res.json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al actualizar etapa de oportunidad',
      error: error.message
    });
  }
}

async function cerrarOportunidad(req, res) {
  try {
    const { id } = req.params;
    const { estado, comentario_cierre } = req.body;

    const pool = await getConnection();

    const result = await pool.request()
      .input('oportunidad_id', sql.Int, Number(id))
      .input('estado', sql.VarChar(20), estado)
      .input('comentario_cierre', sql.VarChar(300), comentario_cierre)
      .execute('sp_cerrar_oportunidad');

    res.json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al cerrar oportunidad',
      error: error.message
    });
  }
}

module.exports = {
  listarOportunidades,
  crearOportunidad,
  actualizarEtapaOportunidad,
  cerrarOportunidad
};