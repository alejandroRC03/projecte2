FROM orboan/dind
MAINTAINER Pau España y Alejandro Rodriguez

ARG language=ca_ES

#Variables de entorno mysql
ENV MYSQL_ROOT_PASSWORD=paulejo
ENV MYSQL_DATABASE=bbdduniversitat
ENV MYSQL_USER=dev
ENV MYSQL_PASSWORD=dev_password

ENV \
    USER=alumne \
    PASSWORD=alumne \
    LANG="${language}.UTF-8" \
    LC_CTYPE="${language}.UTF-8" \
    LC_ALL="${language}.UTF-8" \
    LANGUAGE="${language}:ca" \
    REMOVE_DASH_LINECOMMENT=true \
    SHELL=/bin/bash 
ENV \
    HOME="/home/$USER" \
    DEBIAN_FRONTEND="noninteractive" \
    RESOURCES_PATH="/resources" \
    SSL_RESOURCES_PATH="/resources/ssl"
ENV \
    WORKSPACE_HOME="${HOME}" \
    MYSQL_ALLOW_EMPTY_PASSWORD=true \
    MYSQL_USER="$USER" \ 
    MYSQL_PASSWORD="$PASSWORD"

    
# Layer cleanup script
COPY resources/scripts/*.sh  /usr/bin/
RUN chmod +x usr/bin/*.sh


# Make folders
RUN \
    mkdir -p $RESOURCES_PATH && chmod a+rwx $RESOURCES_PATH && \
    mkdir -p $SSL_RESOURCES_PATH && chmod a+rwx $SSL_RESOURCES_PATH && \
    mkdir -p /etc/supervisor /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor /var/logs /var/run/supervisor

## locales
RUN \
    if [ "$language" != "en_US" ]; then \
        apt-get -y update; \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends locales; \
        echo "${language}.UTF-8 UTF-8" > /etc/locale.gen; \
        locale-gen; \
        dpkg-reconfigure --frontend=noninteractive locales; \
        update-locale LANG="${language}.UTF-8"; \
    fi \
    && clean-layer.sh

#Instalacion basica
RUN \
  apt update -y && \
  if ! which gpg; then \
       apt-get install -y --no-install-recommends gnupg; \
  fi; \
  clean-layer.sh


#Instalación de programas
RUN \
  apt update -y && \ 
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  build-essential \
  software-properties-common \
  curl \
  apt-utils \
  ssh \
  #pyhton3.5 \
  #python3-pip \
  gradle \
  maven \
  nodejs \
  openssl \
  vim \
  bash-completion \
  iputils-ping \
  npm \
  openjdk-11-jdk \
  git \
  wget && \
  clean-layer.sh 

#Instalacion docker-compose
#RUN curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#RUN chmod +x /usr/local/bin/docker-compose


# Instalamos supervisor
RUN  apt install -y supervisor

# Instalamos el servidor ssh
RUN apt update -y && \
    apt install -y openssh-server

# Add PHPMyAdmin
#RUN curl -L -o /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
#    && tar xvf /tmp/phpmyadmin.tar.gz -C /var/www/ \
#    && rm /tmp/phpmyadmin.tar.gz \
#    && mv /var/www/phpMyAdmin-5.0.2-all-languages /var/www/phpmyadmin \
#    && curl -L -o /var/www/phpmyadmin/config.inc.php https://raw.githubusercontent.com/phpmyadmin/docker/master/config.inc.php

# Instalamos VS Code web
RUN apt install -y curl && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt update && \
    apt install -y code-oss

# Instalamos Python 3 y pip
RUN apt-get install -y python3 && \
    apt-get install -y python3-pip

# Instalamos Node.js y npm
RUN apt-get install -y nodejs && \
    apt-get install -y npm

# Instalamos SDKMAN
RUN curl -s "https://get.sdkman.io" | bash

# Instalamos el cliente de Docker
RUN apt-get install -y docker.io

# Instalamos Docker Compose
RUN apt-get install -y docker-compose

# Instalamos el cliente de MySQL
RUN apt-get install -y mysql-client

# Instalamos Git
RUN apt-get install -y git

# Instalamos el cliente de GitHub
RUN apt-get install -y hub

# Instalamos Maven CLI
RUN apt-get install -y maven

# Instalamos Gradle CLI
RUN apt-get install -y gradle

# Creamos un volumen para el directorio $HOME del usuario dev
VOLUME $HOME

# Creamos un volumen para /var/lib/docker
VOLUME /var/lib/docker

# Creamos un volumen para el socket de Docker
VOLUME /var/run/docker.sock

# Exponemos el puerto 2222 para acceder a ssh
EXPOSE 2222

# Exponemos el puerto 8081 para acceder a VSCode
EXPOSE 8081

EXPOSE 3306

# Copiamos el archivo de configuración de supervisor
COPY resources/etc/supervisor/*.conf  /resources/etc/supervisor/conf.d
RUN chmod +x /resources/etc/supervisor/supervisord.conf

# Establecemos el comando a ejecutar al iniciar el contenedor
CMD ["/usr/bin/supervisord"]
