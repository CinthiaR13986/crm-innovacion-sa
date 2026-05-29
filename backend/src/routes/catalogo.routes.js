const express = require('express');
const router = express.Router();

const {
  listarEtapas,
  listarEmpleados,
  listarContactos
} = require('../controllers/catalogo.controller');

router.get('/etapas', listarEtapas);
router.get('/empleados', listarEmpleados);
router.get('/contactos', listarContactos);

module.exports = router;