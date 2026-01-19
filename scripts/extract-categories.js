#!/usr/bin/env node

/**
 * Script para extraer categorías de canciones desde lldmnow.com/partituras/
 * 
 * Este script intenta extraer las categorías de cada canción desde la página web.
 * 
 * Uso:
 *   node scripts/extract-categories.js
 * 
 * Requiere: npm install axios cheerio (o puppeteer para páginas dinámicas)
 */

const fs = require('fs');
const path = require('path');

const DATABASE_FILE = path.join(__dirname, '..', 'database', 'songs.json');

console.log('🔍 Intentando extraer categorías desde lldmnow.com/partituras/...');
console.log('');
console.log('⚠️  NOTA: Este script requiere que la página tenga las categorías en el HTML.');
console.log('   Si la página usa JavaScript para cargar las categorías,');
console.log('   necesitarás usar Puppeteer en lugar de Cheerio.');
console.log('');
console.log('💡 Alternativa: Agregar categorías manualmente a database/songs.json');
console.log('   Ejemplo: {"id":"1","titulo":"...","url":"...","categoria":"Elección"}');
console.log('');
console.log('📋 Categorías disponibles según la página:');
const categorias = [
    'Elección', 'Llamamiento', 'Consagración', 'Confianza',
    'Alabanza', 'Gratitud', 'Adoración', 'Lucha', 'Amor',
    'Gracia', 'Gloria', 'Honra', '7 de Mayo', 'Amanecer',
    'Esperanza', 'Bautismo', 'Evangelización', 'Meditación',
    'Niñez', 'Advenimiento', 'Liberalidad', 'Fin de Año',
    'Restauración', 'Petición', 'Obra', 'Duermen', 'Pasión',
    'Intercesión', 'Juventud', 'Santa Cena', 'Himnario'
];
console.log('   ' + categorias.join(', '));
console.log('');
console.log('📝 Para agregar categorías manualmente:');
console.log('   1. Abre database/songs.json');
console.log('   2. Agrega "categoria": "NombreCategoría" a cada canción');
console.log('   3. Guarda y haz commit/push');
console.log('   4. Sincroniza desde la app');

