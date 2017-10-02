#!/bin/bash

psql postgres://postgres:111@172.17.0.2:5432/postgres -q <<EOF
drop database if exists alpha;
drop database if exists beta;

drop role if exists anonymous;
drop role if exists staff;
drop role if exists authenticator;
drop role if exists board;

create role anonymous;
create role staff;
create role authenticator with login password 'changeme' noinherit in role anonymous, staff;
create role board         with login password 'changeme' noinherit;

comment on role anonymous     is 'No authentication is provided';
comment on role staff         is 'Staff';
comment on role authenticator is 'Intermediate to become anonymous or an user';
comment on role board         is 'Database owner';

create database alpha owner board;
create database beta  owner board;
EOF

for database in alpha beta; do
psql postgres://postgres:111@172.17.0.2:5432/$database -q <<EOF
create extension "uuid-ossp";
create extension "pgcrypto";
create extension "pgjwt";
create extension "pgtap";
alter database $database set board.jwt_secret to 'board secret minimum 32 characters'
EOF
done
