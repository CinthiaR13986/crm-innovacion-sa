const API_BASE = 'http://localhost:3000/api/reportes';
const API_PROCESOS = 'http://localhost:3000/api/procesos';
const API_CATALOGOS = 'http://localhost:3000/api/catalogos';
const tablaGestor = document.getElementById('tablaGestor');

const cardsResumen = document.getElementById('cardsResumen');
const tablaEstado = document.getElementById('tablaEstado');
const tablaFecha = document.getElementById('tablaFecha');
const tablaDW = document.getElementById('tablaDW');
const formFecha = document.getElementById('formFecha');
const mensajeProcesos = document.getElementById('mensajeProcesos');

function mostrarMensajeProceso(texto, tipo) {
  mensajeProcesos.textContent = texto;
  mensajeProcesos.className = `alert ${tipo}`;
  mensajeProcesos.style.display = 'block';

  setTimeout(() => {
    mensajeProcesos.style.display = 'none';
  }, 4000);
}

async function cargarGestores() {
  try {
    const response = await fetch(`${API_CATALOGOS}/empleados`);
    const empleados = await response.json();

    const selectGestor = document.getElementById('gestor_id');
    selectGestor.innerHTML = '<option value="">Seleccione gestor comercial</option>';

    empleados
      .filter(emp => emp.rol === 'GESTOR_COMERCIAL')
      .forEach(emp => {
        selectGestor.innerHTML += `
          <option value="${emp.empleado_id}">
            ${emp.nombre}
          </option>
        `;
      });
  } catch (error) {
    alert('Error al cargar gestores comerciales');
  }
}

async function cargarPorGestor() {
  try {
    const gestorId = document.getElementById('gestor_id').value;

    if (!gestorId) {
      alert('Debe seleccionar un gestor comercial');
      return;
    }

    const response = await fetch(`${API_BASE}/oportunidades/gestor/${gestorId}`);
    const datos = await response.json();

    if (!response.ok) {
      throw new Error(datos.error || 'Error al consultar oportunidades por gestor');
    }

    tablaGestor.innerHTML = '';

    datos.forEach(item => {
      tablaGestor.innerHTML += `
        <tr>
          <td>${item.numero_oportunidad}</td>
          <td>${item.nombre_oportunidad}</td>
          <td>${item.cliente}</td>
          <td>${item.contacto ?? ''}</td>
          <td>${item.etapa}</td>
          <td>${item.porcentaje_avance}%</td>
          <td><span class="${claseEstado(item.estado)}">${item.estado}</span></td>
          <td>${formatoFecha(item.fecha_inicio)}</td>
          <td>${formatoMoneda(item.monto_potencial)}</td>
          <td>${formatoMoneda(item.monto_ponderado)}</td>
        </tr>
      `;
    });
  } catch (error) {
    alert(error.message || 'Error al cargar oportunidades por gestor');
  }
}

async function refrescarReplicaLocal() {
  const confirmar = confirm('¿Desea actualizar la réplica local desde la base principal?');

  if (!confirmar) {
    return;
  }

  try {
    const response = await fetch(`${API_PROCESOS}/refrescar-replica`, {
      method: 'POST'
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al refrescar réplica local');
    }

    mostrarMensajeProceso('Réplica local actualizada correctamente', 'success');
  } catch (error) {
    mostrarMensajeProceso(error.message, 'error');
  }
}

function formatoMoneda(valor) {
  return `Q ${Number(valor || 0).toFixed(2)}`;
}

function formatoFecha(valor) {
  if (!valor) {
    return '';
  }

  return valor.substring(0, 10);
}

function claseEstado(estado) {
  if (estado === 'GANADA') {
    return 'badge badge-win';
  }

  if (estado === 'PERDIDA') {
    return 'badge badge-lost';
  }

  return 'badge badge-open';
}

async function cargarResumen() {
  try {
    if (!cardsResumen) {
      throw new Error('No existe el contenedor cardsResumen en reportes.html');
    }

    const response = await fetch(`${API_BASE}/resumen-gerencial`);
    const datos = await response.json();

    if (!response.ok) {
      throw new Error(datos.error || 'Error al consultar resumen gerencial');
    }

    cardsResumen.innerHTML = '';

    datos.forEach(item => {
      cardsResumen.innerHTML += `
        <div class="dashboard-card">
          <h3>${item.estado}</h3>
          <p class="metric">${item.total_oportunidades}</p>
          <p><strong>Monto potencial:</strong> ${formatoMoneda(item.total_monto_potencial)}</p>
          <p><strong>Monto ponderado:</strong> ${formatoMoneda(item.total_monto_ponderado)}</p>
          <p><strong>Promedio:</strong> ${formatoMoneda(item.promedio_monto_potencial)}</p>
        </div>
      `;
    });
  } catch (error) {
    console.error(error);
    alert(error.message || 'Error al cargar resumen gerencial');
  }
}

async function cargarPorEstado() {
  try {
    const estado = document.getElementById('estado').value;
    const response = await fetch(`${API_BASE}/oportunidades/estado/${estado}`);
    const datos = await response.json();

    tablaEstado.innerHTML = '';

    datos.forEach(item => {
      tablaEstado.innerHTML += `
        <tr>
          <td>${item.numero_oportunidad}</td>
          <td>${item.nombre_oportunidad}</td>
          <td>${item.cliente}</td>
          <td>${item.gestor_comercial}</td>
          <td>${item.etapa}</td>
          <td><span class="${claseEstado(item.estado)}">${item.estado}</span></td>
          <td>${formatoMoneda(item.monto_potencial)}</td>
          <td>${formatoMoneda(item.monto_ponderado)}</td>
        </tr>
      `;
    });
  } catch (error) {
    alert('Error al cargar oportunidades por estado');
  }
}

formFecha.addEventListener('submit', async (event) => {
  event.preventDefault();

  try {
    const fechaInicio = document.getElementById('fecha_inicio').value;
    const fechaFin = document.getElementById('fecha_fin').value;

    const response = await fetch(
      `${API_BASE}/oportunidades/fecha?fecha_inicio=${fechaInicio}&fecha_fin=${fechaFin}`
    );

    const datos = await response.json();

    tablaFecha.innerHTML = '';

    datos.forEach(item => {
      tablaFecha.innerHTML += `
        <tr>
          <td>${item.numero_oportunidad}</td>
          <td>${item.nombre_oportunidad}</td>
          <td>${item.cliente}</td>
          <td>${item.gestor_comercial}</td>
          <td><span class="${claseEstado(item.estado)}">${item.estado}</span></td>
          <td>${formatoFecha(item.fecha_inicio)}</td>
          <td>${formatoMoneda(item.monto_potencial)}</td>
        </tr>
      `;
    });
  } catch (error) {
    alert('Error al cargar oportunidades por fecha');
  }
});

async function cargarDataWarehouse() {
  try {
    const response = await fetch(`${API_BASE}/datawarehouse`);
    const datos = await response.json();

    tablaDW.innerHTML = '';

    datos.forEach(item => {
      tablaDW.innerHTML += `
        <tr>
          <td>${item.numero_oportunidad}</td>
          <td>${item.cliente}</td>
          <td>${item.gestor_comercial}</td>
          <td>${item.etapa}</td>
          <td>${item.porcentaje}%</td>
          <td>${formatoFecha(item.fecha)}</td>
          <td><span class="${claseEstado(item.estado)}">${item.estado}</span></td>
          <td>${formatoMoneda(item.monto_potencial)}</td>
          <td>${formatoMoneda(item.monto_ponderado)}</td>
        </tr>
      `;
    });
  } catch (error) {
    alert('Error al cargar Data Warehouse');
  }
}

cargarResumen();
cargarPorEstado();
cargarDataWarehouse();
cargarGestores();