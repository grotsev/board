create function macro_elm_field(
  i18n code
) returns text
  language plpgsql
  stable
as $function$
declare
begin

  return format(
$macro$module Field exposing (..)

%1$s
$macro$
  , ( select string_agg(line, E'\n'::text)
      from (
        select format(
$macro$
%1$s : Field
%1$s =
    { id = """%1$s"""
    , title = """%2$s"""
    , help = %3$s
    }
$macro$
          , attr
          , title
          , case when help is null then 'Nothing' else format('Just """%1$s"""', help) end
          ) as line
        from i18n_attr_title t
          left join i18n_attr_help h using (i18n, attr)
        where t.i18n = macro_elm_field.i18n
        order by attr
      ) l
    )
  );

end;
$function$;

comment on function macro_elm_field(code) is
  'Macro elm field module';
