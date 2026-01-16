# Use the official PHP + Apache WordPress image
FROM wordpress:6.4

# Install SQLite support and ensure PHP extension is properly loaded
RUN apt-get update && apt-get install -y libsqlite3-dev sqlite3 \
    && docker-php-ext-install pdo pdo_sqlite \
    && docker-php-ext-enable pdo pdo_sqlite

# Verify SQLite extension is loaded
RUN php -m | grep -i pdo_sqlite || (echo "ERROR: SQLite extension not loaded" && exit 1)

# Download and unzip the SQLite plugin
ADD https://downloads.wordpress.org/plugin/sqlite-database-integration.zip /tmp/
RUN apt-get install -y unzip \
    && unzip /tmp/sqlite-database-integration.zip -d /tmp/ \
    && mkdir -p /usr/src/wordpress/wp-content/mu-plugins \
    && cp -r /tmp/sqlite-database-integration/* /usr/src/wordpress/wp-content/mu-plugins/ \
    && cp /usr/src/wordpress/wp-content/mu-plugins/load.php /usr/src/wordpress/wp-content/mu-plugins/0-sqlite-database-integration-loader.php \
    && rm /usr/src/wordpress/wp-content/mu-plugins/load.php \
    && cp /usr/src/wordpress/wp-content/mu-plugins/db.copy /usr/src/wordpress/wp-content/db.php \
    && chmod 755 /usr/src/wordpress/wp-content \
    && chmod 755 /usr/src/wordpress/wp-content/mu-plugins \
    && chmod 644 /usr/src/wordpress/wp-content/db.php \
    && rm -rf /tmp/sqlite-database-integration /tmp/sqlite-database-integration.zip

# Copy your theme files into the WordPress themes directory
COPY . /usr/src/wordpress/wp-content/themes/my-assembler-theme/

# Create database directory and set permissions BEFORE wp-config
RUN mkdir -p /usr/src/wordpress/wp-content/uploads && \
    mkdir -p /usr/src/wordpress/wp-content/plugins

# Create a minimal wp-config.php 
RUN echo '<?php\n\
define( "DB_NAME", "wordpress" );\n\
define( "DB_USER", "wordpress" );\n\
define( "DB_PASSWORD", "wordpress" );\n\
define( "DB_HOST", "localhost" );\n\
define( "DB_CHARSET", "utf8mb4" );\n\
define( "DB_COLLATE", "" );\n\
define( "AUTH_KEY", "put your unique phrase here" );\n\
define( "SECURE_AUTH_KEY", "put your unique phrase here" );\n\
define( "LOGGED_IN_KEY", "put your unique phrase here" );\n\
define( "NONCE_KEY", "put your unique phrase here" );\n\
define( "AUTH_SALT", "put your unique phrase here" );\n\
define( "SECURE_AUTH_SALT", "put your unique phrase here" );\n\
define( "LOGGED_IN_SALT", "put your unique phrase here" );\n\
define( "NONCE_SALT", "put your unique phrase here" );\n\
$table_prefix = "wp_";\n\
define( "WP_DEBUG", true );\n\
define( "WP_DEBUG_LOG", "/var/www/html/wp-content/debug.log" );\n\
define( "WP_DEBUG_DISPLAY", false );\n\
if ( ! defined( "ABSPATH" ) ) {\n\
    define( "ABSPATH", __DIR__ . "/" );\n\
}\n\
require_once ABSPATH . "wp-settings.php";\n\
?>' > /usr/src/wordpress/wp-config.php \
    && chmod 644 /usr/src/wordpress/wp-config.php

# Set proper permissions for WordPress directories at build time
RUN chmod -R 755 /usr/src/wordpress/wp-content && \
    chmod 644 /usr/src/wordpress/wp-content/db.php

WORKDIR /var/www/html