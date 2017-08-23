create table vote
( voting uuid not null
, staff  uuid not null
, option uuid not null

, primary key (voting, staff, option)
, foreign key (voting, staff)  references voter
, foreign key (voting, option) references option
);

comment on table vote is
  'Голос';
