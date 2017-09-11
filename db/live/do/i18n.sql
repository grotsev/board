do $block$
begin
  execute (
    select string_agg(macro_i18n(table_name), E'\n'::text)
    from (values
      ('rel')
    , ('attr')
    ) t(table_name)
  );
end;
$block$;
