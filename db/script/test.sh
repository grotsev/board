#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "alpha or beta argument is required"
fi

db/script/install.sh $1
if [[ -z $2 ]]; then
  echo "TAP version 13" && \
  psql postgres://authenticator:changeme@172.17.0.2:5432/$1 --tuples-only -c "select runtests()"
else
  psql postgres://authenticator:changeme@172.17.0.2:5432/$1 --tuples-only -c "set client_min_messages to info; select runtests('^$2$')"
fi
