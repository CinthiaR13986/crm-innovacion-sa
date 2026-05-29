const sql = require('mssql');
require('dotenv').config();

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  port: Number(process.env.DB_PORT || 1433),
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

let pool;

async function getConnection() {
  try {
    if (pool) {
      return pool;
    }

    pool = await sql.connect(dbConfig);
    console.log('Conexión exitosa a SQL Server');
    return pool;
  } catch (error) {
    console.error('Error conectando a SQL Server:', error.message);
    throw error;
  }
}

module.exports = {
  sql,
  getConnection
};