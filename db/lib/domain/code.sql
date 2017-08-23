create domain code as text
  check (value ~ '^[_a-z][_a-z0-9]{0,29}$');

comment on domain code is
  'Domain specific constant like enum strictly formatted for wide use';
