# Ubuntu 24.04 LTS (Noble Numbat)
FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    NODE_ENV=production \
    TERM=xterm-256color \
    # Keeps Python from generating .pyc files in the container
    PYTHONDONTWRITEBYTECODE=1 \
    # Turns off buffering for easier container logging
    PYTHONUNBUFFERED=1

RUN apt-get update -y && \
    apt-get upgrade -y && \
    # Install required packages to add an apt repository key
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg2 \
        wget && \
    # Add the Odoo nightly repository key
    wget -q -O - https://nightly.odoo.com/odoo.key | gpg --dearmor > /usr/share/keyrings/odoo-nightly.gpg && \
    # Add the Odoo nightly repository
    echo 'deb [signed-by=/usr/share/keyrings/odoo-nightly.gpg] http://nightly.odoo.com/deb/jammy ./' \
        > /etc/apt/sources.list.d/odoo-nightly.list && \
    # Fetch Google Chrome (for web tour tests)
    wget -q --show-progres --progress=bar:force:noscroll -O chrome.deb \
    https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_123.0.6312.58-1_amd64.deb && \
    # Continue install after fetching debs
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        # Install useful tools
        build-essential \
        curl \
        gettext \
        nano \
        postgresql-client \
        sudo \
        vim \
        # Install Python dependencies for Odoo
        pylint \
        python3-aiosmtpd \
        python3-asn1crypto \
        python3-astroid \
        python3-babel \
        python3-cbor2 \
        python3-dateutil \
        python3-dbfread \
        python3-decorator \
        python3-dev \
        python3-docopt \
        python3-docutils \
        python3-feedparser \
        python3-fonttools \
        python3-freezegun \
        python3-geoip2 \
        python3-gevent \
        python3-html2text \
        python3-jinja2 \
        python3-jwt \
        python3-libsass \
        python3-lxml \
        python3-lxml-html-clean \
        python3-mako \
        python3-markdown \
        python3-matplotlib \
        python3-mock \
        python3-num2words \
        python3-ofxparse \
        python3-openid \
        python3-openssl \
        python3-passlib \
        python3-pdfminer \
        python3-phonenumbers \
        python3-pil \
        python3-polib \
        python3-psutil \
        python3-psycogreen \
        python3-psycopg2 \
        python3-pydot \
        python3-pyldap \
        python3-pyparsing \
        python3-pypdf2 \
        python3-qrcode \
        python3-renderpm \
        python3-reportlab \
        python3-requests \
        python3-rjsmin \
        python3-setproctitle \
        python3-simplejson \
        python3-slugify \
        python3-stdnum \
        python3-suds \
        python3-tz \
        python3-unittest2 \
        python3-vobject \
        python3-websocket \
        python3-werkzeug \
        python3-xlrd \
        python3-xlsxwriter \
        python3-xlwt \
        python3-xmlsec \
        python3-zeep \
        # Install Python dependencies for the documentation
        python3-pygments \
        python3-sphinx \
        python3-sphinx-tabs \
        # Set python3 by default
        python-is-python3 \
        # Install pip, to install python dependencies not packaged by Ubuntu
        python3-pip \
        # Install lessc
        node-less \
        # Install npm, to install node dependencies not packaged by Ubuntu
        npm \
        # Install wkhtmltopf
        wkhtmltox \
        # Install fonts
        fonts-freefont-ttf \
        fonts-khmeros-core \
        fonts-noto-cjk \
        fonts-ocr-b \
        fonts-vlgothic \
        gsfonts \
        # Install Google Chrome
        ./chrome.deb

# Cleanup
RUN rm -rf ./chrome.deb /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Node dependencies
RUN npm install -g \
        # Install dependencies for Odoo
        rtlcss@2.5.0 \
        # Install dependencies to check/lint code
        es-check@6.0.0 \
        eslint@8.1.0 \
        eslint-config-prettier@8.5.0 \
        eslint-plugin-prettier@4.2.1 \
        prettier@2.7.1

# Remove the default Ubuntu user, add an Odoo user and set up his environment
RUN --mount=type=bind,source=starship.bashrc,target=/tmp/starship.bashrc \
    userdel ubuntu && \
    groupadd -g 1000 odoo && \
    useradd --create-home -u 1000 -g odoo -G audio,video odoo && \
    passwd -d odoo && \
    echo odoo ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/odoo && \
    chmod 0440 /etc/sudoers.d/odoo && \
    # Create the working directory and make it owned by the Odoo user
    mkdir /code && \
    chown odoo /code && \
    # Configure the Bash shell using Starship
    curl -sS https://starship.rs/install.sh | sh -s -- --yes && \
    cat /tmp/starship.bashrc >> /home/odoo/.bashrc

# Install the following dependencies using the "odoo" user
USER odoo

# Install Python dependencies via pip for packages not available via apt
RUN pip install --no-cache-dir --break-system-packages \
        # Install Odoo dependencies
        ebaysdk \
        firebase-admin==2.17.0 \
        inotify \
        pdf417gen \
        # Install documentation dependencies
        pygments-csv-lexer~=0.1 \ 
        sphinxcontrib-applehelp==1.0.4 \
        sphinxcontrib-devhelp==1.0.2 \
        sphinxcontrib-htmlhelp==2.0.1 \
        sphinxcontrib-serializinghtml==1.1.5 \
        sphinxcontrib-qthelp==1.0.3 \
        # Install debug tools
        debugpy

WORKDIR /code

# Expose useful ports
EXPOSE 5678 8069 8071 8072 8073

CMD [ "bash" ]