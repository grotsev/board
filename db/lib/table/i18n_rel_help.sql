create table i18n_rel_help
( i18n code not null
, rel  name not null
, help text not null

, primary key (i18n, rel)
, foreign key (i18n) references i18n
, foreign key (rel)  references rel
);

comment on table i18n_rel_help is
  'Relation help translation';
