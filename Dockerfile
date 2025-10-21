# Dockerfile principal para PrestamosEdin - Fullstack App
FROM php:8.2-apache

# Agregar Composer al contenedor
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instalar Node.js para construir el frontend
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instalar extensiones necesarias para PostgreSQL y utilidades
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install pdo pdo_pgsql zip

# Habilitar módulos de Apache necesarios
RUN a2enmod rewrite headers

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar todos los archivos del proyecto
COPY . .

# Construir el frontend React
RUN cd dashboard && \
    npm install && \
    npm run build && \
    cd .. && \
    mkdir -p build && \
    cp -r dashboard/build/* build/

# Instalar dependencias PHP del backend
RUN cd backend && composer install --no-dev --prefer-dist --no-progress --no-interaction && cd ..

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configurar Apache para usar el directorio raíz correcto
RUN echo "DocumentRoot /var/www/html" > /etc/apache2/sites-available/000-default.conf && \
    echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    DocumentRoot /var/www/html" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    DirectoryIndex index.php index.html index.htm" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    <Directory /var/www/html>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "        AllowOverride All" >> /etc/apache2/sites-available/000-default.conf && \
    echo "    </Directory>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
CMD ["apache2-foreground"]