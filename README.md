# 🎄 Navegación Avanzada y Visualización Integral de Active Directory

Aplicación web para administración avanzada de entornos Active Directory mediante una interfaz intuitiva, segura y extensible. Utiliza Python Flask en el backend, PowerShell para automatización y Keycloak para autenticación.

---

## 🚀 Descripción del Proyecto

Esta herramienta permite visualizar y gestionar usuarios, grupos, equipos y unidades organizativas en Active Directory, mejorando significativamente las funcionalidades ofrecidas por las herramientas nativas de Microsoft.

---

## 🎯 Objetivos

- 🔍 Interfaz web avanzada para consultar y administrar objetos de AD.
- ⚙️ Automatización de tareas administrativas con PowerShell.
- 🔐 Autenticación segura mediante Keycloak (OpenID Connect).
- 🧱 Arquitectura modular orientada a extensibilidad y mantenimiento.

---

## 🧰 Tecnologías Utilizadas

- **Backend:** Python 3.x + Flask  
- **Frontend:** HTML, CSS, JavaScript (autocompletado, validación)  
- **Automatización:** PowerShell  
- **Autenticación:** Keycloak (OAuth2/OpenID Connect)  
- **Seguridad:** Certificados SSL para conexión HTTPS

---

## 🗂️ Estructura del Proyecto

```
/app       # Lógica de negocio, rutas Flask, autenticación y utilidades
/cert      # Certificados SSL (HTTPS)
/logs      # Registros de acciones críticas
/scripts   # Scripts PowerShell (búsqueda, comparación, gestión de AD)
/static    # Archivos estáticos (JS, CSS)
/templates # Plantillas HTML para generación de vistas
run.py     # Punto de entrada de la aplicación Flask
```

---

## 🧩 Funcionalidades del Proyecto

La aplicación está diseñada para facilitar la administración completa de Active Directory a través de distintas herramientas accesibles desde una interfaz web:

### 🔎 Exploración y Búsqueda

- Consultas avanzadas sobre **usuarios, grupos, equipos y unidades organizativas (OU)**.
- Filtros personalizados por nombre, estado (habilitado/deshabilitado), grupos de pertenencia, etc.
- Sugerencias automáticas y validación de campos mediante autocompletado.

### 👤 Gestión de Cuentas

- **Desbloqueo de cuentas** bloqueadas por políticas de seguridad.
- **Restablecimiento de contraseñas** con generación segura y forzado de cambio en el siguiente inicio de sesión.
- Comprobación del estado de cuentas (habilitado/deshabilitado, expiración, etc.).

### 🧮 Comparación y Auditoría

- Comparación entre usuarios o entre grupos para detectar diferencias de membresía.
- Herramientas para análisis rápido de asignaciones en estructuras grandes.

### 📑 Generación de Informes (HTML)

- Todos los resultados se presentan en tablas HTML dinámicas.
- Compatible con exportación y visualización en navegadores modernos.
- Preparado para extenderse con nuevos reportes en base a scripts PowerShell.

---

## 🧪 Manual de Uso y Extensión

- **Inicio de sesión mediante Keycloak.**
- **Acceso segmentado por roles.**
- **Formulario específico para cada acción sobre AD.**
- **Soporte para autocompletado y validación de entradas.**
- **Fácil incorporación de nuevas herramientas siguiendo la arquitectura del proyecto.**

---

## 💡 Mejoras Futuras

- 📄 **Formularios HTML dinámicos** generados desde configuración.
- 🔍 **Optimizaciones en filtros de búsqueda** para AD.
- 🛠️ **Refactor y modularización** de scripts PowerShell.
- ⚠️ **Manejo avanzado de errores y sistema de alertas.**

---

## 🏁 Conclusión

Este proyecto proporciona una solución robusta y escalable para la gestión de Active Directory en entornos empresariales. Con una arquitectura limpia, autenticación sólida y una interfaz amigable, sirve como base para desarrollos más complejos o adaptaciones específicas.

---

> Desarrollado por Julio Gonzalez Muñiz
