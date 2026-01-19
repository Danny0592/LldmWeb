#!/usr/bin/env node

/**
 * Script para eliminar una canción del database/songs.json
 * 
 * Uso:
 *   node remove-song.js "ID" o "Título"
 * 
 * Ejemplos:
 *   node remove-song.js "616"
 *   node remove-song.js "Document"
 */

const fs = require('fs');
const path = require('path');

const DATABASE_FILE = path.join(__dirname, 'database', 'songs.json');

// Obtener argumentos de la línea de comandos
const args = process.argv.slice(2);

if (args.length < 1) {
    console.error('❌ Error: Falta el argumento');
    console.log('\n📖 Uso:');
    console.log('   node remove-song.js "ID" o "Título"');
    console.log('\n📋 Ejemplos:');
    console.log('   node remove-song.js "616"');
    console.log('   node remove-song.js "Document"');
    process.exit(1);
}

const searchTerm = args[0];

try {
    // Leer el archivo JSON actual
    const data = fs.readFileSync(DATABASE_FILE, 'utf8');
    const canciones = JSON.parse(data);
    
    const totalAntes = canciones.length;
    
    // Buscar la canción por ID o título
    const indice = canciones.findIndex(c => 
        c.id === searchTerm || 
        c.titulo.toLowerCase().includes(searchTerm.toLowerCase())
    );
    
    if (indice === -1) {
        console.error(`❌ No se encontró la canción con ID o título: "${searchTerm}"`);
        console.log('\n💡 Canciones disponibles (últimas 5):');
        canciones.slice(-5).forEach(c => {
            console.log(`   ID: ${c.id} - Título: ${c.titulo}`);
        });
        process.exit(1);
    }
    
    const cancionEliminada = canciones[indice];
    
    // Eliminar la canción del array
    canciones.splice(indice, 1);
    
    // Reindexar los IDs (opcional, pero mejor dejarlos como están)
    // Si quieres mantener IDs consecutivos, descomenta esto:
    // canciones.forEach((c, index) => {
    //     c.id = (index + 1).toString();
    // });
    
    // Guardar el archivo actualizado
    fs.writeFileSync(DATABASE_FILE, JSON.stringify(canciones, null, 2) + '\n', 'utf8');
    
    console.log('✅ Canción eliminada exitosamente!');
    console.log('\n📋 Detalles:');
    console.log(`   ID eliminado: ${cancionEliminada.id}`);
    console.log(`   Título: ${cancionEliminada.titulo}`);
    console.log(`   URL: ${cancionEliminada.url}`);
    console.log(`   Total de canciones antes: ${totalAntes}`);
    console.log(`   Total de canciones ahora: ${canciones.length}`);
    console.log('\n📝 Próximos pasos:');
    console.log('   1. Opcional: Elimina el PDF de Server/public/ si ya no lo necesitas');
    console.log('   2. Haz commit y push a Git:');
    console.log(`      git add database/songs.json`);
    if (cancionEliminada.url && cancionEliminada.url.startsWith('/')) {
        const nombrePDF = cancionEliminada.url.substring(1);
        console.log(`      git rm public/${nombrePDF}  # Si quieres eliminar el PDF también`);
    }
    console.log(`      git commit -m "Eliminar canción: ${cancionEliminada.titulo}"`);
    console.log('      git push');
    console.log('   3. Espera 1-2 minutos para que Render se actualice');
    console.log('   4. Sincroniza desde la app');
    console.log('\n✅ ¡Listo!');

} catch (error) {
    console.error('❌ Error al eliminar la canción:', error.message);
    process.exit(1);
}

