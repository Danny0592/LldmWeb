# 📝 Cómo Agregar una Nueva Canción

## 📋 Pasos para Agregar una Canción

### Paso 1: Preparar el Archivo PDF

1. **Asegúrate de tener el PDF de la canción**
2. **Nombre el archivo PDF** con un formato consistente:
   - Usa guiones bajos o guiones para espacios: `Mi_Nueva_Cancion.pdf` o `Mi-Nueva-Cancion.pdf`
   - Ejemplo: `Cantaré_Al_Senor.pdf`

---

### Paso 2: Agregar la Canción al JSON

1. **Abre el archivo:** `Server/database/songs.json`

2. **Agrega una nueva entrada** antes del último `]`:

```json
  {
    "id": "616",
    "titulo": "Nombre de tu canción",
    "url": "/Nombre_del_archivo.pdf"
  }
```

**Ejemplo completo:**
```json
[
  // ... canciones existentes ...
  {
    "id": "615",
    "titulo": "Dile",
    "url": "/Dile.pdf"
  },
  {
    "id": "616",
    "titulo": "Cantaré Al Señor",
    "url": "/Cantaré_Al_Senor.pdf"
  }
]
```

**⚠️ IMPORTANTE:**
- El `id` debe ser el siguiente número secuencial (616, 617, etc.)
- El `titulo` es como se mostrará en la app (puede tener espacios, se convertirán automáticamente)
- El `url` debe coincidir exactamente con el nombre del archivo PDF

---

### Paso 3: Subir el PDF al Servidor (Render)

Tienes **2 opciones**:

#### Opción A: Subir a Render Manualmente (Recomendado)

1. **Ve a tu dashboard de Render:** https://dashboard.render.com
2. **Selecciona tu servicio** `lldmcantos-server`
3. **Ve a "Settings"** → Scroll down hasta "Public Directory"
4. **El directorio `public`** es donde debes subir los PDFs
5. **Opción:** Usa el **Render Shell** o conecta via **FTP/SFTP** para subir el archivo

**Nota:** Render no tiene una interfaz directa para subir archivos. Necesitarás:
- Usar Git y hacer commit/push del PDF
- O usar un servicio externo y cambiar la URL en el JSON

#### Opción B: Subir el PDF usando Git (Más fácil)

1. **Crea la carpeta `public`** si no existe: `Server/public/`
2. **Copia el PDF** a `Server/public/Nombre_del_archivo.pdf`
3. **Haz commit y push** a tu repositorio de Git:

```bash
cd Server
git add public/Nombre_del_archivo.pdf
git add database/songs.json
git commit -m "Agregar nueva canción: Nombre de la canción"
git push
```

4. **Render se actualizará automáticamente** si está conectado a Git

---

### Paso 4: Actualizar desde la App

Después de subir el PDF y actualizar el JSON:

1. **Abre la app en tu iPhone/iPad**
2. **Presiona el botón de sincronización** (flecha circular) en la parte superior derecha
3. **Espera a que sincronice** (puede tardar unos segundos)
4. **¡Listo!** La nueva canción aparecerá en la lista

---

## 📝 Ejemplo Completo

Supongamos que quieres agregar la canción **"Cantaré Al Señor"**:

### 1. Archivo PDF:
- Nombre: `Cantaré_Al_Senor.pdf`
- Ubicación: `Server/public/Cantaré_Al_Senor.pdf`

### 2. Entrada en `songs.json`:
```json
{
  "id": "616",
  "titulo": "Cantaré Al Señor",
  "url": "/Cantaré_Al_Senor.pdf"
}
```

### 3. Subir a Render:
```bash
cd Server
git add public/Cantaré_Al_Senor.pdf database/songs.json
git commit -m "Agregar canción: Cantaré Al Señor"
git push
```

### 4. Sincronizar en la app:
- Presionar botón de sincronización
- ¡Listo! ✅

---

## 🔍 Verificar que Funciona

1. **Verifica que el servidor responda:**
   ```bash
   curl https://lldmcantos-server.onrender.com/canciones | grep -i "cantaré"
   ```

2. **O abre en el navegador:**
   ```
   https://lldmcantos-server.onrender.com/canciones
   ```
   Busca tu canción en el JSON

3. **En la app:**
   - Sincroniza
   - Busca la canción por nombre
   - Ábrela para ver el PDF

---

## ⚠️ Notas Importantes

- **ID único:** Cada canción debe tener un ID único y secuencial
- **Nombre del PDF:** El nombre en `url` debe coincidir exactamente con el archivo
- **Formato del título:** El título puede tener espacios, se mostrarán correctamente
- **Cache:** Render puede tener cache, espera 1-2 minutos después de hacer push
- **Tamaño del PDF:** Archivos muy grandes (>10MB) pueden tardar más en cargar

---

## 🚀 Proceso Rápido (Resumen)

1. 📄 Agregar entrada a `songs.json` (id, titulo, url)
2. 📁 Subir PDF a `Server/public/`
3. 🔄 Commit y push a Git (Render se actualiza automáticamente)
4. 📱 Sincronizar desde la app
5. ✅ ¡Listo!

