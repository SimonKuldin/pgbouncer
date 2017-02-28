FROM ubuntu:trusty
MAINTAINER dammian.miller@gmail.com
WORKDIR /opt/pgbouncer
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres
# grab gosu for easy step-down from root
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres
# install gosu
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates wget
#
# install pgbouncer: https://github.com/pgbouncer/pgbouncer
#
RUN apt-get update && apt-get install -y --fix-missing unzip wget make cmake gcc autoconf autogen intltool libevent-dev automake git libtool libc-ares2 libc-ares-dev libssl-dev pkg-config libpython2.7 python2.7 python2.7-dev python2.7-minimal python-support python-docutils
RUN mkdir -p /opt/pgbouncer
RUN git clone https://github.com/pgbouncer/pgbouncer.git && cd pgbouncer && git submodule init && git submodule update && ./autogen.sh && ./configure --prefix=/opt/pgbouncer --with-libevent=libevent-prefix && make && make install
RUN echo '"postgres" "postgres"' > /opt/pgbouncer/users.txt
COPY config.ini /opt/pgbouncer/config.ini
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
RUN chown -R postgres /opt/pgbouncer
EXPOSE 6432
ENTRYPOINT ["/docker-entrypoint.sh"]
