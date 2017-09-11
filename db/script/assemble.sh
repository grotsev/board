#!/bin/bash

mkdir -p db/build/

live_model='
  lib/extension/pgjwt
  lib/domain/code
  lib/domain/textarea
  lib/domain/textfield
  lib/domain/uuid_pk
  lib/table/i18n
  live/table/staff
  live/table/voting
  live/table/option
  live/table/vote
  live/type/jwt_token
  live/function/*
'

live_data='
  live/data/i18n
'

dev_model='
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

