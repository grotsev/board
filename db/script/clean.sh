#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "database as first argument is required"
fi

psql postgres://postgres:111@172.17.0.2:5432/$1 -q <<EOF
set client_min_messages to warning;
drop schema if exists dev cascade;
drop schema if exists live cascade;
drop owned by board cascade;
EOF
