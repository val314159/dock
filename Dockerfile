FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y install python-pip python-gevent git \
      bison autoconf libxml2-dev telnet wget \
      libpcre3-dev libpcre++-dev zlib1g-dev \
      build-essential tar unzip libssl-dev libbz2-dev \
      emacs mysql-client mysql-server libmysqlclient-dev
WORKDIR /root
RUN git clone https://github.com/nginx/nginx
RUN git clone https://github.com/val314159/php-src

WORKDIR /root/nginx
RUN auto/configure
RUN make
RUN make install

WORKDIR /root/php-src
RUN ./buildconf
RUN ./configure --enable-fpm --with-mysql
RUN make
RUN make install

ADD fixit fixit
RUN sh fixit
#RUN rm fixit

RUN pip install honcho

WORKDIR /root
ADD extra.conf /usr/local/nginx/conf/extra.conf
ADD Procfile Procfile
EXPOSE 80 443
CMD [ "honcho", "start" ]

WORKDIR /root/php-src
