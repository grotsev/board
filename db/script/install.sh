#!/bin/bash

function clean {
  psql postgres://postgres:111@172.17.0.2:5432/$1 -q <<EOF
set client_min_messages to warning;
drop schema if exists dev cascade;
drop schema if exists live cascade;
drop owned by board cascade;
EOF
}

function in_mode {
  if [ "$1" == "live" ]; then
    p='live, public'
  else
    p='dev, live, public'
  fi
  db/script/assemble.sh $2 && \
  psql postgres://postgres:111@172.17.0.2:5432/$1 -q -c "alter database $1 set search_path to $p;" && \
  psql postgres://board:changeme@172.17.0.2:5432/$1 -q1 --file db/build/$2-model.sql && \
  psql postgres://board:changeme@172.17.0.2:5432/$1 -q1 --file db/build/$2-data.sql
}

if [ "$1" == "alpha" ]; then
  clean alpha && \
  in_mode alpha live && \
  in_mode alpha dev
elif [ "$1" == "beta" ]; then
  clean beta && \
  in_mode beta live && \
  in_mode beta dev
else
  echo "Unknown argument"
fi
