create table i18n_attr_title
( i18n  code not null
, attr  name not null
, title text not null

, primary key (i18n, attr)
, foreign key (i18n) references i18n
, foreign key (attr) references attr
);

comment on table i18n_attr_title is
  'Attribute title translation';
