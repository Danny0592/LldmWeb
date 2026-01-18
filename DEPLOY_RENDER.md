# 🚀 Subir a Render - Guía Paso a Paso

## 📋 Antes de Empezar

**Lo que necesitas:**
- ✅ Cuenta de GitHub (opcional, pero recomendado)
- ✅ Carpeta `Server/` completa con todos los archivos
- ✅ 5-10 minutos

---

## 🚀 Paso 1: Crear Cuenta en Render

1. **Ve a Render:**
   - [render.com](https://render.com)

2. **Crear cuenta:**
   - Click en **"Get Started for Free"** o **"Sign Up"**
   - Puedes usar **GitHub** para registro rápido (recomendado)
   - O crea cuenta con email

3. **Verificar email** (si usaste email)

---

## 📤 Paso 2: Preparar el Código para Subir

Tienes dos opciones:

### **Opción A: Con GitHub (Recomendado)** ⭐

1. **Crear repositorio en GitHub:**
   - Ve a [github.com](https://github.com)
   - Click **"New repository"**
   - Nombre: `lldmcantos-server` (o el que prefieras)
   - Público o privado (tu elección)
   - **NO** agregues README, .gitignore, ni licencia (ya los tienes)
   - Click **"Create repository"**

2. **Subir carpeta Server a GitHub:**
   
   Abre Terminal y ejecuta:
   
   ```bash
   cd /Users/danielortizmillan/Desktop/LldmCantos/Server
   
   # Inicializar Git (si no está inicializado)
   git init
   
   # Agregar todos los archivos
   git add .
   
   # Commit inicial
   git commit -m "Initial commit: Servidor LldmCantos con PDFs"
   
   # Agregar repositorio remoto (reemplaza TU_USUARIO y TU_REPO)
   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
   
   # Subir a GitHub
   git branch -M main
   git push -u origin main
   ```

   **⚠️ IMPORTANTE:** Reemplaza `TU_USUARIO` y `TU_REPO` con tu usuario de GitHub y el nombre del repositorio.

3. **Verificar que se subió:**
   - Ve a tu repositorio en GitHub
   - Deberías ver todos los archivos (index.js, package.json, database/, public/, etc.)

---

### **Opción B: Subir Manualmente (Sin GitHub)**

Si no quieres usar GitHub, puedes subir los archivos directamente en Render.

---

## 🌐 Paso 3: Crear Servicio en Render

1. **En Render Dashboard:**
   - Click en **"New +"** (arriba a la derecha)
   - Selecciona **"Web Service"**

2. **Conectar Repositorio (Opción A - Con GitHub):**
   - Si usaste GitHub:
     - Click **"Connect account"** o **"Connect GitHub"**
     - Autoriza Render a acceder a tus repositorios
     - Selecciona tu repositorio `lldmcantos-server`
     - Render detectará automáticamente que es Node.js

3. **Subir Manualmente (Opción B - Sin GitHub):**
   - Si no usaste GitHub:
     - Selecciona **"Deploy without Git"** o **"Manual Deploy"**
     - Render te dará instrucciones para subir archivos

---

## ⚙️ Paso 4: Configurar el Servicio

Una vez que Render detecte tu repositorio o subas los archivos:

### Configuración Básica:

- **Name:** `lldmcantos-server` (o el que prefieras)
- **Environment:** `Node` (debería detectarse automáticamente)
- **Region:** Elige la más cercana (ej: `Oregon (US West)`)
- **Branch:** `main` (o `master`, según tu repositorio)

### Configuración de Build:

- **Build Command:** `npm install`
- **Start Command:** `npm start`
- **Plan:** `Free` (o `Starter` si quieres mejor rendimiento)

### Variables de Entorno:

**⚠️ IMPORTANTE:** Configura estas variables DESPUÉS del primer deployment:

1. Ve a **"Environment"** (después de crear el servicio)
2. Agrega:
   - **Key:** `NODE_ENV`
     **Value:** `production`
   
   - **Key:** `BASE_URL`
     **Value:** (déjalo vacío por ahora, lo configuramos después)

---

## 📤 Paso 5: Desplegar

1. **Click en "Create Web Service"**

2. **Render iniciará el deployment:**
   - Verás logs en tiempo real
   - Tiempo estimado: **5-10 minutos**
   - Render instalará dependencias (`npm install`)
   - Render iniciará el servidor (`npm start`)

3. **Espera a que termine:**
   - Verás: **"Your service is live"** ✅
   - Render te dará una URL como: `https://lldmcantos-server-xxxx.onrender.com`

---

## 🔧 Paso 6: Configurar BASE_URL

Una vez que el servicio esté corriendo:

1. **Copia la URL** que te dio Render (ej: `https://lldmcantos-server-xxxx.onrender.com`)

2. **Ve a "Environment"** en tu servicio de Render:
   - En el menú lateral, click en **"Environment"**

3. **Actualiza BASE_URL:**
   - Busca la variable `BASE_URL` que creaste antes
   - Cambia el valor por la URL completa de Render (incluyendo `https://`)
   - Ejemplo: `https://lldmcantos-server-xxxx.onrender.com`
   - Click **"Save Changes"**

4. **Reiniciar el servicio:**
   - Render reiniciará automáticamente, o
   - Ve a **"Manual Deploy"** → **"Clear build cache & deploy"**

---

## ✅ Paso 7: Verificar que Funciona

### 1. Verificar Servidor:
```bash
curl https://tu-url.onrender.com/health
```

Deberías ver:
```json
{
  "status": "ok",
  "timestamp": "...",
  "baseUrl": "https://tu-url.onrender.com"
}
```

### 2. Verificar Canciones:
```bash
curl https://tu-url.onrender.com/canciones | head -50
```

Deberías ver JSON con las canciones.

### 3. Verificar PDF:
```bash
curl -I https://tu-url.onrender.com/A_donde_ire.pdf
```

Deberías ver: `HTTP/1.1 200 OK`

---

## 📱 Paso 8: Actualizar App iOS

1. **Abre `LldmCantos/Services/PDFService.swift`**

2. **Cambia la URL:**
   
   Busca esta línea (alrededor de la línea 19):
   ```swift
   private let baseURL = "http://192.168.100.57:3000"
   ```
   
   Cámbiala por tu URL de Render:
   ```swift
   private let baseURL = "https://lldmcantos-server-xxxx.onrender.com"
   ```
   
   (Reemplaza con la URL que te dio Render)

3. **Guarda el archivo**

4. **Prueba la app** en tu iPhone/iPad

---

## 🎉 ¡Listo!

Tu servidor está en Render y funciona desde cualquier lugar.

**URL del servidor:** `https://tu-url.onrender.com`

**Endpoints disponibles:**
- `GET /health` - Estado del servidor
- `GET /canciones` - Lista de canciones (JSON)
- `GET /archivo.pdf` - Descargar PDFs

---

## 📝 Notas Importantes

### Render Free Plan:
- ⚠️ El servidor **"duerme"** después de 15 minutos sin uso
- ⚠️ La **primera petición** puede tardar ~30 segundos (para despertar el servidor)
- ✅ Después de eso, funciona normal

### Si Quieres Evitar que el Servidor "Duerma":
- Considera el plan **Starter** ($7/mes)
- O usa un servicio de "ping" para mantenerlo activo

### Tamaño del Proyecto:
- ✅ 111MB de PDFs está bien para Render Free Plan
- ✅ Render permite hasta 100GB en el plan gratis

---

## 🆘 Troubleshooting

### Error: "Build failed"

**Solución:**
- Verifica que `package.json` esté correcto
- Revisa los logs en Render para ver el error específico
- Verifica que `index.js` esté en la raíz del repositorio

### Error: "Service failed to start"

**Solución:**
- Verifica que `package.json` tenga el script `"start": "node index.js"`
- Verifica que `index.js` no tenga errores de sintaxis
- Revisa los logs en Render

### El servidor responde muy lento

**Solución:**
- Normal en Render Free Plan (servidor "duerme")
- Primera petición tarda ~30 segundos
- Peticiones siguientes son rápidas

### La app no puede conectar

**Solución:**
- Verifica que uses **HTTPS** en la URL (no HTTP)
- Verifica que la URL en `PDFService.swift` sea correcta
- Verifica que `BASE_URL` esté configurado en Render

---

## 🎯 Resumen de Pasos

```
1. Crear cuenta en Render
   ↓
2. Subir código a GitHub (o manualmente)
   ↓
3. Crear Web Service en Render
   ↓
4. Configurar (Build: npm install, Start: npm start)
   ↓
5. Desplegar (esperar 5-10 minutos)
   ↓
6. Configurar BASE_URL con la URL de Render
   ↓
7. Verificar que funciona
   ↓
8. Actualizar URL en PDFService.swift
   ↓
✅ ¡Listo!
```

---

¿Necesitas ayuda con algún paso específico? 🚀

