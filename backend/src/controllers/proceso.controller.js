const { getConnection } = require('../config/db');

async function refrescarDataWarehouse(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request().query(`
      USE DW_CRM_Innovacion;
      EXEC sp_refrescar_datawarehouse;
    `);

    res.json({
      message: 'Data Warehouse actualizado correctamente',
      result: result.recordsets?.[0] || []
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error al refrescar Data Warehouse',
      error: error.message
    });
  }
}

async function refrescarReplicaLocal(req, res) {
  try {
    const pool = await getConnection();

    const result = await pool.request().query(`
      USE CRM_Innovacion_Replica;
      EXEC sp_refrescar_replica_local;
    `);

    res.json({
      message: 'Réplica local actualizada correctamente',
      result: result.recordsets?.[0] || []
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error al refrescar réplica local',
      error: error.message
    });
  }
}

module.exports = {
  refrescarDataWarehouse,
  refrescarReplicaLocal
};