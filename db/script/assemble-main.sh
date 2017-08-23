#!/bin/bash

mkdir -p build/

main_model='lib/domain/code
  lib/domain/textarea
  lib/domain/textfield
  lib/domain/uuid_pk
  main/table/staff
  main/table/voting
  main/table/voter
  main/table/option
  main/table/vote
'

out=db/build/main-model.sql
rm -f $out
for f in $main_model
do
  cat db/$f.sql >> $out
  echo $'\n\n' >> $out
done
