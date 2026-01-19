# 📤 Guía para Subir el Proyecto Completo a GitHub

## 📋 Situación Actual

- ✅ Ya tienes un repositorio en GitHub (probablemente solo con la carpeta `Server/`)
- ❌ El proyecto completo de iOS no está subido

## 🚀 Pasos para Subir Todo el Proyecto

### **OPCIÓN A: Si tu repositorio actual solo tiene `Server/` y quieres agregar el resto**

#### Paso 1: Verificar el repositorio remoto actual
```bash
cd Server
git remote -v
# Anota la URL del repositorio (ej: https://github.com/tu-usuario/tu-repo.git)
```

#### Paso 2: Volver a la raíz e inicializar Git
```bash
cd ..  # Volver a la raíz del proyecto
git init
```

#### Paso 3: Agregar el remote (usando la misma URL de arriba)
```bash
git remote add origin https://github.com/tu-usuario/tu-repo.git
# Reemplaza con tu URL real
```

#### Paso 4: Verificar qué archivos se van a subir
```bash
git add .
git status
# Revisa que aparezcan todos los archivos importantes
```

#### Paso 5: Hacer commit
```bash
git commit -m "Agregar proyecto completo de iOS"
```

#### Paso 6: Hacer pull primero (para evitar conflictos)
```bash
git pull origin main --allow-unrelated-histories
# O 'master' si tu rama principal es 'master'
```

#### Paso 7: Subir todo a GitHub
```bash
git push -u origin main
# O 'master' si tu rama principal es 'master'
```

---

### **OPCIÓN B: Si quieres crear un repositorio completamente nuevo**

#### Paso 1: Crear nuevo repositorio en GitHub
1. Ve a [GitHub.com](https://github.com)
2. Click en "New repository"
3. Nombre: `LldmCantos` (o el que prefieras)
4. **NO** marques "Initialize with README" (ya tienes archivos)
5. Click en "Create repository"

#### Paso 2: Inicializar Git en tu proyecto
```bash
cd /Users/danielortizmillan/Desktop/LldmCantos
git init
```

#### Paso 3: Agregar todos los archivos
```bash
git add .
```

#### Paso 4: Verificar qué se va a subir
```bash
git status
```

#### Paso 5: Hacer el primer commit
```bash
git commit -m "Commit inicial: Proyecto completo de LldmCantos"
```

#### Paso 6: Conectar con GitHub
```bash
git remote add origin https://github.com/TU-USUARIO/TU-REPOSITORIO.git
# Reemplaza con tu URL real de GitHub
```

#### Paso 7: Subir a GitHub
```bash
git branch -M main
git push -u origin main
```

---

## 📁 Archivos que se Subirán

### ✅ Se subirán:
- ✅ Código fuente Swift (`LldmCantos/`)
- ✅ Archivo del proyecto Xcode (`LldmCantos.xcodeproj/`)
- ✅ Assets e imágenes (`Assets.xcassets/`)
- ✅ Servidor Node.js (`Server/`)
- ✅ Documentación (`.md` files)
- ✅ Scripts y utilidades

### ❌ NO se subirán (gracias al `.gitignore`):
- ❌ `node_modules/` (dependencias de Node.js)
- ❌ `xcuserdata/` (configuraciones de usuario)
- ❌ `build/`, `DerivedData/` (archivos de compilación)
- ❌ Archivos `.log`
- ❌ `.DS_Store` (archivos de macOS)

---

## 🔧 Comandos Rápidos (Todo en Uno)

Si quieres hacerlo todo de una vez:

```bash
# 1. Ir a la raíz del proyecto
cd /Users/danielortizmillan/Desktop/LldmCantos

# 2. Inicializar Git (si no está inicializado)
git init

# 3. Agregar remote (reemplaza con tu URL)
git remote add origin https://github.com/TU-USUARIO/TU-REPO.git

# 4. Agregar todos los archivos
git add .

# 5. Verificar qué se subirá
git status

# 6. Commit inicial
git commit -m "Agregar proyecto completo de LldmCantos iOS"

# 7. Si ya existe contenido en el repo, hacer pull primero
git pull origin main --allow-unrelated-histories

# 8. Subir todo
git push -u origin main
```

---

## ⚠️ Solución de Problemas

### Problema: "fatal: refusing to merge unrelated histories"
**Solución:**
```bash
git pull origin main --allow-unrelated-histories
```

### Problema: "error: failed to push some refs"
**Solución:**
```bash
# Primero hacer pull
git pull origin main --allow-unrelated-histories

# Resolver conflictos si los hay, luego:
git push -u origin main
```

### Problema: "remote origin already exists"
**Solución:**
```bash
# Ver el remote actual
git remote -v

# Si necesitas cambiarlo:
git remote set-url origin https://github.com/TU-USUARIO/TU-REPO.git
```

### Problema: Quiero subir solo el proyecto iOS, no el Server
**Solución:**
Si `Server/` ya está en un repositorio separado, puedes:
1. Agregar `Server/` al `.gitignore` temporalmente
2. O mantener ambos en el mismo repositorio (recomendado para tener todo junto)

---

## 📝 Verificar que Todo se Subió Correctamente

Después de hacer push:

1. **Ve a tu repositorio en GitHub**
2. **Verifica que ves:**
   - ✅ Carpeta `LldmCantos/` con el código Swift
   - ✅ Carpeta `Server/` con el servidor Node.js
   - ✅ Archivo `LldmCantos.xcodeproj/`
   - ✅ Archivos `.md` (documentación)
   - ✅ `.gitignore`

3. **NO deberías ver:**
   - ❌ `node_modules/`
   - ❌ `xcuserdata/`
   - ❌ `build/`
   - ❌ Archivos `.log`

---

## 💡 Recomendaciones

1. **README.md**: Crea un `README.md` en la raíz con:
   - Descripción del proyecto
   - Instrucciones de instalación
   - Cómo ejecutar el servidor
   - Cómo compilar la app

2. **Commits descriptivos**: Usa mensajes claros:
   ```bash
   git commit -m "Agregar funcionalidad de carrusel de categorías"
   git commit -m "Mejorar visor de PDFs con zoom"
   ```

3. **Ramas**: Considera usar ramas para features:
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```

4. **Ignorar archivos grandes**: Si tienes PDFs grandes en `Server/public/`, considera usar Git LFS o subirlos a un servicio de almacenamiento.

---

## ✅ Checklist Final

Antes de hacer push, verifica:

- [ ] `.gitignore` está en la raíz del proyecto
- [ ] `git status` muestra solo los archivos que quieres subir
- [ ] No hay archivos sensibles (API keys, passwords)
- [ ] Tienes la URL correcta del repositorio remoto
- [ ] Hiciste commit de todos los cambios

---

## 🆘 ¿Necesitas Ayuda?

Si encuentras algún problema:
1. Revisa los mensajes de error en la terminal
2. Verifica que tu repositorio en GitHub existe
3. Asegúrate de tener permisos para hacer push
4. Revisa que estás en la rama correcta (`main` o `master`)

¡Listo! Con estos pasos deberías tener todo tu proyecto en GitHub. 🚀

