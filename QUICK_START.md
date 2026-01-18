# ⚡ Quick Start - Render Deployment

## 🚀 Pasos Rápidos (5 minutos)

### 1️⃣ Crear Cuenta
- Ve a [render.com](https://render.com)
- Crea cuenta (con GitHub o email)

### 2️⃣ Subir Código

**Opción A: Con GitHub (Recomendado)**
```bash
cd /Users/danielortizmillan/Desktop/LldmCantos/Server
git init
git add .
git commit -m "Initial commit"
# Agregar repositorio remoto de GitHub
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git push -u origin main
```

**Opción B: Manualmente**
- En Render: New + → Web Service → Manual Deploy
- Sube la carpeta `Server/` completa

### 3️⃣ Configurar en Render

**En Render Dashboard:**
- New + → Web Service
- Conecta tu repositorio (o sube manualmente)
- **Build Command:** `npm install`
- **Start Command:** `npm start`
- **Plan:** Free
- Click "Create Web Service"

### 4️⃣ Configurar BASE_URL

**Después del deployment:**
1. Render te dará una URL: `https://lldmcantos-server-xxxx.onrender.com`
2. Ve a **Environment** en Render
3. Agrega variable: `BASE_URL` = `https://lldmcantos-server-xxxx.onrender.com`
4. Guarda y reinicia

### 5️⃣ Actualizar App iOS

**En `PDFService.swift`:**
```swift
// Cambiar esta línea:
private let baseURL = "http://192.168.100.57:3000"

// Por tu URL de Render:
private let baseURL = "https://lldmcantos-server-xxxx.onrender.com"
```

---

## ✅ Verificar

```bash
# Verificar servidor
curl https://tu-url.onrender.com/health

# Verificar canciones
curl https://tu-url.onrender.com/canciones | head -20
```

---

## 📚 Guía Completa

Lee `DEPLOY_RENDER.md` para instrucciones detalladas.

---

## ⚠️ Nota Importante

**Render Free Plan:**
- El servidor "duerme" después de 15 min sin uso
- Primera petición tarda ~30 segundos (para despertar)
- Después funciona normal

---

✅ **¡Listo para subir!**

