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
# Script to run the example and put the results into a csv file
# The default database name is "pg_gsl_db
#

PG_GSL_DB="${PG_GSL_DB:-pg_gsl_db}"

for test in 1 2 3 4
do
	psql $PG_GSL_DB -f fftTest${test}.sql > fftTest${test}.op 2>&1
	sed -e '/^#/d' -e '/^$/d' -e '/^Time/d' fftTest${test}.expected > fftTest${test}.expected.tmp
	sed -e '/^#/d' -e '/^$/d' -e '/^Time/d' fftTest${test}.op > fftTest${test}.op.tmp
	diff fftTest${test}.op.tmp fftTest${test}.expected.tmp
	if [ $? -eq 0 ]
	then
		echo "Test ${test} passed"
	else
		echo "Test ${test} failed"
	fi
	rm fftTest${test}.expected.tmp fftTest${test}.op.tmp fftTest${test}.op
done

exit 0
