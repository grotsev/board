create domain uuid_pk as uuid
  default uuid_generate_v1mc();

comment on domain uuid_pk is
  'Primary key aware mostly sequential time based uuid';
