# 
# Copyright (C) 2016 - Ferndale-Hall (pg_gsl@ferndale-hall.co.uk)
#
# This file is part of pg_gsl.
#
# pg_gsl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# pg_gsl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with pg_gsl.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Script to run the example
# The default database name is "pg_gsl_db
#

PG_GSL_DB="${PG_GSL_DB:-pg_gsl_db}"

#
# Create the functions necessary for running the example
#

psql $PG_GSL_DB -f fftExample1a.sql > fftExample1.op 2>&1

#
# Run the example sql
#

psql -t $PG_GSL_DB -f fftExample1b.sql 2>>fftExample1.op | sed -n -e '/|/p' | sed -e 's/[{} ]//g' | sed -e 's/|/,/' > fftExample1b.csv

sed -e '/^#/d' -e '/^$/d' -e '/^Time/d' fftExample1.expected > fftExample1.expected.tmp
sed -e '/^#/d' -e '/^$/d' -e '/^Time/d' fftExample1.op > fftExample1.op.tmp

diff fftExample1.op.tmp fftExample1.expected.tmp

if [ $? -eq 0 ]
then
	echo "Example 1 part 1 passed"
else
	echo "Example 1 part 1 failed"
fi

rm fftExample1.expected.tmp fftExample1.op.tmp fftExample1.op

sed -e '/^#/d' -e '/^$/d' -e '/^Time/d' fftExample1b.expected.csv > fftExample1b.expected.tmp

diff fftExample1b.csv fftExample1b.expected.tmp
if [ $? -eq 0 ]
then
	echo "Example 1 part 2 passed, output in `pwd`/fftExample1b.csv"
else
	echo "Example 1 part 2 failed"
fi

rm fftExample1b.expected.tmp

exit 0

