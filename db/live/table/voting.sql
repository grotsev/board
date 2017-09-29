create table voting
( voting       uuid_pk not null
, title      textfield not null
, description textarea
, period     tstzrange

, primary key (voting)
);

comment on table voting is
  'Голосование';
comment on column voting.title is
  'Название';
comment on column voting.period is
  'Время начала и окончания, если нет, то голосование не активно';
