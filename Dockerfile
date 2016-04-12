FROM ubuntu:trusty

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


EXPOSE 5432
EXPOSE 8080
