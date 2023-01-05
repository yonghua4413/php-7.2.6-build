### php7.2 docker 构建

#### 配置
```
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
--disable-fileinfo \
--enable-opcache \
--with-xsl
```

#### redis扩展
```
/usr/local/php/bin/phpize 
./configure --with-php-config=/usr/local/php/bin/php-config 
./configure --with-php-config=/usr/local/php73/bin/php-config
make -j4 && make install
```

#### 推荐安装
```
# 构建镜像
docker build --pull --rm -f "Dockerfile" -t php72:v2 "."
# 创建容器
docker run -itd --name php72 -p 9000:9000 -v /www:/www --network local.net php72:v2
```
- -v 目录需要一一对应
- --network 需要分配网络，否则可能导致php容器无法与其他容器通信（如redis）