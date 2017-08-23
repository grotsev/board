create table voter
( voting uuid not null
, staff  uuid not null

primary key (voting, staff)
foreign key (voting) references voting
foreign key (staff)  references staff
);

comment on table voter is
  'Участник голосования';
