#!/bin/bash

db/script/assemble-$1.sh && \
psql postgres://postgres:111@172.17.0.2:5432/postgres -q1 --file db/$1/init.sql && \
psql postgres://board:changeme@172.17.0.2:5432/postgres -q1 --file db/build/$1-model.sql && \
psql postgres://board:changeme@172.17.0.2:5432/postgres -q1 --file db/build/$1-data.sql
