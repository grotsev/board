create type auth as
( staff        uuid
, role         name
, exp          int4
, surname textfield
, name    textfield
, token        text
);
