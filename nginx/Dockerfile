FROM ubuntu:18.04

MAINTAINER alexr (a77x77@gmail.com)

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update -y
RUN apt-get install -y nginx
RUN apt-get install -y curl
RUN apt-get install -y net-tools
RUN apt-get install -y iputils-ping
RUN apt-get install -y zsh
RUN apt-get install -y git
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

EXPOSE 80 443

ADD nginx-conf/am.kiev.ua /etc/nginx/sites-available/am.kiev.ua

RUN ln -s /etc/nginx/sites-available/am.kiev.ua /etc/nginx/sites-enabled/am.kiev.ua

ADD cert/server.crt /etc/nginx/certs/server.crt
ADD cert/server.key /etc/nginx/certs/server.key

WORKDIR /etc/nginx

CMD ["nginx"]
