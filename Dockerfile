# Use the official PHP + Apache WordPress image
FROM wordpress:latest

# Install SQLite support so we don't need a separate database
RUN apt-get update && apt-get install -y libsqlite3-dev \
    && docker-php-ext-install pdo_sqlite

# Download the SQLite integration plugin for WordPress
ADD https://downloads.wordpress.org/plugin/sqlite-database-integration.zip /tmp/
RUN apt-get install -y unzip \
    && unzip /tmp/sqlite-database-integration.zip -d /usr/src/wordpress/wp-content/mu-plugins/ \
    && mv /usr/src/wordpress/wp-content/mu-plugins/sqlite-database-integration/* /usr/src/wordpress/wp-content/mu-plugins/ \
    && rm -rf /usr/src/wordpress/wp-content/mu-plugins/sqlite-database-integration/

# Copy your theme files into the WordPress themes directory
# Ensure this is all on ONE line
COPY . /usr/src/wordpress/wp-content/themes/my-assembler-theme/

# Set the working directory
WORKDIR /var/www/html