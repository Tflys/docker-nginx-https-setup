#!/bin/bash

# Variables
DOMAIN="tu-dominio.com"  # 🔴 Cambia esto por tu dominio real
EMAIL="tu-email@ejemplo.com"  # 🔴 Cambia esto para recibir notificaciones de Let's Encrypt
WEB_DIR="$HOME/nginx-docker/web"
CONF_DIR="$HOME/nginx-docker/conf"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
NGINX_CONF="$CONF_DIR/nginx.conf"
CONTAINER_NAME="nginx_https"
IMAGE_NAME="nginx:latest"

# Función para instalar paquetes si no están instalados
install_if_not_exists() {
    if ! command -v "$1" &> /dev/null; then
        echo "🔹 Instalando $1..."
        sudo apt update && sudo apt install -y "$2"
    else
        echo "✅ $1 ya está instalado."
    fi
}

# Instalar Docker si no está instalado
install_if_not_exists "docker" "docker.io"

# Instalar Certbot si no está instalado
install_if_not_exists "certbot" "certbot"

# Crear estructura de archivos
echo "📂 Creando estructura de archivos en $WEB_DIR..."
mkdir -p "$WEB_DIR" "$CONF_DIR"

# Crear página web de prueba
echo "🌍 Creando página de inicio..."
cat <<EOF > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor Seguro con Nginx y HTTPS</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #007bff; }
    </style>
</head>
<body>
    <h1>🔒 Nginx con HTTPS y Let's Encrypt</h1>
    <p>Este sitio está protegido con SSL.</p>
</body>
</html>
EOF

# Generar certificado SSL con Let's Encrypt si no existe
if [ ! -d "$CERT_DIR" ]; then
    echo "🔑 Generando certificado SSL con Let's Encrypt..."
    sudo certbot certonly --standalone -d "$DOMAIN" --email "$EMAIL" --agree-tos --non-interactive
else
    echo "✅ Certificado SSL ya existente para $DOMAIN."
fi

# Crear configuración de Nginx con HTTPS
echo "⚙ Creando configuración de Nginx con SSL..."
cat <<EOF > "$NGINX_CONF"
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;  # Redirigir HTTP a HTTPS
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate $CERT_DIR/fullchain.pem;
    ssl_certificate_key $CERT_DIR/privkey.pem;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Descargar la imagen de Nginx si no está presente
echo "🐳 Verificando imagen de Docker..."
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "📥 Descargando imagen de Nginx..."
    docker pull "$IMAGE_NAME"
fi

# Verificar si el contenedor ya está corriendo y eliminarlo
if docker ps -a --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "🛑 Eliminando contenedor anterior..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# Ejecutar Nginx en un contenedor Docker con SSL
echo "🚀 Iniciando contenedor Nginx con HTTPS..."
docker run -d --name "$CONTAINER_NAME" -p 80:80 -p 443:443 \
    -v "$WEB_DIR:/usr/share/nginx/html" \
    -v "$NGINX_CONF:/etc/nginx/conf.d/default.conf" \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    "$IMAGE_NAME"

# Verificar si el contenedor está corriendo
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✅ Nginx con HTTPS está corriendo en Docker. Accede a https://$DOMAIN"
else
    echo "❌ Hubo un problema al iniciar el contenedor."
fi
