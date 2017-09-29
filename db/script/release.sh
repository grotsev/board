#!/bin/bash

if [[ $# -eq 0 ]]; then
  release_name=`date +%g%V`-`git rev-parse --abbrev-ref HEAD`
else
  release_name=`date +%g%V`-$1
fi

out=db/release/function.sql
rm -f $out
echo '--liquibase formatted sql'$'\n' >> $out
for f in db/live/function/*
do
  echo '--changeset auto:'$(basename $f .sql)' splitStatements:false runOnChange:true'$'\n' >> $out
  cat $f >> $out
  echo $'\n' >> $out
done

touch db/release/$release_name.sql

echo "    Check"
echo db/release/function.sql
echo db/release/$release_name.sql