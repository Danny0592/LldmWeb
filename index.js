const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const app = express();

// Puerto desde variable de entorno o 3000 por defecto
const PORT = process.env.PORT || 3000;

// URL base del servidor (configurar BASE_URL en Render después del deployment)
const BASE_URL = process.env.BASE_URL || `http://localhost:${PORT}`;

// Ruta a la base de datos local
const DATABASE_FILE = path.join(__dirname, 'database', 'songs.json');

// Cache para almacenar las partituras (se actualiza cada vez que se solicita)
let cachedPartituras = null;
let lastFetchTime = null;
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutos

// Habilitar CORS para permitir acceso desde cualquier origen
app.use(cors({
    origin: '*', // En producción, puedes especificar dominios específicos
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware para parsear JSON
app.use(express.json());

// Servir archivos estáticos desde 'public'
app.use(express.static('public'));

// Endpoint de salud/status
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        baseUrl: BASE_URL
    });
});

// Función para cargar canciones desde la base de datos local
function loadSongsFromLocalDatabase() {
    try {
        if (fs.existsSync(DATABASE_FILE)) {
            const data = fs.readFileSync(DATABASE_FILE, 'utf8');
            const songs = JSON.parse(data);
            
            // Convertir URLs relativas a absolutas usando BASE_URL
            return songs.map(song => ({
                id: song.id,
                titulo: song.titulo,
                url: song.url.startsWith('http') ? song.url : `${BASE_URL}${song.url}`
            }));
        }
    } catch (error) {
        console.error('❌ Error al leer base de datos local:', error.message);
    }
    return null;
}

// Endpoint para obtener la lista de canciones
app.get('/canciones', (req, res) => {
    try {
        // Usar cache si está disponible y no ha expirado
        const now = Date.now();
        if (cachedPartituras && lastFetchTime && (now - lastFetchTime) < CACHE_DURATION) {
            console.log('📦 Usando cache de partituras');
            return res.json(cachedPartituras);
        }
        
        // Cargar desde la base de datos local
        console.log('📂 Cargando canciones desde base de datos local...');
        let listaCanciones = loadSongsFromLocalDatabase();
        
        if (listaCanciones && listaCanciones.length > 0) {
            console.log(`✅ Se encontraron ${listaCanciones.length} canciones en base de datos local`);
            
            // Actualizar cache
            cachedPartituras = listaCanciones;
            lastFetchTime = now;
            
            return res.json(listaCanciones);
        }
        
        // Fallback: Leer archivos PDFs directamente de la carpeta public
        console.log('📁 Intentando leer PDFs de la carpeta public...');
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
                        url: `${BASE_URL}/${archivo}`
                    };
                });
                
                console.log(`✅ Se encontraron ${listaCanciones.length} PDFs en la carpeta public`);
                
                // Actualizar cache
                cachedPartituras = listaCanciones;
                lastFetchTime = now;
                
                return res.json(listaCanciones);
            }
        }
        
        // Si llegamos aquí, no hay canciones disponibles
        return res.status(404).json({ 
            mensaje: "No se encontraron canciones. Asegúrate de tener una base de datos local o archivos PDF en la carpeta public."
        });
        
    } catch (error) {
        console.error('❌ Error al obtener canciones:', error);
        return res.status(500).json({ 
            mensaje: "Error al leer los archivos",
            error: error.message
        });
    }
});

// Manejo de errores
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ 
        error: 'Error interno del servidor',
        message: err.message 
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🎵 Servidor de Cantos corriendo en puerto ${PORT}`);
    console.log(`📄 Lista de canciones disponible en: ${BASE_URL}/canciones`);
    console.log(`🔗 Accesible desde cualquier dispositivo`);
    console.log(`🌐 BASE_URL: ${BASE_URL}`);
    
    // Verificar si existe la base de datos local
    if (fs.existsSync(DATABASE_FILE)) {
        try {
            const songs = JSON.parse(fs.readFileSync(DATABASE_FILE, 'utf8'));
            console.log(`✅ Base de datos local encontrada con ${songs.length} canciones`);
        } catch (e) {
            console.log(`⚠️  Base de datos local existe pero está vacía o corrupta`);
        }
    }
});
