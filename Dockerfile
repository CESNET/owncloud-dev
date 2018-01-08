FROM php:7.0-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		libcurl4-openssl-dev \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libldap2-dev \
		libmcrypt-dev \
		libmemcached-dev \
		libpng12-dev \
		libpq-dev \
		libxml2-dev \
		wget \
		make \
		npm \
		nodejs \
		unzip \
		git \
		apt-transport-https \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# Fix for build error:
# cd build && /usr/local/bin/yarn install
# /usr/bin/env: node: No such file or directory
RUN ln -s /usr/bin/nodejs /usr/bin/node

# https://doc.owncloud.org/server/8.1/admin_manual/installation/source_installation.html#prerequisites
RUN set -ex; \
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
	docker-php-ext-configure ldap --with-libdir="lib/$debMultiarch"; \
	docker-php-ext-install exif gd intl ldap mbstring mcrypt opcache pdo pdo_mysql pdo_pgsql pgsql zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
RUN a2enmod rewrite

# PECL extensions
RUN set -ex \
	&& pecl install APCu-5.1.8 \
	&& pecl install memcached-3.0.3 \
	&& pecl install redis-3.1.2 \
	&& docker-php-ext-enable apcu memcached redis

# Yarn build dependency
RUN npm install -g yarn

WORKDIR /var/www/html
RUN git clone https://github.com/owncloud/core.git .
RUN chown -R www-data:www-data .
RUN chmod o+rw .
RUN make

COPY bootstrap.sh /usr/local/bin/
ENTRYPOINT ["bootstrap.sh"]
