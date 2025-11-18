# Dockerfile for  Omeka S
FROM php:8.1-apache

# Install system dependencies
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

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        intl \
        opcache \
        pdo_mysql \
        xml \
        zip

# Enable Apache modules
RUN a2enmod rewrite headers

# Set working directory
WORKDIR /var/www/html

# Copy Omeka S
COPY ./omeka-s /var/www/html/

# Copy Apache configuration
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Create necessary directories if they don't exist
RUN mkdir -p /var/www/html/files \
    && mkdir -p /var/www/html/logs

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/files \
    && chmod -R 755 /var/www/html/logs

# Environment variables (Railway will inject them)
ENV OMEKA_DB_HOST=${MYSQL_HOST:-mysql} \
    OMEKA_DB_PORT=${MYSQL_PORT:-3306} \
    OMEKA_DB_NAME=${MYSQL_DATABASE:-omeka} \
    OMEKA_DB_USER=${MYSQL_USER:-root} \
    OMEKA_DB_PASSWORD=${MYSQL_PASSWORD}

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start command
CMD ["apache2-foreground"]