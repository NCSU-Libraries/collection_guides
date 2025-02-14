#!/bin/sh

COLUMN_STATISTICS_FLAG=""

# set mac-specific vars
if test "$(uname)" = "Darwin"; then
  COLUMN_STATISTICS_FLAG="--column-statistics=0"
fi

mkdir -p tmp/dbdata

# get a database dump and put it in tmp/dbdata if not available

if test -f tmp/dbdata/collection_guides_db.sql; then
  echo "-- Found Collection Guides staging dump, skipping --"
else
  echo "-- Dumping Collection Guides staging database to tmp/dbdata/collection_guides_db.sql. Enter staging db password. --"
  mysqldump ${COLUMN_STATISTICS_FLAG} -h mysqlstagingcl.lib.ncsu.edu -u collectionguides -p collection_guides_staging > tmp/dbdata/collection_guides_db.sql
fi

cp config/database.yml.docker config/database.yml
# cp config/application.yml.docker config/application.yml
cp config/initializers/devise.rb.docker config/initializers/devise.rb
cp config/initializers/resque.rb.docker config/initializers/resque.rb 

${CONTAINER_COMMAND:-docker} build --ssh=default --no-cache -t collection_guides .
