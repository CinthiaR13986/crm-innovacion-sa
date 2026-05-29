const { sql, getConnection } = require('../config/db');

function normalizarHora(valor) {
  if (!valor) {
    return null;
  }

  // Si viene como "10:00", lo convierte a "10:00:00"
  if (/^\d{2}:\d{2}$/.test(valor)) {
    return `${valor}:00`;
  }

  return valor;
}

async function listarActividades(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request()
      .execute('sp_listar_actividades');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al listar actividades',
      error: error.message
    });
  }
}

async function crearActividad(req, res) {
  try {
    const {
      cliente_id,
      contacto_id,
      oportunidad_id,
      responsable_id,
      tipo_actividad,
      asunto,
      fecha,
      hora_inicio,
      hora_final,
      prioridad,
      comentario,
      estado,
      calle,
      ciudad,
      sala
    } = req.body;

    const pool = await getConnection();

    const result = await pool.request()
      .input('cliente_id', sql.Int, Number(cliente_id))
      .input('contacto_id', sql.Int, contacto_id ? Number(contacto_id) : null)
      .input('oportunidad_id', sql.Int, oportunidad_id ? Number(oportunidad_id) : null)
      .input('responsable_id', sql.Int, Number(responsable_id))
      .input('tipo_actividad', sql.VarChar(30), tipo_actividad)
      .input('asunto', sql.VarChar(150), asunto)
      .input('fecha', sql.Date, fecha)
      .input('hora_inicio', sql.VarChar(8), normalizarHora(hora_inicio))
      .input('hora_final', sql.VarChar(8), normalizarHora(hora_final))
      .input('prioridad', sql.VarChar(20), prioridad)
      .input('comentario', sql.VarChar(300), comentario || null)
      .input('estado', sql.VarChar(30), estado)
      .input('calle', sql.VarChar(150), calle || null)
      .input('ciudad', sql.VarChar(100), ciudad || null)
      .input('sala', sql.VarChar(100), sala || null)
      .execute('sp_crear_actividad');

    res.status(201).json(result.recordset[0]);
  } catch (error) {
    res.status(500).json({
      message: 'Error al crear actividad',
      error: error.message
    });
  }
}

module.exports = {
  listarActividades,
  crearActividad
};