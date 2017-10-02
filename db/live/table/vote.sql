create table vote
( voting uuid not null
, option uuid not null
, staff  uuid not null

, primary key (voting, option, staff)
, foreign key (voting, option) references option
, foreign key (staff)          references staff
);

comment on table vote is
  'Голос';
