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
  * these should fail because of NULL in the array
  *
  */

select pg_gsl_fft_real_transform('{0, NULL, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0}'::integer[]);
select pg_gsl_fft_halfcomplex_inverse('{0, NULL, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0}'::integer[]);
