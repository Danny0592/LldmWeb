# 🗑️ Cómo Eliminar una Canción

## 📋 Pasos para Eliminar una Canción

### Paso 1: Usar el Script (Recomendado) ⭐

El método más fácil es usar el script `remove-song.js`:

1. **Ve a la carpeta del servidor:**
   ```bash
   cd Server
   ```

2. **Ejecuta el script** con el ID o título de la canción:
   ```bash
   node remove-song.js "ID" o "Título"
   ```

   **Ejemplos:**
   ```bash
   # Eliminar por ID
   node remove-song.js "616"
   
   # Eliminar por título (búsqueda parcial)
   node remove-song.js "Document"
   ```

3. **El script:**
   - ✅ Busca la canción por ID o título
   - ✅ Muestra los detalles antes de eliminar
   - ✅ Elimina la entrada del JSON
   - ✅ Te muestra los siguientes pasos

---

### Paso 2: Eliminar Manualmente

Si prefieres hacerlo manualmente:

1. **Abre el archivo:** `Server/database/songs.json`

2. **Busca la canción** que quieres eliminar:
   - Busca por ID: `"id": "616"`
   - O por título: `"titulo": "Document"`

3. **Elimina toda la entrada** del objeto JSON:
   ```json
   {
     "id": "616",
     "titulo": "Document",
     "url": "/Document.pdf"
   }
   ```

4. **Asegúrate de eliminar la coma** si es necesaria:
   ```json
   // ❌ ANTES (con coma extra):
   {
     "id": "615",
     "titulo": "Dile",
     "url": "/Dile.pdf"
   },
   {
     "id": "616",
     "titulo": "Document",
     "url": "/Document.pdf"
   }
   
   // ✅ DESPUÉS (sin la entrada eliminada):
   {
     "id": "615",
     "titulo": "Dile",
     "url": "/Dile.pdf"
   }
   ```

5. **Guarda el archivo**

---

### Paso 3: Eliminar el PDF (Opcional) 📄

Si quieres eliminar también el archivo PDF:

1. **Identifica el nombre del PDF** desde la URL:
   - Si la URL es: `"/Document.pdf"`
   - El archivo es: `Server/public/Document.pdf`

2. **Elimínalo usando Git:**
   ```bash
   cd Server
   git rm public/Document.pdf
   ```

   O manualmente:
   ```bash
   rm Server/public/Document.pdf
   ```

**⚠️ NOTA:** 
- El PDF NO se elimina automáticamente
- Si lo eliminas de Git, se eliminará de Render también
- Si solo lo eliminas manualmente, seguirá en Render hasta que hagas `git rm`

---

### Paso 4: Commit y Push a Git

1. **Agrega los cambios:**
   ```bash
   cd Server
   git add database/songs.json
   git rm public/Document.pdf  # Solo si quieres eliminar el PDF también
   ```

2. **Haz commit:**
   ```bash
   git commit -m "Eliminar canción: Document"
   ```

3. **Haz push:**
   ```bash
   git push
   ```

4. **Render se actualizará automáticamente** (puede tardar 1-2 minutos)

---

### Paso 5: Actualizar desde la App 📱

Después de hacer push:

1. **Abre la app en tu iPhone/iPad**
2. **Presiona el botón de sincronización** (flecha circular ↻) en la parte superior derecha
3. **Espera 10-30 segundos** mientras sincroniza
4. **¡Listo!** La canción desaparecerá de la lista

---

## 📝 Ejemplo Completo

Supongamos que quieres eliminar la canción **"Document"** (ID 616):

### 1. Usar el script:
```bash
cd Server
node remove-song.js "Document"
```

### 2. Eliminar el PDF (opcional):
```bash
git rm public/Document.pdf
```

### 3. Commit y push:
```bash
git add database/songs.json
git commit -m "Eliminar canción: Document"
git push
```

### 4. Esperar 1-2 minutos y sincronizar desde la app

---

## 🔍 Verificar que se Eliminó

1. **Verifica que el servidor ya no la muestre:**
   ```bash
   curl https://lldmcantos-server.onrender.com/canciones | grep -i "document"
   ```
   
   Si no muestra nada, significa que se eliminó correctamente.

2. **En la app:**
   - Sincroniza
   - Busca la canción por nombre
   - Ya no debería aparecer

---

## ⚠️ Notas Importantes

- **⚠️ Irreversible:** Una vez que hagas push, la canción se eliminará del servidor. Solo puedes volver a agregarla manualmente.

- **🔄 Reindexar IDs (Opcional):** 
  - Los IDs NO se reindexan automáticamente (616, 617, etc.)
  - Puedes dejar los IDs como están (no afecta el funcionamiento)
  - O reindexar manualmente si prefieres IDs consecutivos

- **📄 PDF separado:** 
  - Eliminar del JSON NO elimina el PDF automáticamente
  - Debes eliminarlo manualmente con `git rm` si ya no lo necesitas
  - Si lo dejas, ocupará espacio innecesario en Render

- **⏱️ Cache:** 
  - Render puede tardar 1-2 minutos en actualizarse
  - El caché del servidor se limpia cada 5 minutos
  - La app puede tener caché local (sincroniza manualmente)

---

## 🚀 Proceso Rápido (Resumen)

1. 🗑️ Eliminar del JSON usando script o manualmente
2. 📄 Eliminar PDF con `git rm` (opcional)
3. 🔄 Commit y push a Git
4. ⏱️ Esperar 1-2 minutos
5. 📱 Sincronizar desde la app
6. ✅ ¡Listo!

---

## 🔧 Troubleshooting

### La canción sigue apareciendo en la app

**Solución:**
1. Verifica que hayas hecho push correctamente
2. Espera 2-3 minutos (caché del servidor)
3. Presiona el botón de sincronización en la app
4. Si persiste, cierra y reabre la app

### Error: "No se encontró la canción"

**Solución:**
1. Verifica que el ID o título sea correcto
2. Usa el script con el ID exacto: `node remove-song.js "616"`
3. O busca el título parcial: `node remove-song.js "Doc"` (funciona con búsqueda parcial)

### El PDF sigue ocupando espacio

**Solución:**
1. Elimínalo con: `git rm public/NombreDelArchivo.pdf`
2. Haz commit y push
3. Render lo eliminará automáticamente

---

## 💡 Consejos

- ✅ Usa el script para evitar errores de formato JSON
- ✅ Elimina el PDF si ya no lo necesitas (ahorra espacio)
- ✅ Usa títulos descriptivos en los commits
- ✅ Verifica antes de hacer push (revisa el JSON)

---

## 🔄 Restaurar una Canción Eliminada

Si eliminaste una canción por error:

1. **Verifica en el historial de Git:**
   ```bash
   git log database/songs.json
   ```

2. **Restaura desde un commit anterior:**
   ```bash
   git checkout [hash-del-commit] -- database/songs.json
   ```

3. **O vuelve a agregarla manualmente** usando el proceso de agregar canción.

---

**¿Necesitas ayuda?** Revisa `AGREGAR_CANCION.md` para ver cómo volver a agregar una canción.

