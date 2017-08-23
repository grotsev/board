create domain textarea as text
  check (char_length(value) <= 2000);

comment on domain textarea is
  'Reasonably large user input but securely bounded';
