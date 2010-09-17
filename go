#!/bin/bash
./mksql.pl pi.yaml drop > sql && ./inserter.pl books.yaml >> sql && /usr/local/pgsql/bin/psql -qe pi < sql 
