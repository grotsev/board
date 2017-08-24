#!/bin/bash

mkdir -p db/build/

main_model='
  lib/extension/pgjwt
  lib/domain/code
  lib/domain/textarea
  lib/domain/textfield
  lib/domain/uuid_pk
  main/table/staff
  main/table/voting
  main/table/option
  main/table/vote
  main/type/jwt_token
  main/function/*
'

main_data='
'

test_model='
  test/function/*
  test/test/*
'

test_data='
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

