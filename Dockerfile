#Base Image
FROM debian:12

#Don't ask confirmation
ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt install --yes --no-install-recommends \
        wget \
        bzip2 \
        ca-certificates \
        cron \
        apache2 \
        perl \
        curl \
        jq \
        php \
        php-ldap \
        php-imap \
        php-apcu \
        php-xmlrpc \
        php-cas \
        php-mysqli \
        php-mbstring \
        php-curl \
        php-gd \
        php-simplexml \
        php-xml \
        php-intl \
        php-zip \
        php-bz2 \
        php-xdebug \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN echo "session.cookie_httponly=On" > /etc/php/8.2/apache2/conf.d/99-cookie.ini

ENV GLPI_VERSION 10.0.9
ENV GLPI_SHA512SUM b8b6650a2afb3a45b9e1b79ae2d8b8038abe4a5bfc39533d3dc562707f99cc7a56a9e8dd8296b9c9c7eefe790987b2f06dcbf45bd5bfee986492df776059dec7
# NOTE there's a hack below to get fusion to run with GLPI 10.0.9
ENV FUSION_VERSION '10.0.6+1.1'
ENV FUSION_URL_VERSION '10.0.6%2B1.1'
ENV FUSION_SHA512SUM 8cee640f942d0561bb58739325be884d81c6813de5b3d0065046a9eec01fa0c4bd9be915c3f47942a3b27766b72607a42646ce1d4d63b544de4491d30f365b31

RUN mkdir -p /app/log /app/data /app/config
RUN wget -P /tmp/ https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz && \
    echo "${GLPI_SHA512SUM}  /tmp/glpi-${GLPI_VERSION}.tgz" > /tmp/glpi.sha512sum && \
    sha512sum -c /tmp/glpi.sha512sum && \
    tar -xzf /tmp/glpi-${GLPI_VERSION}.tgz -C /app/ && \
    mv /app/glpi/files /app/data/files && \
    rm -Rf /tmp/*
RUN wget -P /tmp/ https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi${FUSION_URL_VERSION}/fusioninventory-${FUSION_VERSION}.tar.bz2 && \
    echo "${FUSION_SHA512SUM}  /tmp/fusioninventory-${FUSION_VERSION}.tar.bz2" > /tmp/fusioninventory.sha512sum && \
    sha512sum -c /tmp/fusioninventory.sha512sum && \
    mkdir -p /app/glpi/plugins && \
    tar -xjvf "/tmp/fusioninventory-${FUSION_VERSION}.tar.bz2" -C /app/glpi/plugins/ && \
    rm -Rf /tmp/*
RUN sed -i "s/define('PLUGIN_FUSIONINVENTORY_GLPI_MAX_VERSION', '10.0.7');/define('PLUGIN_FUSIONINVENTORY_GLPI_MAX_VERSION', '10.0.10');/" /app/glpi/plugins/fusioninventory/setup.php
COPY files/ /tmp/files/
RUN install -m 0644 -o root -g root /tmp/files/apache2.conf /etc/apache2/apache2.conf && \
    install -m 0644 -o root -g root /tmp/files/000-default.conf /etc/apache2/sites-available/000-default.conf && \
    install -m 0644 -o root -g root /tmp/files/glpi-cron /etc/cron.d/glpi && \
    install -m 0644 -o root -g root /tmp/files/downstream.php /app/glpi/inc/downstream.php && \
    install -m 0644 -o root -g root /tmp/files/local_define.php /app/local_define.php && \
    rm -Rf /tmp/* && \
    chown -R www-data:www-data /app && \
    chmod -R 775 /app

VOLUME /app/data
VOLUME /app/log
VOLUME /app/config

# Copy entrypoint make it as executable and run it
COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "source ~/.bashrc && /opt/entrypoint.sh ${@}", "--" ]

#Expose ports
EXPOSE 80 443
