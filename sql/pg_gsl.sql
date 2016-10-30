/* pg_gsl
 * 
 * Copyright (C) 2016 - Ferndale-Hall - All Rights Reserved
 * You may use, distribute and modify this code under the
 * terms of the MIT license.
 *
 * You should have received a copy of the MIT license with
 * this file. If not, please email pgxn@ferndale-hall.co.uk
 */

/* 
 * SQL to create the pg_sql sql functions
 *
 */

CREATE OR REPLACE FUNCTION pg_x_gsl_version()
RETURNS text
AS 'pg_gsl','pg_x_gsl_version'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pg_gsl_fft_real_transform(double precision[])
RETURNS double precision[]
AS 'pg_gsl','pg_gsl_fft_real_transform'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pg_gsl_fft_halfcomplex_inverse(double precision[])
RETURNS double precision[]
AS 'pg_gsl','pg_gsl_fft_halfcomplex_inverse'
LANGUAGE C IMMUTABLE STRICT;

/*
 * Function to transform pg_gsl_fft_real_transform() return into
 * normalised spectrum
 *
 */
 
create or replace function pg_gsl_x_fftToSpectrum(ip double precision[]) returns double precision[] as $$
Declare
        retArray double precision[];
        n integer;
Begin
        n := array_length(ip, 1);
        retArray := array_fill(0.0, ARRAY[n/2]);
        for i in 1..n/2 loop
                retArray[i] := (sqrt(ip[2 * i - 1] * ip[2* i - 1] + ip[2 * i] * ip[2 * i])) / (n/2);
        end loop;
        return retArray;
end;
$$ language plpgsql;

/*
 * Function to truncate (fill with zeros) the pg_gsl_fft_real_transform()
 * output, equivalent to filtering out the higher frequencies.
 *
 */

create or replace function pg_gsl_x_fftTruncate(a double precision[], n integer) returns double precision[] as $$
Declare
        retArray double precision[];
        len integer;
Begin
        retArray := a;
        len := array_length(a, 1);
        for i in (len-n + 1)..len  loop
                retArray[i] := 0.0;
        end loop;
        return retArray;
end;
$$ language plpgsql;



