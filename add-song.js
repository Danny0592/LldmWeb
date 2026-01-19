#!/usr/bin/env node

/**
 * Script para agregar una nueva canción al database/songs.json
 * 
 * Uso:
 *   node add-song.js "Título de la Canción" "nombre_del_archivo.pdf"
 * 
 * Ejemplo:
 *   node add-song.js "Cantaré Al Señor" "Cantaré_Al_Senor.pdf"
 */

const fs = require('fs');
const path = require('path');

const DATABASE_FILE = path.join(__dirname, 'database', 'songs.json');

// Obtener argumentos de la línea de comandos
const args = process.argv.slice(2);

if (args.length < 2) {
    console.error('❌ Error: Faltan argumentos');
    console.log('\n📖 Uso:');
    console.log('   node add-song.js "Título de la Canción" "nombre_del_archivo.pdf"');
    console.log('\n📋 Ejemplo:');
    console.log('   node add-song.js "Cantaré Al Señor" "Cantaré_Al_Senor.pdf"');
    process.exit(1);
}

const titulo = args[0];
const nombreArchivo = args[1];

// Validar que el nombre del archivo termine en .pdf
const nombreArchivoLimpio = nombreArchivo.endsWith('.pdf') 
    ? nombreArchivo 
    : nombreArchivo + '.pdf';

// Construir la URL (siempre empieza con /)
const url = nombreArchivoLimpio.startsWith('/') 
    ? nombreArchivoLimpio 
    : '/' + nombreArchivoLimpio;

try {
    // Leer el archivo JSON actual
    const data = fs.readFileSync(DATABASE_FILE, 'utf8');
    const canciones = JSON.parse(data);

    // Encontrar el siguiente ID (el último + 1)
    const ultimoId = canciones.length > 0 
        ? Math.max(...canciones.map(c => parseInt(c.id))) 
        : 0;
    const nuevoId = (ultimoId + 1).toString();

    // Crear la nueva canción
    const nuevaCancion = {
        id: nuevoId,
        titulo: titulo.trim(),
        url: url
    };

    // Agregar la nueva canción al array
    canciones.push(nuevaCancion);

    // Guardar el archivo actualizado
    fs.writeFileSync(DATABASE_FILE, JSON.stringify(canciones, null, 2) + '\n', 'utf8');

    console.log('✅ Canción agregada exitosamente!');
    console.log('\n📋 Detalles:');
    console.log(`   ID: ${nuevoId}`);
    console.log(`   Título: ${titulo}`);
    console.log(`   URL: ${url}`);
    console.log(`   Total de canciones: ${canciones.length}`);
    console.log('\n📝 Próximos pasos:');
    console.log('   1. Asegúrate de tener el PDF en Server/public/');
    console.log('   2. Haz commit y push a Git:');
    console.log(`      git add database/songs.json public/${nombreArchivoLimpio}`);
    console.log(`      git commit -m "Agregar canción: ${titulo}"`);
    console.log('      git push');
    console.log('   3. Espera 1-2 minutos para que Render se actualice');
    console.log('   4. Sincroniza desde la app');
    console.log('\n✅ ¡Listo!');

} catch (error) {
    console.error('❌ Error al agregar la canción:', error.message);
    process.exit(1);
}

