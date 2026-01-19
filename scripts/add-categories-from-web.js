#!/usr/bin/env node

/**
 * Script para extraer categorías desde lldmnow.com/partituras/
 * y agregarlas a database/songs.json
 * 
 * Uso:
 *   node scripts/add-categories-from-web.js
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const DATABASE_FILE = path.join(__dirname, '..', 'database', 'songs.json');
const WEB_URL = 'https://lldmnow.com/partituras/';

console.log('🔍 Extrayendo categorías desde lldmnow.com/partituras/...');
console.log('');

https.get(WEB_URL, (res) => {
    let data = '';
    
    res.on('data', (chunk) => {
        data += chunk;
    });
    
    res.on('end', () => {
        try {
            // Buscar el array todasLasPartituras en el HTML
            const match = data.match(/todasLasPartituras\s*=\s*\[(.*?)\];/s);
            
            if (!match) {
                console.error('❌ No se encontró el array todasLasPartituras en la página');
                console.log('💡 Intenta verificar la URL o la estructura de la página');
                process.exit(1);
            }
            
            // Extraer el contenido del array
            let arrayContent = match[1].trim();
            
            // Usar eval de forma segura para convertir el array JavaScript a objeto
            // En un entorno controlado, esto es aceptable para parsear JavaScript
            let webSongs;
            try {
                // Reemplazar el código JavaScript por código que devuelva el array
                const code = 'const todasLasPartituras = [' + arrayContent + ']; return todasLasPartituras;';
                const func = new Function(code);
                webSongs = func();
            } catch (error) {
                // Si falla, intentar parsear manualmente
                console.log('⚠️  Intentando método alternativo...');
                // Limpiar el contenido y convertir a JSON
                arrayContent = arrayContent.replace(/'/g, '"'); // Reemplazar comillas simples
                arrayContent = arrayContent.replace(/(\w+):/g, '"$1":'); // Agregar comillas a las claves
                const jsonString = '[' + arrayContent + ']';
                webSongs = JSON.parse(jsonString);
            }
            
            console.log(`✅ Se encontraron ${webSongs.length} canciones en la página web`);
            console.log('');
            
            // Cargar songs.json actual
            const currentSongs = JSON.parse(fs.readFileSync(DATABASE_FILE, 'utf8'));
            console.log(`📋 Canciones en database/songs.json: ${currentSongs.length}`);
            console.log('');
            
            // Crear un mapa de canciones web por título normalizado
            const webSongsMap = new Map();
            webSongs.forEach(song => {
                const tituloNormalizado = song.titulo
                    .trim()
                    .toLowerCase()
                    .replace(/[_-]/g, ' ')
                    .replace(/\s+/g, ' ');
                webSongsMap.set(tituloNormalizado, song.tema || song.categoria || null);
            });
            
            console.log(`📊 Canciones con tema en la web: ${Array.from(webSongsMap.values()).filter(v => v).length}`);
            console.log('');
            
            // Normalizar título helper
            function normalizeTitle(title) {
                return title
                    .trim()
                    .toLowerCase()
                    .replace(/[_-]/g, ' ')
                    .replace(/\s+/g, ' ');
            }
            
            // Agregar categorías a las canciones locales
            let updatedCount = 0;
            let alreadyHadCategory = 0;
            
            currentSongs.forEach(song => {
                const tituloNormalizado = normalizeTitle(song.titulo);
                const categoria = webSongsMap.get(tituloNormalizado);
                
                if (categoria) {
                    if (!song.categoria) {
                        song.categoria = categoria;
                        updatedCount++;
                    } else {
                        alreadyHadCategory++;
                    }
                }
            });
            
            // Guardar el archivo actualizado
            fs.writeFileSync(DATABASE_FILE, JSON.stringify(currentSongs, null, 2) + '\n', 'utf8');
            
            console.log('✅ Proceso completado!');
            console.log('');
            console.log('📊 Resumen:');
            console.log(`   ✅ Categorías agregadas: ${updatedCount}`);
            console.log(`   ⏭️  Ya tenían categoría: ${alreadyHadCategory}`);
            console.log(`   📋 Total canciones: ${currentSongs.length}`);
            console.log('');
            console.log('📝 Próximos pasos:');
            console.log('   1. Revisa database/songs.json para verificar las categorías');
            console.log('   2. Haz commit y push:');
            console.log('      git add database/songs.json');
            console.log('      git commit -m "Agregar categorías a canciones"');
            console.log('      git push');
            console.log('   3. Espera 1-2 minutos para que Render se actualice');
            console.log('   4. Sincroniza desde la app');
            console.log('');
            console.log('✅ ¡Listo!');
            
        } catch (error) {
            console.error('❌ Error al procesar:', error.message);
            console.log('');
            console.log('💡 El formato del array en la página puede haber cambiado.');
            console.log('   Puedes agregar categorías manualmente a database/songs.json');
            process.exit(1);
        }
    });
    
}).on('error', (err) => {
    console.error('❌ Error al conectar con la página:', err.message);
    console.log('');
    console.log('💡 Verifica tu conexión a internet o intenta más tarde');
    process.exit(1);
});

