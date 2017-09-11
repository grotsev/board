#!/bin/bash

outdir=db/build/elm
mkdir -p $outdir

psql postgres://postgres:111@172.17.0.2:5432/postgres -qAtX -c "select macro_elm_field('rus')" > $outdir/Field.elm
