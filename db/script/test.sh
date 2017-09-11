#!/bin/bash

db/script/clean.sh && \
db/script/install.sh live && \
db/script/install.sh dev && \
if [[ $# -eq 0 ]]; then
  echo "TAP version 13" && \
  psql postgres://authenticator:changeme@172.17.0.2:5432/postgres --tuples-only -c "select runtests()"
else
  psql postgres://authenticator:changeme@172.17.0.2:5432/postgres --tuples-only -c "set client_min_messages to info; select runtests('^$1$')"
fi
