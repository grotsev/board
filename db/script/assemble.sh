#!/bin/bash

mkdir -p db/build/

live_model='
  lib/extension/pgjwt
  lib/domain/code
  lib/domain/textarea
  lib/domain/textfield
  lib/domain/uuid_pk
  lib/table/i18n
  lib/table/rel
  lib/table/attr
  lib/table/i18n_rel_title
  lib/table/i18n_rel_help
  lib/table/i18n_attr_title
  lib/table/i18n_attr_help
  live/table/staff
  live/table/voting
  live/table/option
  live/table/vote
  live/type/jwt_token
  live/function/*
  live/grant/*
'

live_data='
  live/data/i18n
  live/data/rel
  live/data/attr
  live/data/i18n_rel_title-eng
  live/data/i18n_rel_title-rus
  live/data/i18n_rel_help-eng
  live/data/i18n_rel_help-rus
  live/data/i18n_attr_title-eng
  live/data/i18n_attr_title-rus
  live/data/i18n_attr_help-eng
  live/data/i18n_attr_help-rus
'

dev_model='
  lib/macro/macro_elm_field
  dev/function/*
  dev/test/*
'

dev_data='
'

for md in model data
do
  out=db/build/$1-$md.sql
  rm -f $out
  touch $out
  ref=$1_${md}
  for f in ${!ref}
  do
    cat db/$f.sql >> $out
    echo $'\n\n' >> $out
  done
done

