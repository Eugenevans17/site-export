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
    && unzip /tmp/sqlite-database-integration.zip -d /tmp/ \
    && mkdir -p /usr/src/wordpress/wp-content/mu-plugins \
    && cp -r /tmp/sqlite-database-integration/* /usr/src/wordpress/wp-content/mu-plugins/ \
    && cp /usr/src/wordpress/wp-content/mu-plugins/load.php /usr/src/wordpress/wp-content/mu-plugins/0-sqlite-database-integration-loader.php \
    && rm /usr/src/wordpress/wp-content/mu-plugins/load.php \
    && cp /usr/src/wordpress/wp-content/mu-plugins/db.copy /usr/src/wordpress/wp-content/db.php \
    && chmod 644 /usr/src/wordpress/wp-content/db.php \
    && rm -rf /tmp/sqlite-database-integration /tmp/sqlite-database-integration.zip

# Copy your theme files into the WordPress themes directory
COPY . /usr/src/wordpress/wp-content/themes/my-assembler-theme/

# Create a minimal wp-config.php to trigger SQLite initialization
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
define( "WP_DEBUG", false );\n\
if ( ! defined( "ABSPATH" ) ) {\n\
    define( "ABSPATH", __DIR__ . "/" );\n\
}\n\
require_once ABSPATH . "wp-settings.php";\n\
?>' > /usr/src/wordpress/wp-config.php \
    && chmod 644 /usr/src/wordpress/wp-config.php

WORKDIR /var/www/html