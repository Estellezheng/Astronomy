# Dockerfile para Omeka S
FROM php:8.1-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libzip-dev \
    imagemagick \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Configurar e instalar extensiones PHP
RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        opcache \
        pdo_mysql \
        xml \
        zip

# Habilitar módulos de Apache
RUN a2enmod rewrite headers

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar Omeka S
COPY ./omeka-s /var/www/html/

# Copiar configuración de Apache
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Crear directorios necesarios si no existen
RUN mkdir -p /var/www/html/files \
    && mkdir -p /var/www/html/logs

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/files \
    && chmod -R 755 /var/www/html/logs

# Variables de entorno (Railway las inyectará)
ENV OMEKA_DB_HOST=${MYSQL_HOST:-mysql} \
    OMEKA_DB_PORT=${MYSQL_PORT:-3306} \
    OMEKA_DB_NAME=${MYSQL_DATABASE:-omeka} \
    OMEKA_DB_USER=${MYSQL_USER:-root} \
    OMEKA_DB_PASSWORD=${MYSQL_PASSWORD}

# Exponer puerto
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Comando de inicio
CMD ["apache2-foreground"]