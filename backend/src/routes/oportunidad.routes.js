const express = require('express');
const router = express.Router();

const {
  listarOportunidades,
  crearOportunidad,
  actualizarEtapaOportunidad,
  cerrarOportunidad
} = require('../controllers/oportunidad.controller');

router.get('/', listarOportunidades);
router.post('/', crearOportunidad);
router.patch('/:id/etapa', actualizarEtapaOportunidad);
router.patch('/:id/cerrar', cerrarOportunidad);

module.exports = router;