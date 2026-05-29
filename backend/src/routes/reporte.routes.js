const express = require('express');
const router = express.Router();

const {
  reporteOportunidadesPorFecha,
  reporteOportunidadesPorGestor,
  reporteOportunidadesPorEstado,
  resumenGerencial,
  reporteDataWarehouse
} = require('../controllers/reporte.controller');

router.get('/oportunidades/fecha', reporteOportunidadesPorFecha);
router.get('/oportunidades/gestor/:gestor_id', reporteOportunidadesPorGestor);
router.get('/oportunidades/estado/:estado', reporteOportunidadesPorEstado);
router.get('/resumen-gerencial', resumenGerencial);
router.get('/datawarehouse', reporteDataWarehouse);

module.exports = router;