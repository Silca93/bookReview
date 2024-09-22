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
    libonig-dev \
    libpq-dev \
    postgresql-client

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Install application dependencies
RUN composer install --optimize-autoloader --no-dev

# Optimize configuration loading
RUN php artisan config:cache
RUN php artisan route:cache

# Change current user to www-data
USER root

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Ensure the storage and bootstrap/cache directories are writable
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Expose port 80 and start PHP-FPM server
EXPOSE 80

CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]