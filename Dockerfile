# Stage 1: Builder
FROM php:8.2-fpm AS builder

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libicu-dev libpq-dev \
    nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl gd intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --optimize-autoloader --no-dev --no-interaction

RUN npm install && npm run build

# Stage 2: Runtime
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www

COPY --from=builder /var/www /var/www

RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000  # php-fpm escucha en 9000 internamente, pero Render usa proxy

# Start solo php-fpm (Render maneja el proxy)
CMD ["php-fpm"]
