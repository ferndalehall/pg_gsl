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

#include "postgres.h"
#include "fmgr.h"
#include "pg_gsl.h"

#include "catalog/pg_type.h"
#include "utils/geo_decls.h"
#include "utils/array.h"
#include "utils/lsyscache.h"

#include <math.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_fft_real.h>
#include <gsl/gsl_fft_halfcomplex.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/*
 * Function to return the version of this postresql extension
 */

PG_FUNCTION_INFO_V1(pg_x_gsl_version);
Datum pg_x_gsl_version(PG_FUNCTION_ARGS);

Datum
pg_x_gsl_version(PG_FUNCTION_ARGS)
{
	int32 newSize;
    text *newText;
	newSize = strlen(PG_GSL_VERSION) + VARHDRSZ;
	newText = (text *) palloc(newSize);

    SET_VARSIZE(newText, newSize);
	memcpy(VARDATA(newText), PG_GSL_VERSION, strlen(PG_GSL_VERSION));

	PG_RETURN_TEXT_P(newText);
}

/*
 * Wrapper to call the GSL fft_real_transform() function
 */

Datum pg_gsl_fft_real_transform(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pg_gsl_fft_real_transform);
Datum pg_gsl_fft_real_transform(PG_FUNCTION_ARGS) {
	ArrayType *input;
	Datum *i_data;
	bool *nulls;
	ArrayType *result;
	Datum *result_data;
	int ndims, *dims, *lbs;
	Oid i_eltype, o_eltype = FLOAT8OID;;
	int16 i_typlen, o_typlen;
	bool i_typbyval, o_typbyval;
	char i_typalign, o_typalign;
	int i, n;
	double *data;

	/* Declare the GSL workspaces */
	gsl_fft_real_wavetable *real;
	gsl_fft_real_workspace *work;

	/* return null on null input */
	if (PG_ARGISNULL(0)) {
		PG_RETURN_NULL();
	}

	/* get input args */
	input = PG_GETARG_ARRAYTYPE_P(0);

	/* get input array element type */
	i_eltype = ARR_ELEMTYPE(input);
	get_typlenbyvalalign(i_eltype, &i_typlen, &i_typbyval, &i_typalign);

	/* validate input data type */
	if (i_eltype != FLOAT8OID) {
		elog(ERROR, "Invalid input data type");
	}

	/* Get the details of the input parameter */
	get_typlenbyvalalign(o_eltype, &o_typlen, &o_typbyval, &o_typalign);

	/* get various pieces of data from the input array */
	ndims = ARR_NDIM(input);
	dims = ARR_DIMS(input);
	lbs = ARR_LBOUND(input);

	/* get src data */
	deconstruct_array(input, i_eltype, i_typlen, i_typbyval, i_typalign,
			&i_data, &nulls, &n);

	/* Get the input data, nulls not allowed */
	data = (double *)palloc(n * sizeof(double));
	for (i = 0; i < n; i++) {
		if (nulls[i]) {
			elog(ERROR, "NULLs not allowed in the input array");
			PG_RETURN_NULL();
		}
			data[i] = DatumGetFloat8(i_data[i]);
	}

	/* Allocate the GSL workspaces */
	work = gsl_fft_real_workspace_alloc(n);
	real = gsl_fft_real_wavetable_alloc(n);

	/* Call the GSL function */
	gsl_fft_real_transform(data, 1, n, real, work);

	/* construct result array */
	result_data = (Datum *) palloc(n * sizeof(Datum));

	/* Put data into return array */
	for (i = 0; i < n; i++) {
		result_data[i] = Float8GetDatum((float8) data[i]);
	}

	/* Construct the return values */
	result = construct_md_array((void *) result_data, nulls, ndims, dims, lbs,
			o_eltype, o_typlen, o_typbyval, o_typalign);

	/* Free the GSL workspaces */
	gsl_fft_real_workspace_free(work);
	gsl_fft_real_wavetable_free(real);

	/* Free the postgresql arrays */
	pfree(i_data);
	pfree(result_data);
	pfree(nulls);
	pfree(data);

	PG_RETURN_ARRAYTYPE_P(result);
}

/*
 * Wrapper to call the GSL fft_halfcomplex_inverse() function
 */

Datum pg_gsl_fft_halfcomplex_inverse(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pg_gsl_fft_halfcomplex_inverse);

Datum pg_gsl_fft_halfcomplex_inverse(PG_FUNCTION_ARGS) {
	ArrayType *input;
	Datum *i_data;
	bool *nulls;
	ArrayType *result;
	Datum *result_data;
	int ndims, *dims, *lbs;
	Oid i_eltype, o_eltype = FLOAT8OID;;
	int16 i_typlen, o_typlen;
	bool i_typbyval, o_typbyval;
	char i_typalign, o_typalign;
	int i, n;
	double *data;

	/* Declare the GSL workspaces */
	gsl_fft_halfcomplex_wavetable *hc;
	gsl_fft_real_workspace *work;

	/* return null on null input */
	if (PG_ARGISNULL(0)) {
		PG_RETURN_NULL();
	}

	/* get input args */
	input = PG_GETARG_ARRAYTYPE_P(0);

	/* get input array element type */
	i_eltype = ARR_ELEMTYPE(input);
	get_typlenbyvalalign(i_eltype, &i_typlen, &i_typbyval, &i_typalign);

	/* validate input data type */
	if (i_eltype != FLOAT8OID) {
		elog(ERROR, "Invalid input data type");
	}

	get_typlenbyvalalign(o_eltype, &o_typlen, &o_typbyval, &o_typalign);

	/* get various pieces of data from the input array */
	ndims = ARR_NDIM(input);
	dims = ARR_DIMS(input);
	lbs = ARR_LBOUND(input);

	/* get src data */
	deconstruct_array(input, i_eltype, i_typlen, i_typbyval, i_typalign,
			&i_data, &nulls, &n);

	/* Get the input data, nulls not allowed */
	data = (double *)palloc(n * sizeof(double));
	for (i = 0; i < n; i++) {
		if (nulls[i]) {
			elog(ERROR, "NULLs not allowed in the input array");
			PG_RETURN_NULL();
		}
		data[i] = DatumGetFloat8(i_data[i]);
	}

	/* Allocate the GSL workspaces */
	work = gsl_fft_real_workspace_alloc(n);
	hc = gsl_fft_halfcomplex_wavetable_alloc(n);

	/* Call the GSL function */
	gsl_fft_halfcomplex_inverse(data, 1, n, hc, work);

	/* construct result array */
	result_data = (Datum *) palloc(n * sizeof(Datum));

	/* Put data into return array */
	for (i = 0; i < n; i++) {
		result_data[i] = Float8GetDatum((float8) data[i]);
	}

	/* Construct the return values */
	result = construct_md_array((void *) result_data, nulls, ndims, dims, lbs,
			o_eltype, o_typlen, o_typbyval, o_typalign);

	/* Free the GSL workspaces */
	gsl_fft_halfcomplex_wavetable_free(hc);
	gsl_fft_real_workspace_free(work);

	/* Free the postgresql arrays */
	pfree(i_data);
	pfree(result_data);
	pfree(nulls);
	pfree(data);

	PG_RETURN_ARRAYTYPE_P(result);
}




