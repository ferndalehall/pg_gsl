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

 /* SQL functions used by later examples */
 
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

/* to create a cosine array with given length, period and offset */

create or replace function cosArray(n integer, period integer, off integer) returns double precision[] as $$
Declare
	retArray double precision[];
	pi double precision:= 3.1415926535 ;
Begin
	retArray := array_fill(0.0, ARRAY[n]);
	for i in 1..n  loop
		retArray[i] := cos((i - 1 + off) * 2 * pi / period);
	end loop;
	return retArray;
end;
$$ language plpgsql;

/* To add 2 arrays */

create or replace function addArray(a double precision[], b double precision[]) returns double precision[] as $$
Declare
	retArray double precision[];
	n integer;
Begin
	n := array_length(a, 1);
	retArray := array_fill(0.0, ARRAY[n]);
	for i in 1..n  loop
		retArray[i] := a[i] + b[i];
	end loop;
	return retArray;
end;
$$ language plpgsql;

/* To create the "+" operator to add 2 real arrays */

drop OPERATOR + (double precision[],
    double precision[]
);
CREATE OPERATOR + (
    LEFTARG = double precision[],
    RIGHTARG =double precision[],
    PROCEDURE = addArray
);

/* To create a function to multiply each value in an array by a scalar */

create or replace function timesArray(a double precision, b double precision[]) returns double precision[] as $$
Declare
	retArray double precision[];
	n integer;
Begin
	n := array_length(b, 1);
	retArray := array_fill(0.0, ARRAY[n]);
	for i in 1..n  loop
		retArray[i] := a * b[i];
	end loop;
	return retArray;
end;
$$ language plpgsql;

/* To create the "*" operator to multiply an array by a scalar */

drop OPERATOR * (double precision,
    double precision[]
);
CREATE OPERATOR * (
    LEFTARG = double precision,
    RIGHTARG =double precision[],
    PROCEDURE = timesArray
);
