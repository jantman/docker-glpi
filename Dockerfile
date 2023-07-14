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
    && apt upgrade \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN echo "session.cookie_httponly=On" > /etc/php/8.2/apache2/conf.d/99-cookie.ini

ENV GLPI_VERSION 10.0.9
ENV GLPI_SHA512SUM b8b6650a2afb3a45b9e1b79ae2d8b8038abe4a5bfc39533d3dc562707f99cc7a56a9e8dd8296b9c9c7eefe790987b2f06dcbf45bd5bfee986492df776059dec7

RUN mkdir -p /app/log /app/data /app/config
RUN wget -P /tmp/ https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz && \
    echo "${GLPI_SHA512SUM}  /tmp/glpi-${GLPI_VERSION}.tgz" > /tmp/glpi.sha512sum && \
    sha512sum -c /tmp/glpi.sha512sum && \
    tar -xzf /tmp/glpi-${GLPI_VERSION}.tgz -C /app/ && \
    mv /app/glpi/files /app/data/files && \
    rm -Rf /tmp/*

COPY files/ /tmp/files/
RUN install -m 0644 -o root -g root /tmp/files/apache2.conf /etc/apache2/apache2.conf && \
    install -m 0644 -o root -g root /tmp/files/000-default.conf /etc/apache2/sites-available/000-default.conf && \
    install -m 0644 -o root -g root /tmp/files/glpi-cron /etc/cron.d/glpi && \
    install -m 0644 -o root -g root /tmp/files/downstream.php /app/glpi/inc/downstream.php && \
    install -m 0644 -o root -g root /tmp/files/local_define.php /app/local_define.php && \
    install -m 0644 -o root -g root /tmp/files/Inventory.php /app/glpi/src/Inventory/Inventory.php && \
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
