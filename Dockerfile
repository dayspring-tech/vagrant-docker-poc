FROM fedora:latest
ENV container docker
LABEL __copyright__="(C) Dayspring Technology Inc." \
      __version__="1.0.0"

# Perform a package update
RUN dnf -y update
RUN dnf -y install 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled fedora-cisco-openh264

# Add some familiar utilities
RUN dnf -y install procps \
  htop \
  grep \
  findutils \
  iputils \
  iproute \
  wget \
  git \
  ruby \
  libxcrypt-compat

# Add sshd server so we can 'vagrant ssh' later
RUN dnf -y install openssh-server openssh-clients passwd sudo; 
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN useradd --create-home -s /bin/bash vagrant
RUN echo -e "vagrant\nvagrant" | (passwd --stdin vagrant)
RUN echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh

# Allow public key authentication for 'vagrant ssh' in Fedora 35
RUN sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/i' /etc/ssh/sshd_config
# This softens a crypto policy that prevents vagrant completing ssh setup
RUN sed -i 's/^Include \/etc\/crypto-policies\/back-ends\/opensshserver.config/#Include \/etc\/crypto-policies\/back-ends\/opensshserver.config/i' /etc/ssh/sshd_config.d/50-redhat.conf

# As the container isn't normally running systemd, /run/nologin needs to be removed to allow SSH
RUN rm -rf /run/nologin

# Install the replacement systemctl command
RUN dnf -y install python3
COPY vagrant/files/docker/systemctl3.py /usr/bin/systemctl
RUN chmod 755 /usr/bin/systemctl

# Tools specific to our normal environment
RUN dnf -y install php \
  php-intl \
  php-soap \ 
  php-mysqlnd \
  php-zipstream \
  httpd \
  nodejs
RUN npm i -g npm

# Setup of httpd / php-hpm
COPY vagrant/files/docker/httpd.default.conf /etc/httpd/conf/httpd.conf
RUN mkdir -p /etc/httpd/sites-available
RUN mkdir -p /etc/httpd/sites-enabled
COPY vagrant/files/docker/php-fpm-www-override.conf /etc/php-fpm.d/z-www-override.conf
RUN systemctl enable httpd
RUN systemctl enable php-fpm

RUN printf "# composer php cli ini settings\n\
date.timezone=UTC\n\
memory_limit=-1\n\
" > $PHP_INI_DIR/php-cli.ini

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 2.2.9
ENV COMPOSER_INSTALLER_URL https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer
ENV COMPOSER_INSTALLER_HASH 48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5

RUN set -eux; \
  curl --silent --fail --location --retry 3 --output /tmp/installer.php --url ${COMPOSER_INSTALLER_URL}; \
  php -r " \
    \$signature = '${COMPOSER_INSTALLER_HASH}'; \
    \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
      unlink('/tmp/installer.php'); \
      echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
      exit(1); \
    }"; \
  php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION}; \
  composer --ansi --version --no-interaction; \
  rm -f /tmp/installer.php; \
  find /tmp -type d -exec chmod -v 1777 {} +

# install phpunit
RUN wget https://phar.phpunit.de/phpunit-9.5.phar && \
    chmod +x phpunit-9.5.phar && \
    mv phpunit-9.5.phar /usr/local/bin/phpunit

CMD /usr/bin/systemctl
