/* 
 * Copyright (C) 2016 - Ferndale-Hall (pg_gsl@ferndale-hall.co.uk)
 *
 * This file is part of pg_gsl.
 *
 * pg_gsl is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * pg_gsl is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with pg_gsl.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/* to create an array on randon numbers in the range [-0.5, 0.5] */
 
create or replace function noiseArray(n integer) returns double precision[] as $$
Declare
	retArray double precision[];
Begin
	retArray := array_fill(0.0, ARRAY[n]);
	for i in 1..n loop
		retArray[i] := random() - 0.5;
	end loop;
	return retArray;
end;
$$ language plpgsql;

\timing
select setseed(0);
select (noiseArray(100))::decimal(7,5)[];
select (noiseArray(100))::decimal(7,5)[];
select (noiseArray(1000))::decimal(7,5)[];
select (noiseArray(10000))::decimal(7,5)[];
select pg_gsl_x_fftToSpectrum(noiseArray(100))::decimal(7,5)[];
select pg_gsl_x_fftToSpectrum(noiseArray(1000))::decimal(7,5)[];
select pg_gsl_x_fftToSpectrum(noiseArray(10000))::decimal(7,5)[];

