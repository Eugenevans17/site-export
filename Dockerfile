# Use a lightweight nginx image to serve static files
FROM nginx:alpine

# Copy all files to nginx default location
COPY . /usr/share/nginx/html/

# Copy nginx config
RUN echo 'server {\n\
    listen 80 default_server;\n\
    listen [::]:80 default_server;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html home.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]