set client_min_messages to warning;

drop schema if exists board_test cascade;
drop schema if exists board cascade;
drop owned by board cascade;

drop role if exists authenticator;
drop role if exists anonymous;
drop role if exists board;
drop role if exists staff;
