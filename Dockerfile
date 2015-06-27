FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y install python-pip python-gevent git \
      bison autoconf libxml2-dev telnet wget \
      libpcre3-dev libpcre++-dev zlib1g-dev \
      build-essential tar unzip libssl-dev libbz2-dev
WORKDIR /root
RUN git clone https://github.com/nginx/nginx
RUN git clone https://github.com/php/php-src

WORKDIR /root/nginx
RUN auto/configure
RUN make
RUN make install

RUN apt-get -y install emacs mysql-client mysql-server libmysqlclient-dev

WORKDIR /root/php-src
RUN ./buildconf
RUN ./configure --enable-fpm --with-mysql
RUN make
RUN make install

RUN cp php.ini-development /usr/local/php/php.ini
RUN cp /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf
RUN cp sapi/fpm/php-fpm /usr/local/bin
RUN ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
RUN perl -i -npe 's/NONE\///g' /usr/local/etc/php-fpm.conf
RUN cp /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
RUN perl -i -npe 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/php.ini
RUN echo 'user = www-data'  >>/usr/local/etc/php-fpm.conf
RUN echo 'group = www-data' >>/usr/local/etc/php-fpm.conf
RUN perl -i -npe 's/index.html/index.php index.html/g' /usr/local/nginx/conf/nginx.conf
RUN perl -i -npe 's/location \//include extra.conf; location \//g' /usr/local/nginx/conf/nginx.conf
RUN rm -f /usr/local/nginx/html/index.html
RUN echo "<?php phpinfo(); ?>" >> /usr/local/nginx/html/index.php
RUN pip install honcho

WORKDIR /root
ADD extra.conf /usr/local/nginx/conf/extra.conf
ADD Procfile Procfile
EXPOSE 80 443
CMD [ "honcho", "start" ]
