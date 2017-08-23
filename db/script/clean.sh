#!/bin/bash

psql postgres://postgres:111@172.17.0.2:5432/postgres -q1 --file db/test/clean.sql
