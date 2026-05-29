const express = require('express');
const cors = require('cors');
require('dotenv').config();

const clienteRoutes = require('./routes/cliente.routes');
const oportunidadRoutes = require('./routes/oportunidad.routes');
const reporteRoutes = require('./routes/reporte.routes');
const catalogoRoutes = require('./routes/catalogo.routes');
const actividadRoutes = require('./routes/actividad.routes');
const procesoRoutes = require('./routes/proceso.routes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'API CRM Innovacion S.A. funcionando correctamente'
  });
});

app.use('/api/clientes', clienteRoutes);
app.use('/api/oportunidades', oportunidadRoutes);
app.use('/api/reportes', reporteRoutes);
app.use('/api/catalogos', catalogoRoutes);
app.use('/api/actividades', actividadRoutes);
app.use('/api/procesos', procesoRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
});