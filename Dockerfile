FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    supervisor \
    openssh-server \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    mysql-client \
    maven \
    gradle \
    && apt-get clean

RUN curl -s "https://get.sdkman.io" | bash

RUN pip3 install docker

RUN pip3 install docker-compose

RUN curl -s https://raw.githubusercontent.com/cli/cli/trunk/install.sh | sh

RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY supervisord.conf /etc/supervisor/conf.d/

RUN wget https://github.com/cdr/code-server/releases/download/3.5.1/code-server-3.5.1-linux-x86_64.tar.gz
RUN tar -xzf code-server-3.5.1-linux-x86_64.tar.gz
RUN rm code-server-3.5.1-linux-x86_64.tar.gz
RUN mv code-server-3.5.1-linux-x86_64 /usr/local/lib/code-server

VOLUME ["/var/lib/docker", "$HOME"]

EXPOSE 2222 8081
CMD ["/usr/bin/supervisord"]
