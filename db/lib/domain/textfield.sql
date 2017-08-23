create domain textfield as text
  check (char_length(value) <= 100);

comment on domain textfield is
  'Reasonably large user input but securely bounded';
