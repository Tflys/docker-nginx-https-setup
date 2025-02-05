# 🚀Configuración automática de Nginx con Docker y HTTPS

![Nginx + Docker + HTTPS](https://img.shields.io/badge/Nginx-Docker-009639?style=for-the-badge&logo=nginx)
![License](https://img.shields.io/github/license/tu-usuario/NginxShield?style=for-the-badge)

📢 Es un script en **Bash** que instala y configura automáticamente un servidor **Nginx con HTTPS** usando **Docker** y certificados gratuitos de **Let's Encrypt** para hacer pruebas en entornos de desarrollo.  

## 📌 Características

✅ **Instala automáticamente Docker y Certbot** si no están presentes.  
✅ **Genera certificados SSL/TLS gratuitos** con Let's Encrypt.  
✅ **Configura Nginx en un contenedor Docker** con soporte HTTPS.  
✅ **Redirige automáticamente HTTP a HTTPS** para mayor seguridad.  
✅ **Renovación automática de certificados** con cron.  

---

## 📦 Instalación y uso

1️⃣ Clonar el repositorio** 
bash
git clone https://github.com/tflys/docker-nginx-https-setup.git
cd docker-nginx-https-setup

2️⃣ Editar variables en el script
Antes de ejecutar el script, abre setup-nginx-https.sh y edita:

DOMAIN="tu-dominio.com" → Reemplázalo por tu dominio real.
EMAIL="tu-email@ejemplo.com" → Para recibir notificaciones de SSL.

3️⃣ Dar permisos de ejecución
bash
Copiar
Editar
chmod +x setup-nginx-https.sh

4️⃣ Ejecutar el script
bash
Copiar
Editar
./setup-nginx-https.sh

5️⃣ Acceder a tu servidor
📌 Abre en tu navegador:
🔗 http://tu-dominio.com → Se redirigirá a https://tu-dominio.com con SSL activo.

🔄 Renovación automática de certificados
Los certificados de Let's Encrypt expiran cada 90 días. Para renovarlos automáticamente, puedes añadir esto a cron:

bash

(crontab -l ; echo "0 3 * * 1 certbot renew --quiet && docker restart nginx_https") | crontab -

//Esto intentará renovar el certificado cada lunes a las 03:00 AM.
---
🛠 Requisitos
✅ Un dominio apuntando a tu servidor.
✅ Ubuntu/Debian (o cualquier sistema con Bash).
✅ Puertos 80 y 443 abiertos en el firewall.
✅ Docker instalado (el script lo instala si no está presente).
---
📜 Licencia
Este proyecto está bajo la Licencia MIT – puedes usarlo, modificarlo y distribuirlo libremente.
---
👨‍💻 Contribuir
¿Quieres mejorar este proyecto? ¡Las contribuciones son bienvenidas! Puedes:

Hacer un fork del repositorio.
Crear una rama nueva con tus cambios.
Enviar un Pull Request.

Si tienes dudas o sugerencias, puedes abrir un issue.
