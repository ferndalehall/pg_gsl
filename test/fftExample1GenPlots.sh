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
# Script to generate svg plots from the data output from fft1Example
# These plots are used in the documentation
# 

for name in signal noise signal+noise filtered50 filtered75
do
	awk -v name=$name -F "," '
	{
		if ( $1 == name )
		{
			for(i=2;i<=NF;i++)printf("%d %s\n", i-2, $i);
		}
	} ' fftExample1b.csv > $$.$name.data


	(cat <<!
set title ""
set xlabel ""
set ylabel ""
set zlabel ""
unset logscale x
unset logscale y
unset logscale z
set term svg size 300,240
set xtics  20
plot [:] [-5.0:5.0] [:] '$$.$name.data' using 1:2  with lines     title "$name "
!
) | gnuplot > ${name}.svg
done

for name in spectrum truncatedspectrum50 truncatedspectrum75
do
	awk -v name=$name -F "," '
	{
		if ( $1 == name )
		{
			for(i=2;i<=NF;i++)printf("%d %s\n", i-2, $i);
		}
	} ' fftExample1b.csv > $$.$name.data


	(cat <<!
set title ""
set xlabel ""
set ylabel ""
set zlabel ""
unset logscale x
unset logscale y
unset logscale z
set term svg size 300,240
set xtics  10
plot [:] [0.0:1.0] [:] '$$.$name.data' using 1:2  with lines     title "$name "
!
) | gnuplot > ${name}.svg
done

(
cat <<!
set title ""
set xlabel ""
set ylabel ""
set zlabel ""
unset logscale x
unset logscale y
unset logscale z
set term svg size 300,240
set xtics  20
plot [:] [-5.0:5.0] [:] '$$.signal.data' using 1:2  with lines     title "signal " , '$$.filtered75.data' using 1:2  with lines  lc rgb '#fde725'   title "reconstructed "
!
) | gnuplot > signal+filtered75.svg

rm $$.*.data

