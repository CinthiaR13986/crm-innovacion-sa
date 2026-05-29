const API_URL = 'http://localhost:3000/api/clientes';

const clienteForm = document.getElementById('clienteForm');
const tablaClientes = document.getElementById('tablaClientes');
const mensaje = document.getElementById('mensaje');

const clienteIdInput = document.getElementById('cliente_id');
const tituloFormulario = document.getElementById('tituloFormulario');
const btnGuardar = document.getElementById('btnGuardar');
const btnCancelar = document.getElementById('btnCancelar');

let clientesActuales = [];

function mostrarMensaje(texto, tipo) {
  mensaje.textContent = texto;
  mensaje.className = `alert ${tipo}`;
  mensaje.style.display = 'block';

  setTimeout(() => {
    mensaje.style.display = 'none';
  }, 3000);
}

function limpiarFormulario() {
  clienteIdInput.value = '';
  clienteForm.reset();

  tituloFormulario.textContent = 'Crear cliente';
  btnGuardar.textContent = 'Guardar cliente';
  btnCancelar.style.display = 'none';
}

function cancelarEdicion() {
  limpiarFormulario();
}

async function cargarClientes() {
  try {
    const response = await fetch(API_URL);
    const clientes = await response.json();

    clientesActuales = clientes;
    tablaClientes.innerHTML = '';

    clientes.forEach(cliente => {
      tablaClientes.innerHTML += `
        <tr>
          <td>${cliente.cliente_id}</td>
          <td>${cliente.nombre_comercial}</td>
          <td>${cliente.direccion}</td>
          <td>${cliente.telefono ?? ''}</td>
          <td>${cliente.celular ?? ''}</td>
          <td>${cliente.correo ?? ''}</td>
          <td>${cliente.division_cliente}</td>
          <td>
            <button onclick="cargarClienteParaEditar(${cliente.cliente_id})">Editar</button>
            <button class="btn-lost" onclick="eliminarCliente(${cliente.cliente_id})">Eliminar</button>
          </td>
        </tr>
      `;
    });
  } catch (error) {
    mostrarMensaje('Error al cargar clientes', 'error');
  }
}

function cargarClienteParaEditar(clienteId) {
  const cliente = clientesActuales.find(c => c.cliente_id === clienteId);

  if (!cliente) {
    mostrarMensaje('Cliente no encontrado en la tabla actual', 'error');
    return;
  }

  clienteIdInput.value = cliente.cliente_id;
  document.getElementById('nombre_comercial').value = cliente.nombre_comercial;
  document.getElementById('direccion').value = cliente.direccion;
  document.getElementById('telefono').value = cliente.telefono ?? '';
  document.getElementById('celular').value = cliente.celular ?? '';
  document.getElementById('correo').value = cliente.correo ?? '';
  document.getElementById('division_cliente').value = cliente.division_cliente;

  tituloFormulario.textContent = 'Editar cliente';
  btnGuardar.textContent = 'Actualizar cliente';
  btnCancelar.style.display = 'inline-block';

  window.scrollTo({
    top: 0,
    behavior: 'smooth'
  });
}

async function eliminarCliente(clienteId) {
  const confirmar = confirm('¿Está seguro de eliminar este cliente? Se realizará una eliminación lógica.');

  if (!confirmar) {
    return;
  }

  try {
    const response = await fetch(`${API_URL}/${clienteId}`, {
      method: 'DELETE'
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al eliminar cliente');
    }

    mostrarMensaje('Cliente eliminado correctamente', 'success');
    cargarClientes();
  } catch (error) {
    mostrarMensaje(error.message, 'error');
  }
}

clienteForm.addEventListener('submit', async (event) => {
  event.preventDefault();

  const clienteId = clienteIdInput.value;

  const cliente = {
    nombre_comercial: document.getElementById('nombre_comercial').value,
    direccion: document.getElementById('direccion').value,
    telefono: document.getElementById('telefono').value,
    celular: document.getElementById('celular').value,
    correo: document.getElementById('correo').value,
    division_cliente: document.getElementById('division_cliente').value
  };

  try {
    let response;

    if (clienteId) {
      response = await fetch(`${API_URL}/${clienteId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(cliente)
      });
    } else {
      response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(cliente)
      });
    }

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Error al guardar cliente');
    }

    mostrarMensaje(
      clienteId ? 'Cliente actualizado correctamente' : 'Cliente creado correctamente',
      'success'
    );

    limpiarFormulario();
    cargarClientes();
  } catch (error) {
    mostrarMensaje(error.message, 'error');
  }
});

cargarClientes();