const express = require('express');
const router = express.Router();

const {
  listarActividades,
  crearActividad
} = require('../controllers/actividad.controller');

router.get('/', listarActividades);
router.post('/', crearActividad);

module.exports = router;