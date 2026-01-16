# Use the official PHP + Apache WordPress image
FROM wordpress:latest

# Install SQLite support and ensure PHP extension is properly loaded
RUN apt-get update && apt-get install -y libsqlite3-dev sqlite3 \
    && docker-php-ext-install pdo_sqlite

# Ensure SQLite extension is enabled
RUN echo "extension=pdo_sqlite.so" > /usr/local/etc/php/conf.d/docker-php-ext-pdo_sqlite.ini

# Download and unzip the SQLite plugin
ADD https://downloads.wordpress.org/plugin/sqlite-database-integration.zip /tmp/
RUN apt-get install -y unzip \
    && unzip /tmp/sqlite-database-integration.zip -d /usr/src/wordpress/wp-content/mu-plugins/ \
    && mv /usr/src/wordpress/wp-content/mu-plugins/sqlite-database-integration/* /usr/src/wordpress/wp-content/mu-plugins/ \
    && rm -rf /usr/src/wordpress/wp-content/mu-plugins/sqlite-database-integration/ /tmp/sqlite-database-integration.zip

# Create the directory if it doesn't exist and copy the SQLite drop-in to the correct location
RUN mkdir -p /usr/src/wordpress/wp-content && \
    cp /usr/src/wordpress/wp-content/mu-plugins/db.copy /usr/src/wordpress/wp-content/db.php && \
    chmod 644 /usr/src/wordpress/wp-content/db.php

# Copy your theme files into the WordPress themes directory
COPY . /usr/src/wordpress/wp-content/themes/my-assembler-theme/

WORKDIR /var/www/html