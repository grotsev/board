FROM postgres:9.6
MAINTAINER Denis Grotsev

COPY pgjwt /tmp/pgjwt
RUN apt-get update
RUN apt-get install -y \
            postgresql-server-dev-9.6 \
            python-pip \
      && pip install pgxnclient \
      && pgxn install pgTAP \
      && pgxn install temporal_tables \
      && cd /tmp/pgjwt && make install \
      && apt-get autoremove -y \
            python-pip \
            postgresql-server-dev-9.6 \
      && rm -rf /var/lib/apt/lists/*
