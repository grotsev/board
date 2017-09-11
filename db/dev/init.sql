set client_min_messages to warning;
set plpgsql.extra_warnings to 'all';

create schema board_test authorization board;
alter database postgres set search_path to board_test, board;

-- temporary become superuser to create owned extensions
alter role board with superuser;
set local role board;
create extension if not exists "pgtap" schema board_test;
reset role;
alter role board with nosuperuser;

grant usage on schema board_test to public;
grant usage on schema board to public;
grant board to authenticator;
