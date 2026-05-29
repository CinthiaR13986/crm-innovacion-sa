const API_OPORTUNIDADES = 'http://localhost:3000/api/oportunidades';
const API_CLIENTES = 'http://localhost:3000/api/clientes';
const API_CATALOGOS = 'http://localhost:3000/api/catalogos';

const oportunidadForm = document.getElementById('oportunidadForm');
const tablaOportunidades = document.getElementById('tablaOportunidades');
const pipeline = document.getElementById('pipeline');
const mensaje = document.getElementById('mensaje');

let etapas = [];
let oportunidades = [];

function mostrarMensaje(texto, tipo) {
  mensaje.textContent = texto;
  mensaje.className = `alert ${tipo}`;
  mensaje.style.display = 'block';

  setTimeout(() => {
    mensaje.style.display = 'none';
  }, 3500);
}

function badgeEstado(estado) {
  if (estado === 'GANADA') {
    return `<span class="badge badge-win">GANADA</span>`;
  }

  if (estado === 'PERDIDA') {
    return `<span class="badge badge-lost">PERDIDA</span>`;
  }

  return `<span class="badge badge-open">ABIERTA</span>`;
}

async function cargarClientes() {
  const response = await fetch(API_CLIENTES);
  const clientes = await response.json();

  const select = document.getElementById('cliente_id');
  select.innerHTML = '<option value="">Seleccione cliente</option>';

  clientes.forEach(cliente => {
    select.innerHTML += `
      <option value="${cliente.cliente_id}">
        ${cliente.nombre_comercial}
      </option>
    `;
  });
}

async function cargarContactos() {
  const response = await fetch(`${API_CATALOGOS}/contactos`);
  const contactos = await response.json();

  const select = document.getElementById('contacto_id');
  select.innerHTML = '<option value="">Seleccione contacto</option>';

  contactos.forEach(contacto => {
    select.innerHTML += `
      <option value="${contacto.contacto_id}" data-cliente="${contacto.cliente_id}">
        ${contacto.nombre_contacto} - ${contacto.cliente}
      </option>
    `;
  });
}

async function cargarEmpleados() {
  const response = await fetch(`${API_CATALOGOS}/empleados`);
  const empleados = await response.json();

  const gestor = document.getElementById('gestor_id');
  const asistente = document.getElementById('asistente_id');
  const gerente = document.getElementById('gerente_id');

  gestor.innerHTML = '<option value="">Seleccione gestor comercial</option>';
  asistente.innerHTML = '<option value="">Seleccione asistente</option>';
  gerente.innerHTML = '<option value="">Seleccione gerente</option>';

  empleados.forEach(emp => {
    if (emp.rol === 'GESTOR_COMERCIAL') {
      gestor.innerHTML += `<option value="${emp.empleado_id}">${emp.nombre}</option>`;
    }

    if (emp.rol === 'ASISTENTE_COMERCIAL') {
      asistente.innerHTML += `<option value="${emp.empleado_id}">${emp.nombre}</option>`;
    }

    if (emp.rol === 'GERENTE_COMERCIAL') {
      gerente.innerHTML += `<option value="${emp.empleado_id}">${emp.nombre}</option>`;
    }
  });
}

async function cargarEtapas() {
  const response = await fetch(`${API_CATALOGOS}/etapas`);
  etapas = await response.json();

  const select = document.getElementById('etapa_id');
  select.innerHTML = '<option value="">Seleccione etapa</option>';

  etapas.forEach(etapa => {
    select.innerHTML += `
      <option value="${etapa.etapa_id}">
        ${etapa.nombre} - ${etapa.porcentaje}%
      </option>
    `;
  });
}

async function cargarOportunidades() {
  const response = await fetch(API_OPORTUNIDADES);
  oportunidades = await response.json();

  tablaOportunidades.innerHTML = '';

  oportunidades.forEach(op => {
    tablaOportunidades.innerHTML += `
      <tr>
        <td>${op.oportunidad_id}</td>
        <td>${op.numero_oportunidad}</td>
        <td>${op.nombre_oportunidad}</td>
        <td>${op.cliente}</td>
        <td>${op.gestor_comercial}</td>
        <td>${op.etapa}</td>
        <td>${op.porcentaje}%</td>
        <td>${op.estado}</td>
        <td>Q ${Number(op.monto_potencial).toFixed(2)}</td>
        <td>Q ${Number(op.monto_ponderado).toFixed(2)}</td>
      </tr>
    `;
  });
}

function obtenerSiguienteEtapaId(etapaActualNombre) {
  const etapaActual = etapas.find(e => e.nombre === etapaActualNombre);

  if (!etapaActual) {
    return null;
  }

  const index = etapas.findIndex(e => e.etapa_id === etapaActual.etapa_id);

  if (index === -1 || index === etapas.length - 1) {
    return null;
  }

  return etapas[index + 1].etapa_id;
}

async function avanzarEtapa(oportunidadId, etapaActualNombre) {
  const siguienteEtapaId = obtenerSiguienteEtapaId(etapaActualNombre);

  if (!siguienteEtapaId) {
    mostrarMensaje('La oportunidad ya está en la última etapa.', 'error');
    return;
  }

  try {
    const response = await fetch(`${API_OPORTUNIDADES}/${oportunidadId}/etapa`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        etapa_id: siguienteEtapaId
      })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al avanzar etapa');
    }

    mostrarMensaje('Etapa actualizada correctamente', 'success');
    await cargarPipeline();
  } catch (error) {
    mostrarMensaje(error.message, 'error');
  }
}

async function cerrarOportunidad(oportunidadId, estado) {
  const comentario = prompt(`Ingrese comentario para cerrar como ${estado}:`);

  if (!comentario || comentario.trim() === '') {
    mostrarMensaje('Debe ingresar un comentario de cierre.', 'error');
    return;
  }

  try {
    const response = await fetch(`${API_OPORTUNIDADES}/${oportunidadId}/cerrar`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        estado,
        comentario_cierre: comentario
      })
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al cerrar oportunidad');
    }

    mostrarMensaje(`Oportunidad marcada como ${estado}`, 'success');
    await cargarPipeline();
  } catch (error) {
    mostrarMensaje(error.message, 'error');
  }
}

function renderPipeline() {
  pipeline.innerHTML = '';

  etapas.forEach(etapa => {
    const columna = document.createElement('div');
    columna.className = 'pipeline-column';

    const oportunidadesEtapa = oportunidades.filter(op => op.etapa === etapa.nombre);

    columna.innerHTML = `
      <h3>${etapa.nombre}</h3>
      <div class="percent">${etapa.porcentaje}% de avance</div>
    `;

    oportunidadesEtapa.forEach(op => {
      const card = document.createElement('div');
      card.className = 'opportunity-card';

      card.innerHTML = `
        <h4>${op.numero_oportunidad}</h4>
        <p><strong>${op.nombre_oportunidad}</strong></p>
        <p>Cliente: ${op.cliente}</p>
        <p>Gestor: ${op.gestor_comercial}</p>
        <p>Monto: Q ${Number(op.monto_potencial).toFixed(2)}</p>
        <p>Ponderado: Q ${Number(op.monto_ponderado).toFixed(2)}</p>
        <p>${badgeEstado(op.estado)}</p>

        <div class="card-actions">
          ${
            op.estado === 'ABIERTA'
              ? `<button class="btn-next" onclick="avanzarEtapa(${op.oportunidad_id}, '${op.etapa}')">Avanzar</button>`
              : ''
          }

          ${
            op.estado === 'ABIERTA' && etapa.porcentaje === 100
              ? `
                <button class="btn-win" onclick="cerrarOportunidad(${op.oportunidad_id}, 'GANADA')">Ganada</button>
                <button class="btn-lost" onclick="cerrarOportunidad(${op.oportunidad_id}, 'PERDIDA')">Perdida</button>
              `
              : ''
          }
        </div>
      `;

      columna.appendChild(card);
    });

    pipeline.appendChild(columna);
  });
}

async function cargarPipeline() {
  try {
    await cargarOportunidades();
    renderPipeline();
  } catch (error) {
    mostrarMensaje('Error al cargar pipeline', 'error');
  }
}

oportunidadForm.addEventListener('submit', async (event) => {
  event.preventDefault();

  const oportunidad = {
    numero_oportunidad: document.getElementById('numero_oportunidad').value,
    nombre_oportunidad: document.getElementById('nombre_oportunidad').value,
    cliente_id: Number(document.getElementById('cliente_id').value),
    contacto_id: Number(document.getElementById('contacto_id').value),
    gestor_id: Number(document.getElementById('gestor_id').value),
    asistente_id: document.getElementById('asistente_id').value || null,
    gerente_id: document.getElementById('gerente_id').value || null,
    etapa_id: Number(document.getElementById('etapa_id').value),
    tipo_oportunidad: document.getElementById('tipo_oportunidad').value,
    fecha_inicio: document.getElementById('fecha_inicio').value,
    cierre_planificado_dias: Number(document.getElementById('cierre_planificado_dias').value),
    monto_potencial: Number(document.getElementById('monto_potencial').value)
  };

  try {
    const response = await fetch(API_OPORTUNIDADES, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(oportunidad)
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al crear oportunidad');
    }

    mostrarMensaje('Oportunidad creada correctamente', 'success');
    oportunidadForm.reset();
    await cargarPipeline();
  } catch (error) {
    mostrarMensaje(error.message, 'error');
  }
});

async function iniciarPagina() {
  try {
    await cargarClientes();
    await cargarContactos();
    await cargarEmpleados();
    await cargarEtapas();
    await cargarPipeline();
  } catch (error) {
    mostrarMensaje('Error al iniciar pantalla de oportunidades', 'error');
  }
}

iniciarPagina();