FROM orboan/dind
MAINTAINER Pau España y Alejandro Rodriguez

ARG language=ca_ES

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


# Instalamos supervisor
RUN apt install -y supervisor

#Instalamos el servidor SSH

RUN apt update -y && \
    apt install -y openssh-server
# Add PHPMyAdmin
#RUN curl -L -o /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
#    && tar xvf /tmp/phpmyadmin.tar.gz -C /var/www/ \
#    && rm /tmp/phpmyadmin.tar.gz \
#    && mv /var/www/phpMyAdmin-5.0.2-all-languages /var/www/phpmyadmin \
#    && curl -L -o /var/www/phpmyadmin/config.inc.php https://raw.githubusercontent.com/phpmyadmin/docker/master/config.inc.php


# Descargar VS Code versión web
RUN apt-get update && apt-get install -y curl gpg
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    rm microsoft.gpg
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
RUN apt-get update && apt-get install -y code
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Instalar Git y las CLI de Github y Gitlab
RUN apt-get install -y git && \
    curl -LJO https://github.com/github/hub/releases/download/v2.14.2/hub-linux-amd64-2.14.2.tgz && \
    tar xvzf hub-linux-amd64-2.14.2.tgz && \
    cd hub-linux-amd64-2.14.2 && \
    ./install && \
    cd ../ && \
    rm -rf hub-linux-amd64-2.14.2 && \
    rm hub-linux-amd64-2.14.2.tgz

# Configurar el servidor ssh
#RUN mkdir /var/run/sshd && \
#    echo 'root:root' | chpasswd && \
#    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd



# Instalamos Python 3 y pip
RUN apt-get update && apt-get install -y python3 python3-pip
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instalamos Node.js y npm
RUN apt-get install -y nodejs && \
    apt-get install -y npm

# Instalamos el cliente de Docker
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce-cli


# Instalamos el cliente de MySQL
RUN apt-get update && apt-get install -y mysql-client

#Variables de entorno mysql
ENV MYSQL_ROOT_PASSWORD=paulejo
ENV MYSQL_DATABASE=bbdduniversitat
ENV MYSQL_USER=dev
ENV MYSQL_PASSWORD=dev_password

# Instalamos Maven CLI
RUN apt-get update && apt-get install -y maven

# Instalamos Gradle CLI
RUN apt-get update && apt-get install -y gradle

# Creamos un volumen para el directorio $HOME del usuario dev
VOLUME /home/dev

# Creamos un volumen para /var/lib/docker
VOLUME /var/lib/docker

# Creamos un volumen para el socket de Docker
VOLUME /var/run/docker.sock

# Exponemos los puertos
EXPOSE 2222:22 8081 3306 9001 443

#Expone el puerto code-server
EXPOSE 8080

COPY modprobe startup.sh /usr/local/bin/
COPY logger.sh /opt/bash-utils/logger.sh 


# Copiamos el archivo de configuración de supervisor

COPY resources/etc/supervisor /etc/supervisor

RUN chmod +x /usr/local/bin/startup.sh /usr/local/bin/modprobe

ENTRYPOINT [ "code-server" ]

CMD [ "code" ]
