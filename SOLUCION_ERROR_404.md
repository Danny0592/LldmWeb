# 🔧 Solución al Error 404 al Cargar PDFs

## 🔍 Diagnóstico

El error **"error al descargar pdf: 404"** significa que:

1. ✅ El servidor en Render está funcionando
2. ✅ La app puede obtener la lista de canciones (`/canciones`)
3. ❌ **Los PDFs no están disponibles en Render**

---

## 📋 Causa del Problema

Cuando eliminamos los PDFs del repositorio Git, también los eliminamos de la carpeta local `Server/public/`. Sin embargo:

- ✅ Los PDFs siguen listados en `Server/database/songs.json` (con sus URLs)
- ❌ Los PDFs **NO están físicamente** en el servidor de Render
- ❌ Por lo tanto, cuando la app intenta descargarlos, recibe error 404

---

## ✅ Soluciones

### **Opción 1: Subir PDFs a Render Manualmente (Recomendado)**

Los PDFs deben estar en Render en la carpeta `public/`. 

#### Pasos:

1. **Accede a Render Dashboard**
   - Ve a https://dashboard.render.com
   - Selecciona tu servicio `lldmcantos-server`

2. **Sube los PDFs** (Render Shell o Git):
   
   **⚠️ NOTA IMPORTANTE:** Si tienes el plan **gratuito** de Render, **NO puedes usar Shell**. En ese caso, salta directamente al **Método B (Git)**.
   
   **Método A: Usando Render Shell** ⚠️ **Requiere plan de pago (Starter o superior)**
   - En Render Dashboard, ve a tu servicio
   - Haz clic en "Shell" o "SSH"
   - Si aparece un modal diciendo que necesitas actualizar, significa que tienes plan gratuito
   - Solo funciona si tienes plan Starter o superior
   - **Si tienes plan de pago:** Desde el Shell, navega a la carpeta `public/` con: `cd public`
   - Sube los PDFs usando `wget` o `curl`
   
   ⚠️ **Este método NO funciona con plan gratuito. Usa el Método B.**
   
   **Método B: Usando Git** ✅ **Funciona con plan gratuito (RECOMENDADO)**
   - Los PDFs deben estar en `Server/public/` localmente
   - Temporalmente, necesitas permitir que los PDFs se suban a Git
   - Ver instrucciones detalladas a continuación en "Solución para Plan Gratuito"

3. **Verifica que los PDFs estén ahí:**
   ```bash
   # En Render Shell
   ls public/ | head -10
   ```

4. **Reinicia el servidor** si es necesario

---

### **🔓 Solución para Plan Gratuito de Render (Sin Shell)**

Si tienes el plan **gratuito** de Render, **NO puedes usar Shell**. Sigue estos pasos para subir los PDFs usando Git:

#### Paso 1: Preparar los PDFs localmente (En tu computadora, NO en Render)

**📍 IMPORTANTE:** Todo esto lo haces **en tu computadora**, NO en Render.

1. **Asegúrate de tener los PDFs** en tu computadora
2. **Navega a la carpeta del proyecto** en tu terminal:
   ```bash
   cd /Users/danielortizmillan/Desktop/LldmCantos/Server
   ```
   
3. **La carpeta `public/` está aquí:** `Server/public/`
   - Ruta completa: `/Users/danielortizmillan/Desktop/LldmCantos/Server/public/`
   - Puedes abrirla en Finder: Ve a la carpeta `LldmCantos` → `Server` → `public`

4. **Coloca los PDFs** en esa carpeta:
   ```bash
   # Opción A: Desde terminal (copia todos los PDFs de una carpeta)
   cp /ruta/a/tus/pdfs/*.pdf Server/public/
   
   # Opción B: Manualmente (arrastra los PDFs desde Finder)
   # Abre Finder → Ve a donde están tus PDFs
   # Selecciona todos los PDFs → Cópialos
   # Ve a LldmCantos/Server/public/ → Pégalos
   ```
   
   **💡 Tip:** Puedes verificar que los PDFs estén ahí:
   ```bash
   ls Server/public/*.pdf | wc -l  # Cuenta cuántos PDFs hay
   ```

#### Paso 2: Permitir temporalmente los PDFs en Git ✅ **YA ESTÁ HECHO**

1. **✅ Archivo editado:** `Server/.gitignore`
2. **✅ Línea comentada:** La línea `public/*.pdf` ahora está comentada con `#`
3. **✅ Verificación:**
   ```bash
   cd /Users/danielortizmillan/Desktop/LldmCantos/Server
   grep "public/\*\.pdf" .gitignore
   ```
   Debería mostrar: `# public/*.pdf` (con el `#` al inicio)

**⚠️ Si necesitas hacerlo manualmente:**
- Abre `Server/.gitignore` con tu editor
- Busca la línea `public/*.pdf` (línea 255)
- Agrega `#` al inicio: `# public/*.pdf`
- Guarda el archivo

#### Paso 3: Colocar los PDFs en `Server/public/` ⚠️ **IMPORTANTE: Hacer ANTES de `git add`**

**El error `zsh: no matches found: public/*.pdf` significa que NO hay PDFs en la carpeta.**

Primero necesitas copiar los PDFs a la carpeta `public/`:

**Opción A: Desde Terminal**
```bash
# Navegar a donde tienes los PDFs
cd /ruta/a/tus/pdfs

# Copiar todos los PDFs a Server/public/
cp *.pdf /Users/danielortizmillan/Desktop/LldmCantos/Server/public/

# O desde cualquier ubicación:
cp /ruta/completa/a/*.pdf /Users/danielortizmillan/Desktop/LldmCantos/Server/public/
```

**Opción B: Desde Finder (Más fácil)**
1. Abre Finder
2. Ve a donde tienes los PDFs
3. Selecciona todos los PDFs (Cmd + A si están todos juntos)
4. Cópialos (Cmd + C)
5. Navega a: `Desktop` → `LldmCantos` → `Server` → `public`
6. Pégalos (Cmd + V)

**Verificar que los PDFs estén ahí:**
```bash
cd /Users/danielortizmillan/Desktop/LldmCantos/Server
ls public/*.pdf | wc -l  # Debe mostrar el número de PDFs
ls public/*.pdf | head -5  # Ver los primeros 5
```

**⚠️ Si el comando anterior muestra "no matches found", significa que aún NO has copiado los PDFs.**

---

#### Paso 4: Hacer Commit y Push

**Solo después de tener los PDFs en `public/`:**

```bash
cd Server

# ⚠️ SOLUCIÓN AL ERROR "zsh: no matches found":
# Usa find en lugar de wildcard, o encierra el patrón en comillas

# Opción A: Agregar toda la carpeta (RECOMENDADO - Más simple y seguro)
git add public/

# Opción B: Usar find con xargs (si Opción A no funciona)
find public -name "*.pdf" -print0 | xargs -0 git add

# Opción C: Usar comillas simples (puede fallar con espacios en nombres)
git add 'public/*.pdf'

# Verificar que se agregaron correctamente
git status
# Deberías ver muchos archivos PDF listos para commit

# Hacer commit
git commit -m "Subir PDFs a Render (temporal para despliegue)"

# Push a GitHub
git push origin main
```

**⚠️ NOTA IMPORTANTE:** Si `git add public/*.pdf` da el error `zsh: no matches found`, usa una de las opciones alternativas arriba. Esto pasa porque zsh interpreta el `*` antes de pasarlo a git.

#### Paso 4: Esperar el Despliegue en Render

- Render detectará automáticamente el push
- Reiniciará el servidor automáticamente
- Los PDFs estarán disponibles en `https://lldmcantos-server.onrender.com/NombreDelArchivo.pdf`

#### Paso 5: Volver a Ignorar los PDFs (Opcional)

Si no quieres seguir trackeando los PDFs en Git después del despliegue:

```bash
# Restaurar la línea en .gitignore
# Descomentar: public/*.pdf

# Eliminar los PDFs del tracking de Git (pero mantenerlos en el disco)
git rm --cached public/*.pdf

# Commit del cambio
git commit -m "Dejar de trackear PDFs después del despliegue"
git push origin main
```

**⚠️ Nota:** Si haces esto, los PDFs seguirán en Render, pero no se actualizarán automáticamente si cambias algo.

---

### **Opción 2: Usar un Servicio de Almacenamiento Externo**

En lugar de almacenar PDFs en Render, puedes:

- **Amazon S3**
- **Cloudinary**
- **Firebase Storage**
- **GitHub Releases** (conversión a URLs directas)

Y actualizar las URLs en `songs.json` para apuntar a esos servicios.

---

### **Opción 3: Verificar que los PDFs Estén en Render**

1. **Prueba acceder directamente a un PDF:**
   ```
   https://lldmcantos-server.onrender.com/A_donde_ire.pdf
   ```

2. **Si no carga:**
   - Los PDFs no están en Render
   - Necesitas subirlos

3. **Si carga:**
   - El problema puede ser otro (URLs mal formadas, etc.)

---

## 🚀 Solución Rápida: Verificar Estado Actual

### Paso 1: Verificar qué canciones están en la lista
```bash
curl https://lldmcantos-server.onrender.com/canciones | jq '.[0:3]'
```

### Paso 2: Verificar si un PDF específico existe
```bash
curl -I https://lldmcantos-server.onrender.com/A_donde_ire.pdf
```

### Paso 3: Verificar si la carpeta public/ existe en Render
- Accede a Render Shell
- Verifica: `ls -la public/`

---

## 💡 Recomendación

**Si los PDFs no están en Render**, tienes dos opciones:

### A) Subirlos a Render (si tienes espacio)
- Render Free tier tiene límites de espacio
- Necesitas subir ~600 PDFs (~100MB)
- Puede ser lento pero funciona

### B) Usar un servicio de almacenamiento dedicado
- Mejor para producción
- Más rápido y confiable
- Requiere configuración adicional

---

## 🔧 Mejora Aplicada

He mejorado el mensaje de error en la app para que sea más descriptivo cuando hay un error 404, indicando específicamente que el PDF no se encontró en el servidor.

---

## 📝 Próximos Pasos

1. ✅ Verifica si los PDFs están en Render
2. ✅ Si no están, súbelos
3. ✅ Si están, verifica que las URLs sean correctas
4. ✅ Prueba abrir una canción de nuevo

---

¿Los PDFs están físicamente en tu servidor de Render? Si no, necesitamos subirlos.

