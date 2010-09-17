#!/bin/bash
./mksql.pl pi.yaml drop > sql && /usr/local/pgsql/bin/psql -qe pi < sql 
