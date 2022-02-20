FROM php:8.0.11-fpm-alpine3.14
# PHP extensions


RUN apk add --update --no-cache mysql-client msmtp perl wget procps shadow libzip libpng libjpeg-turbo libwebp freetype icu


RUN set -ex \
    && apk add --update --no-cache --virtual build-essentials  zlib-dev libzip-dev nginx autoconf g++ make libpng-dev curl icu-dev libwebp-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && pecl install redis \	
    && docker-php-ext-enable redis \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) opcache \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) fileinfo \
    && docker-php-ext-install -j$(nproc) sockets

RUN apk add --update --no-cache nodejs npm yarn

RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer	   
COPY php.ini /usr/local/etc/php/php.ini 
COPY default.conf /etc/nginx/http.d/default.conf
COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh /etc/entrypoint.sh
COPY index.html /var/www/html/public/index.html
COPY info.php /var/www/html/public/info.php
RUN chmod +x /etc/entrypoint.sh


EXPOSE 80 443

ENTRYPOINT ["/etc/entrypoint.sh"]
