#!/bin/bash

mkdir -p db/build/release

if [[ $# -eq 0 ]]; then
  release_name=`date +%g%V`-`git rev-parse --abbrev-ref HEAD`.sql
else
  release_name=`date +%g%V`-$1.sql
fi

out=db/build/release/$release_name
liquibase \
        --url=jdbc:postgresql://172.17.0.2:5432/postgres \
        --username=owner \
        --password=changeme \
    diff \
        --referenceUrl=jdbc:postgresql://172.17.0.2:5432/postgres \
        --referenceUsername=owner \
        --referencePassword=changeme

out=db/build/release/function.sql
rm -f $out
echo '--liquibase formatted sql'$'\n' >> $out
for f in db/live/function/*
do
  echo '--changeset auto:'$(basename $f .sql)' splitStatements:false runOnChange:true'$'\n' >> $out
  cat $f >> $out
  echo $'\n' >> $out
done

