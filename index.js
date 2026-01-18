const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const app = express();

const PORT = process.env.PORT || 3000;
const BASE_URL = process.env.BASE_URL || `http://localhost:${PORT}`;
const DATABASE_FILE = path.join(__dirname, 'database', 'songs.json');

let cachedPartituras = null;
let lastFetchTime = null;
let lastFileModTime = null;
const CACHE_DURATION = 1 * 60 * 1000; // 1 minuto (reducido para actualizaciones más rápidas)

app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());
app.use(express.static('public'));

app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        baseUrl: BASE_URL
    });
});

function loadSongsFromLocalDatabase() {
    try {
        if (fs.existsSync(DATABASE_FILE)) {
            const data = fs.readFileSync(DATABASE_FILE, 'utf8');
            const songs = JSON.parse(data);
            
            return songs.map(song => ({
                id: song.id,
                titulo: song.titulo,
                url: song.url.startsWith('http') ? song.url : `${BASE_URL}${song.url}`,
                categoria: song.categoria || null  // Incluir categoría si existe
            }));
        }
    } catch (error) {
        console.error('❌ Error al leer base de datos local:', error.message);
    }
    return null;
}

app.get('/canciones', (req, res) => {
    try {
        const now = Date.now();
        
        // Verificar si el archivo cambió
        let fileModTime = null;
        if (fs.existsSync(DATABASE_FILE)) {
            fileModTime = fs.statSync(DATABASE_FILE).mtime.getTime();
        }
        
        // Si el archivo cambió, limpiar cache
        if (fileModTime && lastFileModTime && fileModTime > lastFileModTime) {
            cachedPartituras = null;
            lastFetchTime = null;
        }
        
        // Si hay cache válido y el archivo no cambió, usarlo
        if (cachedPartituras && lastFetchTime && (now - lastFetchTime) < CACHE_DURATION) {
            return res.json(cachedPartituras);
        }
        
        let listaCanciones = loadSongsFromLocalDatabase();
        
        if (listaCanciones && listaCanciones.length > 0) {
            cachedPartituras = listaCanciones;
            lastFetchTime = now;
            lastFileModTime = fileModTime;
            return res.json(listaCanciones);
        }
        
        const carpetaPdfs = path.join(__dirname, 'public');
        if (fs.existsSync(carpetaPdfs)) {
            const archivos = fs.readdirSync(carpetaPdfs);
            const pdfs = archivos.filter(archivo => archivo.toLowerCase().endsWith('.pdf'));
            
            if (pdfs.length > 0) {
                listaCanciones = pdfs.map(archivo => {
                    const tituloLimpio = archivo
                        .replace(/\.pdf$/i, '')
                        .replace(/[_-]/g, ' ');
                    
                    return {
                        id: archivo,
                        titulo: tituloLimpio,
                        url: `${BASE_URL}/${archivo}`,
                        categoria: null  // Sin categoría si se genera desde archivos PDF
                    };
                });
                
                cachedPartituras = listaCanciones;
                lastFetchTime = now;
                return res.json(listaCanciones);
            }
        }
        
        return res.status(404).json({ 
            mensaje: "No se encontraron canciones."
        });
        
    } catch (error) {
        console.error('❌ Error al obtener canciones:', error);
        return res.status(500).json({ 
            mensaje: "Error al leer los archivos",
            error: error.message
        });
    }
});

app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ 
        error: 'Error interno del servidor',
        message: err.message 
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
    console.log(`BASE_URL: ${BASE_URL}`);
    
    if (fs.existsSync(DATABASE_FILE)) {
        try {
            const songs = JSON.parse(fs.readFileSync(DATABASE_FILE, 'utf8'));
            console.log(`Base de datos: ${songs.length} canciones`);
        } catch (e) {
            console.log(`Error al leer base de datos`);
        }
    }
});
