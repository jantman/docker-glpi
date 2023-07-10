#Based Image
FROM debian:11.6

#Don't ask confirmation
ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt install --yes --no-install-recommends \
        wget \
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
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

ENV GLPI_VERSION 10.0.8
ENV GLPI_SHA512SUM 6bbd382780033ef264df37c582130b46e9b22eaae61a8eee1d15431ccb2ae9b31dd1f9be094c10be3b3533177813ba94c45cb714ffc50ee9148c8c8001e0e502

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
    install -m 0644 -o root -g root /tmp/files/local_define.php /app/config/local_define.php && \
    rm -Rf /tmp/* && \
    chown -R www-data:www-data /app && \
    chmod -R 775 /app && \
    rm -rf /app/glpi/install

VOLUME /app/data
VOLUME /app/log
VOLUME /app/config

# Copy entrypoint make it as executable and run it
COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "source ~/.bashrc && /opt/entrypoint.sh ${@}", "--" ]

#Expose ports
EXPOSE 80 443
