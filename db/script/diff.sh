#!/bin/bash

liquibase --defaultsFile="etc/liquibase.properties" diff --schemas=live | grep -v ': NONE'
