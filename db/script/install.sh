#!/bin/bash

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
  db/script/clean.sh alpha && \
  in_mode alpha live && \
  in_mode alpha dev
elif [ "$1" == "beta" ]; then
  db/script/clean.sh beta && \
  liquibase \
      --url=jdbc:postgresql://172.17.0.2:5432/beta \
      --username=board \
      --password=changeme \
      --changeLogFile=db/release/changelog.xml \
      update && \
  in_mode beta dev
else
  echo "Unknown database as first argument"
fi
