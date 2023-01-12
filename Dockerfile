FROM centos:7

#设置时区
ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

COPY ./src/* /usr/local/src/

RUN yum update -y && yum install -y gcc autoconf gcc-c++ git pcre-devel libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel readline readline-devel libxslt libxslt-devel systemd-devel openjpeg-devel libicu-devel \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN cd /usr/local/src && tar xvf php-7.2.6.tar.bz2 

RUN cd /usr/local/src/php-7.2.6 && ./configure \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-config-file-scan-dir=/usr/local/php/conf.d \
    --enable-fpm \
    --with-fpm-systemd \
    --enable-mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-iconv-dir \
    --with-freetype-dir=/usr/local/freetype \
    --with-jpeg-dir --with-png-dir \
    --with-zlib \
    --with-libxml-dir=/usr \
    --enable-xml \
    --disable-rpath \
    --enable-bcmath \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --with-curl --enable-mbregex \
    --enable-mbstring \
    --enable-intl \
    --enable-ftp \
    --with-gd \
    --with-openssl \
    --with-mhash \
    --enable-pcntl \
    --enable-sockets \
    --with-xmlrpc \
    --enable-zip \
    --enable-soap \
    --with-gettext \
    --enable-fileinfo \
    --enable-opcache \
    --with-xsl && make -j4 && make install 

RUN cd /usr/local/src/php-7.2.6 && \
    cp php.ini-production /usr/local/php/etc/php.ini && \
    sed -i -e 's/expose_php = On/expose_php = Off/g' /usr/local/php/etc/php.ini &&\
    cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
    cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \
    sed -i -e 's/127.0.0.1:9000/0.0.0.0:9000/g' /usr/local/php/etc/php-fpm.d/www.conf && \
    ln -s /usr/local/php/bin/php /usr/bin/php && \
    ln -s /usr/local/php/bin/phpize /usr/bin/phpize && \
    ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

RUN cd /usr/local/src && \
    tar xvf phpredis-5.3.2.tar.gz && \
    cd phpredis-5.3.2 && /usr/local/php/bin/phpize && \
    ./configure --with-php-config=/usr/local/php/bin/php-config && make -j4 && make install && \
    echo 'extension="redis.so"' >> /usr/local/php/etc/php.ini && rm -rf phpredis

# 安装composer
COPY ./src/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

WORKDIR /data/www

EXPOSE 9000

CMD ["/usr/local/php/sbin/php-fpm", "-F"]