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

/*
 * Output arrays, each select must reset the seed to the same value
 * so that it gives the same results in each run
 *
 */
 
 /* Output a cosine array[100] with a period of 10, offset of 0 and amplitue of 1 */
 
select setseed(0);
select 'signal', cosArray(100, 10, 0)::decimal(7,5)[];

/* Output an array[100] of random numbers with range [-2.5, +2.5] */
 
select setseed(0);
select 'noise', (5 * noiseArray(100))::decimal(7,5)[];

/* Output the sum of the previous 2 arrays */

select setseed(0);
select 'signal+noise', (cosArray(100, 10, 0) + 5 * noiseArray(100))::decimal(7,5)[];

/* Run the fft transform of this noise + signal and output as a normalised spectrum */

select setseed(0);
select 'spectrum', pg_gsl_x_fftToSpectrum((pg_gsl_fft_real_transform(cosArray(100, 10, 0) + 5 *noiseArray(100))))::decimal(7,5)[];

/* Set the high frequency part of the transform to 0.0 and output as a spectrum */

select setseed(0);
select 'truncatedspectrum50', pg_gsl_x_fftToSpectrum(pg_gsl_x_fftTruncate(pg_gsl_fft_real_transform(cosArray(100, 10, 0) + 5 * noiseArray(100)), 50))::decimal(7,5)[];

/* Set the high frequency part of the transform to 0.0 and output as a spectrum */

select setseed(0);
select 'truncatedspectrum75', pg_gsl_x_fftToSpectrum(pg_gsl_x_fftTruncate(pg_gsl_fft_real_transform(cosArray(100, 10, 0) + 5 * noiseArray(100)), 75))::decimal(7,5)[];

/* Run the inverse transform on the truncated fft transform spectrum */

select setseed(0);
select 'filtered50', pg_gsl_fft_halfcomplex_inverse(pg_gsl_x_fftTruncate(pg_gsl_fft_real_transform(cosArray(100, 10, 0) + 5 * noiseArray(100)), 50))::decimal(7,5)[];

/* Run the inverse transform on the truncated fft transform spectrum */

select setseed(0);
select 'filtered75', pg_gsl_fft_halfcomplex_inverse(pg_gsl_x_fftTruncate(pg_gsl_fft_real_transform(cosArray(100, 10, 0) + 5 * noiseArray(100)), 75))::decimal(7,5)[];


