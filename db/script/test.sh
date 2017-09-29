#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "database as first argument is required"
fi

db/script/install.sh $1
if [[ -z $2 ]]; then
  echo "TAP version 13" && \
  psql postgres://authenticator:changeme@172.17.0.2:5432/$1 --tuples-only -q <<EOF
select runtests();
EOF
else
  psql postgres://authenticator:changeme@172.17.0.2:5432/$1 --tuples-only -q <<EOF
set client_min_messages to info;
select no_plan();
select $2();
select * from finish();
EOF
fi
