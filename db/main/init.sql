create role anonymous;
create role authenticator with login password 'changeme' in role anonymous noinherit;
create role board         with login password 'changeme' noinherit;
create role staff;

comment on role anonymous     is 'No authentication is provided';
comment on role authenticator is 'Intermediate to become anonymous or an user';
comment on role board         is 'Schema owner';
comment on role staff         is 'Staff';

create schema authorization board;
set schema 'board';

-- temporary become superuser to create owned extensions
alter role board with superuser;
set local role board;
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";
reset role;
alter role board with nosuperuser;

alter default privileges for role board revoke execute on functions from public;

--grant usage on schema board to public; -- TODO remove or uncomment

alter database postgres set search_path to board;

alter database postgres set board.jwt_secret to 'board'
