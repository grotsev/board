create table attr
( attr name not null

, primary key (attr)
);

-- not in relation scope
comment on table attr is
  'Attribute in global scope';
