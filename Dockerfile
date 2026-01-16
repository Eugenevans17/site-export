# Use the official PHP + Apache WordPress image
FROM wordpress:latest

# Install SQLite support
RUN apt-get update && apt-get install -y libsqlite3-dev \
    && docker-php-ext-install pdo_sqlite

# Download and unzip the SQLite plugin
ADD https://downloads.wordpress.org/plugin/sqlite-database-integration.zip /tmp/
RUN apt-get install -y unzip \
    && unzip /tmp/sqlite-database-integration.zip -d /usr/src/wordpress/wp-content/mu-plugins/ \
    && mv /usr/src/wordpress/wp-content/mu-plugins/sqlite-database-integration/* /usr/src/wordpress/wp-content/mu-plugins/ \
    && rm -rf /usr/src/wordpress/wp-content/mu-plugins/sqlite-database-integration/

# NEW: Copy the db.php file to the wp-content directory to enable SQLite
RUN cp /usr/src/wordpress/wp-content/mu-plugins/db.copy /usr/src/wordpress/wp-content/wp-content/db.php

# Copy your theme files (Ensure this is on one line)
COPY . /usr/src/wordpress/wp-content/themes/my-assembler-theme/

WORKDIR /var/www/html