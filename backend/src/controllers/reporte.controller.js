const { sql, getConnection } = require('../config/db');

async function reporteOportunidadesPorFecha(req, res) {
  try {
    const { fecha_inicio, fecha_fin } = req.query;

    const pool = await getConnection();

    const result = await pool.request()
      .input('fecha_inicio', sql.Date, fecha_inicio)
      .input('fecha_fin', sql.Date, fecha_fin)
      .execute('sp_reporte_oportunidades_por_fecha');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al generar reporte por fecha',
      error: error.message
    });
  }
}

async function reporteOportunidadesPorGestor(req, res) {
  try {
    const { gestor_id } = req.params;

    const pool = await getConnection();

    const result = await pool.request()
      .input('gestor_id', sql.Int, Number(gestor_id))
      .execute('sp_reporte_oportunidades_por_gestor');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al generar reporte por gestor',
      error: error.message
    });
  }
}

async function reporteOportunidadesPorEstado(req, res) {
  try {
    const { estado } = req.params;

    const pool = await getConnection();

    const result = await pool.request()
      .input('estado', sql.VarChar(20), estado)
      .execute('sp_reporte_oportunidades_por_estado');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al generar reporte por estado',
      error: error.message
    });
  }
}

async function resumenGerencial(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request()
      .execute('sp_reporte_resumen_gerencial');

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al generar resumen gerencial',
      error: error.message
    });
  }
}

async function reporteDataWarehouse(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request().query(`
      SELECT 
        fact_oportunidad_id,
        numero_oportunidad,
        cliente,
        division_cliente,
        gestor_comercial,
        etapa,
        porcentaje,
        fecha,
        anio,
        mes,
        nombre_mes,
        trimestre,
        estado,
        tipo_oportunidad,
        monto_potencial,
        monto_ponderado
      FROM DW_CRM_Innovacion.dbo.vw_dw_oportunidades_resumen
      ORDER BY fecha DESC
    `);

    res.json(result.recordset);
  } catch (error) {
    res.status(500).json({
      message: 'Error al consultar Data Warehouse',
      error: error.message
    });
  }
}

module.exports = {
  reporteOportunidadesPorFecha,
  reporteOportunidadesPorGestor,
  reporteOportunidadesPorEstado,
  resumenGerencial,
  reporteDataWarehouse
};