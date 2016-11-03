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

EXTENSION    = pg_gsl
EXTVERSION   = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\\([^']*\\)'/\\1/")

DATA         = $(filter-out $(wildcard sql/*--*.sql),$(wildcard sql/*.sql))
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test
MODULES      = $(patsubst %.c,%,$(wildcard src/*.c))
PG_CONFIG    = pg_config
PG91         = $(shell $(PG_CONFIG) --version | grep -qE " 8\\.| 9\\.0" && echo no || echo yes)
PKGLIBDIR    = $(shell $(PG_CONFIG) --pkglibdir)

override CFLAGS +="-DPG_GSL_VERSION=\"0.0.1\""

ifeq ($(PG91),yes)
all: sql/$(EXTENSION)--$(EXTVERSION).sql

sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
	cp $< $@

src/pg_gsl.so:	src/pg_gsl.o src/cpalloc.o
	gcc -Xlinker -rpath=$(PKGLIBDIR) -shared -o src/$(EXTENSION).so src/cpalloc.o src/pg_gsl.o $(PKGLIBDIR)/libgsl.so -lgslcblas

DATA = $(wildcard sql/*--*.sql) sql/$(EXTENSION)--$(EXTVERSION).sql
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

pg_gsl_test:
	-(cd test ; sh ./fftTest.sh)

pg_gsl_example:
	-(cd test ; ./fftExample1.sh)

pg_gsl_plots:
	-(cd test ; ./fftExample1GenPlots.sh)


