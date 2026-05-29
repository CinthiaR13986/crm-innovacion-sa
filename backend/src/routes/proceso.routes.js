const express = require('express');
const router = express.Router();

const {
  refrescarDataWarehouse,
  refrescarReplicaLocal
} = require('../controllers/proceso.controller');

router.post('/refrescar-datawarehouse', refrescarDataWarehouse);
router.post('/refrescar-replica', refrescarReplicaLocal);

module.exports = router;