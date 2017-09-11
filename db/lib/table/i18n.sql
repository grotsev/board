create table i18n
( i18n code not null check (i18n ~ '^[a-z]{3}$')

, primary key (i18n)
);

comment on table i18n is
  'Supported internationalization language, ISO 639-2';
