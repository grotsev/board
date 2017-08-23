set client_min_messages to warning;
set plpgsql.extra_warnings to 'all';

create schema board_test authorization board;

create extension if not exists "pgtap" schema board_test;

alter database postgres set search_path to board_test, board;

alter default privileges for role board in schema board_test grant execute on functions to public;
grant usage on schema board_test to public;
grant usage on schema board to public;
grant board to authenticator;
