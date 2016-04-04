FROM ubuntu:trusty
MAINTAINER winsent <pipetc@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install packages http://wiki.openstreetmap.org/wiki/Nominatim/Installation#Ubuntu.2FDebian
RUN apt-get -y update --fix-missing && \
    apt-get install -y build-essential libxml2-dev libpq-dev libbz2-dev libtool automake \
    libproj-dev libboost-dev libboost-system-dev libboost-filesystem-dev \
    libboost-thread-dev libexpat-dev gcc proj-bin libgeos-c1 libgeos++-dev \
    libexpat-dev php5 php-pear php5-pgsql php5-json php-db libapache2-mod-php5 \
    postgresql postgis postgresql-contrib postgresql-9.3-postgis-2.1 \
    postgresql-server-dev-9.3 curl git autoconf-archive cmake python \
    lua5.1 liblua5.1-dev libluabind-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.3/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
EXPOSE 5432

# Install nominatim
RUN git clone --recursive git://github.com/twain47/Nominatim.git ./src && \
    cmake ./src && make

# Nominatim config file
COPY local.php ./settings/local.php
RUN rm -rf /var/www/html/* && ./utils/setup.php --create-website /var/www/html
# Apache site config
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf
EXPOSE 8080

# Load initial data
ENV PBF_DATA http://download.geofabrik.de/europe/monaco-latest.osm.pbf
RUN curl $PBF_DATA --create-dirs -o /app/src/data.osm.pbf
RUN service postgresql start && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
    sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
    useradd -m -p password1234 nominatim && \
    sudo -u nominatim ./utils/setup.php --osm-file /app/src/data.osm.pbf --all --threads 2 && \
    service postgresql stop

COPY start.sh /app/start.sh
CMD /app/start.sh