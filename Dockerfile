FROM debian:jessie
MAINTAINER Mauro <mauro@sdf.org>

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

ENV MYSQL_ROOT_PASS=chang3me
ENV MYSQL_WP_PASS=chang3me

RUN touch /etc/inittab \
    && apt-get update \
    && apt-get install -yq \
    runit ca-certificates \
    mysql-server mysql-client \
    nginx php5-fpm php5-mysql php-apc \
    php5-curl php5-gd php5-intl php-pear \
    php5-imagick php5-imap php5-mcrypt \
    php5-memcache php5-pspell php5-recode \
    php5-sqlite php5-tidy php5-xmlrpc php5-xsl \
    python-setuptools curl wget git unzip \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf \
    && sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf \
    && sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf \
    && sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini \
    && sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini \
    && sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini \
    && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf \
    && sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf \
    && find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

COPY ["conf/nginx-default.conf", "/etc/nginx/sites-available/default"]
COPY ["services/nginx.run", "/etc/service/nginx/run"]
COPY ["services/php5-fpm.run", "/etc/service/php5-fpm/run"]
COPY ["services/mysql.run", "/etc/service/mysql/run"]

ADD https://wordpress.org/latest.tar.gz /usr/share/nginx/latest.tar.gz
RUN cd /usr/share/nginx/ \
    && tar xvf latest.tar.gz \
    && rm latest.tar.gz \
    && wget --no-check-certificate https://downloads.wordpress.org/plugin/nginx-helper.1.9.7.zip \
    && unzip -o nginx-helper.*.zip -d /usr/share/nginx/wordpress/wp-content/plugins \
    && rm /usr/share/nginx/nginx-helper*.zip \
    && chown -R www-data:www-data /usr/share/nginx/wordpress \
    && chmod 755 /etc/service/nginx/run \
    && chmod 755 /etc/service/php5-fpm/run \
    && chmod 755 /etc/service/mysql/run

COPY ["conf/wp-config.php", "/usr/share/nginx/wordpress/wp-config.php"]

################################################
# NOT THE NICEST SOLUTION BUT IT WORKS FOR DEV #
################################################
RUN /usr/bin/mysqld_safe & \
    sleep 10s \
    && echo "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASS}' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql \
    && echo "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '${MYSQL_WP_PASS}'; FLUSH PRIVILEGES;" | mysql \
    && sed -i -e "s/_REPLACEME_/${MYSQL_WP_PASS}/" /usr/share/nginx/wordpress/wp-config.php

EXPOSE 80

VOLUME ["/var/lib/mysql", "/usr/share/nginx/wordpress/wp-content/themes/"]
CMD ["/usr/bin/runsvdir", "-P", "/etc/service"]
