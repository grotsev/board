create table i18n_attr_help
( i18n code not null
, attr name not null
, help text not null

, primary key (i18n, attr)
, foreign key (i18n) references i18n
, foreign key (attr) references attr
);

comment on table i18n_attr_help is
  'Relation help translation';
