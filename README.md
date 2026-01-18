# 🎵 Servidor LldmCantos

Servidor API simple para la app LldmCantos que sirve la lista de canciones y los archivos PDF.

---

## 📁 Estructura del Proyecto

```
Server/
├── index.js                # Servidor principal
├── package.json            # Dependencias
├── database/
│   └── songs.json         # Base de datos de canciones (615 canciones)
├── public/
│   └── *.pdf              # PDFs de las canciones (617 archivos)
└── render.yaml            # Configuración para Render
```

---

## 🚀 Inicio Rápido

### Desarrollo Local

```bash
# Instalar dependencias
npm install

# Iniciar servidor
npm start
```

El servidor estará disponible en: `http://localhost:3000`

---

## 📡 Endpoints

### `GET /health`

Verifica el estado del servidor.

**Respuesta:**
```json
{
  "status": "ok",
  "timestamp": "2025-01-17T...",
  "baseUrl": "http://localhost:3000"
}
```

### `GET /canciones`

Obtiene la lista de todas las canciones disponibles.

**Respuesta:**
```json
[
  {
    "id": "1",
    "titulo": "A donde ire",
    "url": "http://localhost:3000/A_donde_ire.pdf"
  },
  ...
]
```

### `GET /archivo.pdf`

Sirve los archivos PDF desde la carpeta `public/`.

Ejemplo: `GET /A_donde_ire.pdf` → Descarga el PDF

---

## ☁️ Deployment en Render

### Paso 1: Crear Cuenta

1. Ve a [render.com](https://render.com)
2. Crea una cuenta (puedes usar GitHub para registro rápido)
3. Click en "New +" → "Web Service"

### Paso 2: Conectar Repositorio

**Opción A - Con GitHub (Recomendado):**
1. Sube esta carpeta `Server` a un repositorio de GitHub
2. En Render, conecta tu repositorio de GitHub
3. Selecciona el repositorio y la carpeta `Server`

**Opción B - Manual:**
1. Usa "Deploy without Git"
2. Sube los archivos manualmente

### Paso 3: Configurar Servicio

- **Name:** `lldmcantos-server`
- **Environment:** `Node`
- **Build Command:** `npm install`
- **Start Command:** `npm start`
- **Plan:** `Free` (o `Starter` si quieres mejor rendimiento)

### Paso 4: Variables de Entorno

Después de crear el servicio, ve a "Environment" y agrega:

- `NODE_ENV` = `production`
- `BASE_URL` = (déjalo vacío primero, lo configuramos después)

### Paso 5: Desplegar

1. Click en "Create Web Service"
2. Espera a que termine el deployment (5-10 minutos)
3. Render te dará una URL como: `https://lldmcantos-server-xxxx.onrender.com`

### Paso 6: Configurar BASE_URL

1. Ve a "Environment" en Render
2. Actualiza `BASE_URL` con la URL completa que te dio Render (incluyendo `https://`)
   - Ejemplo: `https://lldmcantos-server-xxxx.onrender.com`
3. Guarda y reinicia el servicio

### Paso 7: Actualizar la App iOS

1. Abre `LldmCantos/Services/PDFService.swift`
2. Cambia esta línea:
   ```swift
   private let baseURL = "http://192.168.100.57:3000"
   ```
   
   Por:
   ```swift
   private let baseURL = "https://lldmcantos-server-xxxx.onrender.com"
   ```
   (Usa la URL que te dio Render)

---

## ✅ Verificar que Funciona

1. **Verificar servidor:**
   ```bash
   curl https://tu-url.onrender.com/health
   ```

2. **Verificar canciones:**
   ```bash
   curl https://tu-url.onrender.com/canciones | head -20
   ```

3. **Verificar PDFs:**
   ```bash
   curl -I https://tu-url.onrender.com/A_donde_ire.pdf
   ```
   Deberías ver `HTTP/1.1 200 OK`

---

## 📊 Datos Actuales

- ✅ **615 canciones** en `database/songs.json`
- ✅ **617 PDFs** en `public/` (~111MB)
- ✅ Servidor listo para producción

---

## 🔧 Configuración

### Variables de Entorno

- `PORT`: Puerto del servidor (default: 3000)
- `BASE_URL`: URL base del servidor (para construir URLs de PDFs)
- `NODE_ENV`: Entorno (development/production)

---

## 📝 Notas

- **Render Free Plan:** El servidor "duerme" después de 15 minutos sin uso. La primera petición puede tardar ~30 segundos.
- **HTTPS:** Render proporciona HTTPS automáticamente.
- **CORS:** El servidor tiene CORS habilitado para permitir acceso desde cualquier origen.

---

## 🆘 Troubleshooting

### El servidor no responde en Render

- Verifica los logs en Render
- Asegúrate de que el servicio esté "Running"
- Verifica que `BASE_URL` esté configurado correctamente

### La app no puede conectar

- Verifica que uses HTTPS en la URL
- Revisa que la URL en `PDFService.swift` sea correcta
- Verifica que el servidor esté corriendo en Render

---

¡Listo para usar! 🎉
