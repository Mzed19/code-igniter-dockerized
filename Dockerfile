# Usa a imagem oficial do PHP com Apache
FROM php:8.2-apache

# Define o diretório de trabalho
WORKDIR /var/www/html

# Cria o usuário 1000 e o grupo 1000, se não existirem
RUN groupadd -g 1000 user1000 && \
    useradd -u 1000 -g user1000 -m user1000

# Instala dependências do sistema e extensões do PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    libmongoc-dev \
    libbson-dev \
    libicu-dev && \
    docker-php-ext-install pdo_mysql zip mbstring exif pcntl bcmath gd sockets intl && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copia os arquivos do projeto para o container
COPY . .

# Define permissões para o usuário 1000
RUN chown -R 1000:1000 /var/www/html

# Altera o usuário e grupo do Apache para 1000
RUN sed -i 's/www-data/user1000/g' /etc/apache2/envvars

# Configura o diretório raiz do Apache
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Expõe a porta 80
EXPOSE 80

# Comando padrão para iniciar o Apache
CMD ["apache2-foreground"]