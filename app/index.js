// app/index.js
require('dotenv').config();
const path = require('path');
const express = require('express');
const db = require('./db');

const app = express();
const port = 3000;

app.use(express.json());

// UI mínima
app.use(express.static(path.join(__dirname, 'public')));

// Swagger (ya lo tenías)
// Swagger (arreglado: busca anotaciones en este archivo y en otros .js del folder)
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const openapi = swaggerJsdoc({
  definition: {
    openapi: '3.0.0',
    info: { title: 'User Service', version: '1.0.0' },
  },
  apis: [
    path.join(__dirname, '*.js'),           // p.ej. index.js, db.js (ignora si no tiene anotaciones)
    path.join(__dirname, 'routes/**/*.js'), // por si luego separas rutas
  ],
});

// Ruta opcional para depurar el JSON de OpenAPI
app.get('/openapi.json', (_req, res) => res.json(openapi));

app.use('/docs', swaggerUi.serve, swaggerUi.setup(openapi, { explorer: true }));

/** Espera a la DB para evitar ECONNREFUSED */
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
async function waitForDb(retries = 30, delayMs = 1000) {
  for (let i = 1; i <= retries; i++) {
    try {
      await db.query('SELECT 1;');
      console.log('DB lista ✅');
      return;
    } catch (e) {
      console.log(`DB no lista, reintento ${i}/${retries}…`);
      await sleep(delayMs);
    }
  }
  throw new Error('DB no estuvo lista a tiempo');
}

// Bootstrap: crea tabla si no existe
async function bootstrap() {
  await db.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
  `);
}

/** Healthchecks */
app.get('/health', (_req, res) => res.json({ ok: true }));
app.get('/health/db', async (_req, res) => {
  try { await db.query('SELECT 1'); res.json({ db: 'up' }); }
  catch { res.status(500).json({ db: 'down' }); }
});

/** Rutas */
app.get('/', (_req, res) => {
  res.send('¡Bienvenido al Microservicio de Gestión de Usuarios! Visita / (UI) o /docs (API).');
});

app.get('/users', async (_req, res) => {
  try {
    const r = await db.query('SELECT id, name, email, created_at FROM users ORDER BY id');
    res.json(r.rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

app.post('/users', async (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: 'Nombre y email son requeridos' });
  try {
    const r = await db.query(
      'INSERT INTO users(name, email) VALUES($1, $2) RETURNING *',
      [name, email]
    );
    res.status(201).json(r.rows[0]);
  } catch (e) {
    // Manejo de email duplicado (Postgres: 23505)
    if (e && e.code === '23505') return res.status(409).json({ error: 'Email ya existe' });
    console.error(e);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

app.get('/users/:id', async (req, res) => {
  try {
    const r = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
    if (r.rows.length === 0) return res.status(404).json({ message: 'Usuario no encontrado.' });
    res.json(r.rows[0]);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

app.put('/users/:id', async (req, res) => {
  const fields = [], values = [];
  if (req.body.name)  { fields.push('name');  values.push(req.body.name); }
  if (req.body.email) { fields.push('email'); values.push(req.body.email); }
  if (fields.length === 0) return res.status(400).json({ error: 'Nada que actualizar' });

  const sets = fields.map((f, i) => `${f} = $${i + 1}`).join(', ');
  values.push(req.params.id);
  try {
    const r = await db.query(`UPDATE users SET ${sets} WHERE id = $${values.length} RETURNING *`, values);
    if (r.rows.length === 0) return res.status(404).json({ message: 'Usuario no encontrado.' });
    res.json(r.rows[0]);
  } catch (e) {
    if (e && e.code === '23505') return res.status(409).json({ error: 'Email ya existe' });
    console.error(e);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

app.delete('/users/:id', async (req, res) => {
  try {
    const r = await db.query('DELETE FROM users WHERE id = $1 RETURNING id', [req.params.id]);
    if (r.rowCount === 0) return res.status(404).json({ message: 'Usuario no encontrado.' });
    res.json({ deleted: r.rows[0].id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Arranque: espera DB -> migra -> escucha
(async () => {
  try {
    await waitForDb();
    await bootstrap();
    app.listen(port, '0.0.0.0', () => console.log(`Servidor corriendo en el puerto ${port}`));
  } catch (err) {
    console.error('Fallo en arranque:', err);
    process.exit(1);
  }
})();

