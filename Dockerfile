# Use an official PHP 8.3 image with FPM
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www

# Copy composer.json and composer.lock
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-scripts --no-autoloader

# Copy existing application directory contents
COPY . /var/www

# Generate autoloader
RUN composer dump-autoload --optimize

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Copy Nginx config
COPY nginx.conf /etc/nginx/sites-available/default

# Enable error logging
RUN mkdir -p /var/log/php \
    && touch /var/log/php/errors.log \
    && chown -R www-data:www-data /var/log/php

# Expose port 80
EXPOSE 80

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh \
    && echo 'php artisan config:clear' >> /entrypoint.sh \
    && echo 'php artisan cache:clear' >> /entrypoint.sh \
    && echo 'php artisan config:cache' >> /entrypoint.sh \
    && echo 'php artisan route:cache' >> /entrypoint.sh \
    && echo 'php-fpm -D' >> /entrypoint.sh \
    && echo 'nginx -g "daemon off;"' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]