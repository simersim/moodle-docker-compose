FROM php:8.3-apache

# Enable Apache modules
RUN a2enmod rewrite

# Install PostgreSQL client and its PHP extensions
RUN apt-get update \
    && apt-get install -y cron libpq-dev libzip-dev git zip unzip libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev libexif-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pgsql pdo pdo_pgsql zip intl soap exif

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

RUN docker-php-ext-enable opcache

RUN mkdir /var/moodledata
RUN chown -R www-data:www-data /var/moodledata
RUN chmod 0777 /var/moodledata

# Set max_input_vars to at least 5000
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/99-custom.ini

RUN echo "* * * * * /usr/local/bin/php /var/www/html/admin/cli/cron.php > /dev/null 2>&1" > /etc/cron.d/moodle-cron && \
    chmod 0644 /etc/cron.d/moodle-cron && \
    crontab /etc/cron.d/moodle-cron

