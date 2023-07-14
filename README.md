# jantman fork of jr0w3/docker-glpi

This is a fork of https://github.com/jr0w3/docker-glpi with the following major changes:

* Image is now predictable/repeatable; all software is downloaded and installed during the Docker build, in accordance with [Docker development best practices](https://docs.docker.com/develop/dev-best-practices/), [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/), and [The Twelve-Factor App/](https://12factor.net/). Restarting the container, or even recreating the container from the same tag, will not result in any changes to the running software.
* GLPI 10.0.9, latest version
* Volumes for config, data, and logs
* Apache configured for proper root directory
* [FusionInventory](https://fusioninventory.org/) `10.0.6+1.1` installed
  * Patched to install with GLPI 10.0.9
* GLPI `src/Inventory/Inventory.php` patched for some Docker modifications, namely:
  * Docker containers (virtualmachines) have their `image` field (discarded by GLPI) copied to the `comment` field (kept by GLPI)
  * Images for running Docker containers are also reported in the Software category, with the "publisher" field set to `docker`
* **NOTE:** I _am_ still running `cron` in the same container as Apache. Sorry.

## Post-Installation Notes

* You must configure FusionInventory after installation, according to https://documentation.fusioninventory.org/FusionInventory_for_GLPI/installation/
* You must also enable Inventory via `/front/inventory.conf.php`

# Quick reference

-   **Maintained by**:  
    [jr0w3](https://github.com/jr0w3)

-   **Where to file issues**:  
    [https://github.com/jr0w3/docker-glpi/issues](https://github.com/jr0w3/docker-glpi/issues)
    
-   **Supported architectures**: 
    `amd64`
-   **Current GLPI Version**: 
    `10.0.7`

### TAGS
 - [`10.0.7`,  `latest`](https://hub.docker.com/layers/jr0w3/glpi/latest/images/sha256-ecd346740bc581c9fe4f680fe793e3d65d67c438a1770b520bbc721cbe1fe9c1?context=explore)
 - [`10.0.6`](https://hub.docker.com/layers/jr0w3/glpi/10.0.6/images/sha256-1f43ae0c38913c45ce9f95430d55004aa30c69c0b029d512ec32614153575bd7?context=explore)
 - [`10.0.5`](https://hub.docker.com/layers/jr0w3/glpi/10.0.5/images/sha256-5c33cbf954f4e8f9a74eb2ffd298a5c2e8a9a87a91a24a71b8abb7382415b1eb?context=explore)
 - [`10.0.4`](https://hub.docker.com/layers/jr0w3/glpi/10.0.4/images/sha256-3af46e9944347b86871977bb59f359ed60ad9ed43b120ef5f351ecbea2b3ca5c?context=explore)
 - [`10.0.3`](https://hub.docker.com/layers/jr0w3/glpi/10.0.3/images/sha256-8ad513a14982293a68a0fe555e3c7d9a2dfba8fa7c965053c0ec00f4d61c3a23?context=explore)
 - [`10.0.2`](https://hub.docker.com/layers/jr0w3/glpi/10.0.2/images/sha256-9b56a53f6bf671aa5a1654bc5120cba18577611716a18d600ed9e86b5d05c500?context=explore)
 - [`10.0.1`](https://hub.docker.com/layers/jr0w3/glpi/10.0.1/images/sha256-3c659df958eb3adc4f628400963e398b67d1cb92dac98bf9c7d7bc08205eaf08?context=explore)
 - [`10.0.0`](https://hub.docker.com/layers/jr0w3/glpi/10.0.0/images/sha256-ff23dcdceefaac4a1bffaf9617a27b82df208797cb67f0a318f361ac453bc845?context=explore)


### Default accounts
| Login | Password | Role |
|--|--|--|
glpi|glpi|admin account
tech|tech|technical account
normal|normal|"normal" account
post-only|postonly|post-only account

### Read the documentation
Know that I have no connection with the team that develops GLPI and/or TecLib.
If you encounter a problem with this image , you can create an issue, i will help you with pleasure.
If you encounter a problem with GLPI and/or need more information on how it works, I recommend that you read the documentations:

[GLPI Administrators Docs](https://glpi-install.readthedocs.io/)

[GLPI Users Docs](https://glpi-user-documentation.readthedocs.io/)

### About SSL
The installation of GLPI is done without SSL. If you need to open access to GLPI from the outside and/or an SSL certificate, I recommend that you use a reverse proxy.

# Deploy with CLI
## Deploy GLPI
First MariaDB image using:

    docker run --name db -e MYSQL_ROOT_PASSWORD=rtpsw -e MYSQL_DATABASE=glpi -e MYSQL_USER=user -e MYSQL_PASSWORD=psw -d mariadb:10.11-rc 

Next run GLPI image:

    docker run --name glpi --link db:db -p 80:80 -e MYSQL_HOST=db -e MYSQL_DATABASE=glpi -e MYSQL_USER=user -e MYSQL_PASSWORD=psw -d jr0w3/glpi

⚠️ If you change the password on the database deployment command, don't forget to do it also for the GLPI deployment command.

## Deploy GLPI with database and persistence data
First MariaDB image using:

    docker run --name db -e MYSQL_ROOT_PASSWORD=rtpsw -e MYSQL_DATABASE=glpi -e MYSQL_USER=user -e MYSQL_PASSWORD=psw --volume /var/lib/mysql:/var/lib/mysql -d mariadb:10.11-rc 

Next run GLPI image:

    docker run --name glpi --link db:db -p 80:80 -e MYSQL_HOST=db -e MYSQL_DATABASE=glpi -e MYSQL_USER=user -e MYSQL_PASSWORD=psw --volume /var/www/html/:/data -d jr0w3/glpi

⚠️ If you change the password on the database deployment command, don't forget to do it also for the GLPI deployment command.

## Deploy GLPI with docker-compose:

    version: '2'
    
    volumes:
      data:
      db:
    
    services:
    # mariaDB Container
      db:
        image: mariadb:10.11-rc
        restart: always
        command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
        environment:
    # It is strongly recommended to change these identifiers by other more secure ones.
    # Don't forget to report them in the app service below.
          - MYSQL_ROOT_PASSWORD=rtpsw
          - MYSQL_PASSWORD=psw
          - MYSQL_DATABASE=glpi
          - MYSQL_USER=user
    
    #GLPI Container
      app:
        image: jr0w3/glpi
        restart: always
        ports:
          - 80:80
        links:
          - db
        environment:
          - MYSQL_PASSWORD=psw
          - MYSQL_DATABASE=glpi
          - MYSQL_USER=user
          - MYSQL_HOST=db

⚠️ If you change the password on the database deployment command, don't forget to do it also for the GLPI deployment command.

## Deploy GLPI with docker-compose, database and persistence data:

    version: '2'
    
    volumes:
      data:
      db:
    
    services:
    # mariaDB Container
      db:
        image: mariadb:10.11-rc
        restart: always
        command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
        volumes:
          - db:/var/lib/mysql
        environment:
    # It is strongly recommended to change these identifiers by other more secure ones.
    # Don't forget to report them in the app service below.
          - MYSQL_ROOT_PASSWORD=rtpsw
          - MYSQL_PASSWORD=psw
          - MYSQL_DATABASE=glpi
          - MYSQL_USER=user
    
    #GLPI Container
      app:
        image: jr0w3/glpi
        restart: always
        ports:
          - 80:80
        links:
          - db
        volumes:
          - data:/app/data
        environment:
          - MYSQL_PASSWORD=psw
          - MYSQL_DATABASE=glpi
          - MYSQL_USER=user
          - MYSQL_HOST=db

⚠️ If you change the password on the database deployment command, don't forget to do it also for the GLPI deployment command.
