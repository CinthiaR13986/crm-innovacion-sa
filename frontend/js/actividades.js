const API_ACTIVIDADES = 'http://localhost:3000/api/actividades';
const API_CLIENTES = 'http://localhost:3000/api/clientes';
const API_OPORTUNIDADES = 'http://localhost:3000/api/oportunidades';
const API_CATALOGOS = 'http://localhost:3000/api/catalogos';

const actividadForm = document.getElementById('actividadForm');
const tablaActividades = document.getElementById('tablaActividades');
const mensaje = document.getElementById('mensaje');

function mostrarMensaje(texto, tipo) {
  mensaje.textContent = texto;
  mensaje.className = `alert ${tipo}`;
  mensaje.style.display = 'block';

  setTimeout(() => {
    mensaje.style.display = 'none';
  }, 3000);
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
      <option value="${contacto.contacto_id}">
        ${contacto.nombre_contacto} - ${contacto.cliente}
      </option>
    `;
  });
}

async function cargarResponsables() {
  const response = await fetch(`${API_CATALOGOS}/empleados`);
  const empleados = await response.json();

  const select = document.getElementById('responsable_id');
  select.innerHTML = '<option value="">Seleccione responsable</option>';

  empleados.forEach(emp => {
    select.innerHTML += `
      <option value="${emp.empleado_id}">
        ${emp.nombre} - ${emp.rol}
      </option>
    `;
  });
}

async function cargarOportunidadesSelect() {
  const response = await fetch(API_OPORTUNIDADES);
  const oportunidades = await response.json();

  const select = document.getElementById('oportunidad_id');
  select.innerHTML = '<option value="">Seleccione oportunidad</option>';

  oportunidades.forEach(op => {
    select.innerHTML += `
      <option value="${op.oportunidad_id}">
        ${op.numero_oportunidad} - ${op.nombre_oportunidad}
      </option>
    `;
  });
}

async function cargarActividades() {
  try {
    const response = await fetch(API_ACTIVIDADES);
    const actividades = await response.json();

    tablaActividades.innerHTML = '';

    actividades.forEach(act => {
      tablaActividades.innerHTML += `
        <tr>
          <td>${act.actividad_id}</td>
          <td>${act.cliente}</td>
          <td>${act.contacto ?? ''}</td>
          <td>${act.numero_oportunidad ?? ''}</td>
          <td>${act.responsable}</td>
          <td>${act.tipo_actividad}</td>
          <td>${act.asunto}</td>
          <td>${act.fecha ? act.fecha.substring(0, 10) : ''}</td>
          <td>${act.duracion_minutos ?? ''}</td>
          <td>${act.prioridad}</td>
          <td>${act.estado}</td>
        </tr>
      `;
    });
  } catch (error) {
    mostrarMensaje('Error al cargar actividades', 'error');
  }
}

function limpiarEstados() {
  const estado = document.getElementById('estado');
  estado.innerHTML = '<option value="">Seleccione estado</option>';
}

function cargarEstadosTarea() {
  const estado = document.getElementById('estado');

  estado.innerHTML = `
    <option value="">Seleccione estado</option>
    <option value="EN_PROCESO">En proceso</option>
    <option value="EN_ESPERA">En espera</option>
    <option value="CONCLUIDO">Concluido</option>
    <option value="NO_INICIADO">No iniciado</option>
  `;
}

function cargarEstadosReunion() {
  const estado = document.getElementById('estado');

  estado.innerHTML = `
    <option value="">Seleccione estado</option>
    <option value="EN_PROCESO">En proceso</option>
    <option value="EN_ESPERA">En espera</option>
    <option value="CONCLUIDO">Concluido</option>
    <option value="NO_CONCLUIDO">No concluido</option>
  `;
}

function cargarEstadosGenerales() {
  const estado = document.getElementById('estado');

  estado.innerHTML = `
    <option value="">Seleccione estado</option>
    <option value="NO_INICIADO">No iniciado</option>
    <option value="EN_PROCESO">En proceso</option>
    <option value="EN_ESPERA">En espera</option>
    <option value="CONCLUIDO">Concluido</option>
    <option value="NO_CONCLUIDO">No concluido</option>
    <option value="CERRADO">Cerrado</option>
    <option value="INACTIVO">Inactivo</option>
  `;
}

function mostrarCampo(id, mostrar) {
  const campo = document.getElementById(id);

  if (!campo) {
    return;
  }

  if (mostrar) {
    campo.classList.remove('hidden');
  } else {
    campo.classList.add('hidden');
  }
}

function configurarCamposPorTipo() {
  const tipo = document.getElementById('tipo_actividad').value;

  const estado = document.getElementById('estado');
  const calle = document.getElementById('calle');
  const ciudad = document.getElementById('ciudad');
  const sala = document.getElementById('sala');
  const asunto = document.getElementById('asunto');
  const horaFinal = document.getElementById('hora_final');

  limpiarEstados();

  mostrarCampo('grupoFecha', true);
  mostrarCampo('grupoHoraInicio', true);
  mostrarCampo('grupoHoraFinal', true);
  mostrarCampo('grupoPrioridad', true);
  mostrarCampo('grupoEstado', true);
  mostrarCampo('grupoCalle', false);
  mostrarCampo('grupoCiudad', false);
  mostrarCampo('grupoSala', false);

  asunto.required = true;
  estado.required = true;
  horaFinal.required = false;
  calle.required = false;
  ciudad.required = false;
  sala.required = false;

  if (tipo === 'TAREA') {
    cargarEstadosTarea();

    mostrarCampo('grupoEstado', true);
    mostrarCampo('grupoCalle', false);
    mostrarCampo('grupoCiudad', false);
    mostrarCampo('grupoSala', false);
  }

  if (tipo === 'REUNION') {
    cargarEstadosReunion();

    mostrarCampo('grupoEstado', true);
    mostrarCampo('grupoCalle', true);
    mostrarCampo('grupoCiudad', true);
    mostrarCampo('grupoSala', true);

    calle.required = true;
    ciudad.required = true;
    sala.required = true;
  }

  if (tipo === 'NOTA') {
    mostrarCampo('grupoFecha', true);
    mostrarCampo('grupoHoraInicio', true);
    mostrarCampo('grupoHoraFinal', false);
    mostrarCampo('grupoPrioridad', true);
    mostrarCampo('grupoEstado', false);
    mostrarCampo('grupoCalle', false);
    mostrarCampo('grupoCiudad', false);
    mostrarCampo('grupoSala', false);

    asunto.required = false;
    estado.required = false;
    horaFinal.required = false;

    document.getElementById('estado').value = '';
    document.getElementById('calle').value = '';
    document.getElementById('ciudad').value = '';
    document.getElementById('sala').value = '';
  }

  if (tipo === 'LLAMADA') {
    cargarEstadosGenerales();

    mostrarCampo('grupoEstado', true);
    mostrarCampo('grupoCalle', false);
    mostrarCampo('grupoCiudad', false);
    mostrarCampo('grupoSala', false);
  }

  if (!tipo) {
    cargarEstadosGenerales();
  }
}

actividadForm.addEventListener('submit', async (event) => {
  event.preventDefault();

  const tipoActividad = document.getElementById('tipo_actividad').value;

let asunto = document.getElementById('asunto').value;
let estado = document.getElementById('estado').value;
let horaFinal = document.getElementById('hora_final').value || null;
let calle = document.getElementById('calle').value || null;
let ciudad = document.getElementById('ciudad').value || null;
let sala = document.getElementById('sala').value || null;

if (tipoActividad === 'NOTA') {
  asunto = 'Nota comercial';
  estado = 'CERRADO';
  horaFinal = null;
  calle = null;
  ciudad = null;
  sala = null;
}

if (tipoActividad !== 'REUNION') {
  calle = null;
  ciudad = null;
  sala = null;
}

const actividad = {
  cliente_id: Number(document.getElementById('cliente_id').value),
  contacto_id: document.getElementById('contacto_id').value || null,
  oportunidad_id: document.getElementById('oportunidad_id').value || null,
  responsable_id: Number(document.getElementById('responsable_id').value),
  tipo_actividad: tipoActividad,
  asunto,
  fecha: document.getElementById('fecha').value,
  hora_inicio: document.getElementById('hora_inicio').value || null,
  hora_final: horaFinal,
  prioridad: document.getElementById('prioridad').value,
  comentario: document.getElementById('comentario').value || null,
  estado,
  calle,
  ciudad,
  sala
};

  try {
    const response = await fetch(API_ACTIVIDADES, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(actividad)
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al crear actividad');
    }

    mostrarMensaje('Actividad creada correctamente', 'success');
    actividadForm.reset();
    cargarActividades();
  } catch (error) {
    mostrarMensaje(error.message, 'error');
  }
});

async function iniciarPagina() {
  try {
    await cargarClientes();
    await cargarContactos();
    await cargarResponsables();
    await cargarOportunidadesSelect();
    await cargarActividades();
    configurarCamposPorTipo();
  } catch (error) {
    mostrarMensaje('Error al cargar datos iniciales', 'error');
  }
}

iniciarPagina();