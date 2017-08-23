set client_min_messages to warning;
set plpgsql.extra_warnings to 'all';

create schema board_test authorization board;

create extension if not exists "pgtap" schema board_test;

alter database postgres set search_path to board_test, board;

grant usage on schema board_test to public;
grant usage on schema board to public;
grant execute on all functions in schema board_test to public;
grant board to authenticator;
