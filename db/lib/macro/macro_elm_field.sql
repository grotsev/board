create function macro_elm_field(
  i18n code
) returns text
  language plpgsql
  stable
as $function$
declare
begin

  return format(
$macro$
module Field exposing (..)

%1$s
$macro$
  , ( select string_agg(line, E'\n'::text)
      from (
        select format(
$macro$
%1$s : Field
%1$s =
    { id = """%1$s"""
    , title = """"""
    , help =
    }
$macro$
          , attr
          , case when row_number() over ()=count(*) over () then ';' else ',' end
          ) as line
        from attr
        order by attr
      ) l
    )
  );

end;
$function$;

comment on function macro_elm_field(code) is
  'Macro elm field module';
