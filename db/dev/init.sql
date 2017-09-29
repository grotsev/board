set client_min_messages to warning;
set plpgsql.extra_warnings to 'all';

create schema dev;

grant usage on schema live to public;
grant usage on schema dev  to public;
grant board to authenticator;
