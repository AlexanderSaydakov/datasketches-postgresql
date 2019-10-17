EXTENSION = datasketches
EXTVERSION = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
MODULE_big = datasketches

SQL_MODULES = sql/datasketches_cpc_sketch.sql sql/datasketches_kll_float_sketch.sql sql/datasketches_theta_sketch.sql sql/datasketches_frequent_strings_sketch.sql sql/datasketches_hll_sketch.sql
SQL_INSTALL = sql/$(EXTENSION)--$(EXTVERSION).sql
DATA = $(SQL_INSTALL)

EXTRA_CLEAN = $(SQL_INSTALL)

OBJS = src/global_hooks.o src/base64.o src/common.o \
  src/kll_float_sketch_pg_functions.o src/kll_float_sketch_c_adapter.o \
  src/cpc_sketch_pg_functions.o src/cpc_sketch_c_adapter.o \
  src/theta_sketch_pg_functions.o src/theta_sketch_c_adapter.o \
  src/frequent_strings_sketch_pg_functions.o src/frequent_strings_sketch_c_adapter.o \
  src/hll_sketch_pg_functions.o src/hll_sketch_c_adapter.o

# assume a copy or link datasketches-cpp in the current dir
CORE = datasketches-cpp

CPC = $(CORE)/cpc/src
OBJS += $(CPC)/cpc_sketch.o $(CPC)/fm85.o $(CPC)/fm85Compression.o $(CPC)/fm85Confidence.o $(CPC)/fm85Merging.o $(CPC)/fm85Util.o $(CPC)/iconEstimator.o $(CPC)/u32Table.o

PG_CPPFLAGS = -fPIC -I/usr/local/include -I$(CORE)/kll/include -I$(CORE)/common/include -I$(CORE)/cpc/include -I$(CORE)/theta/include -I$(CORE)/fi/include -I$(CORE)/hll/include
PG_CXXFLAGS = -std=c++11
SHLIB_LINK = -lstdc++ -L/usr/local/lib

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

# generate combined sql
$(SQL_INSTALL): $(sort $(SQL_MODULES))
	cat $^ > $@

install: $(SQL_INSTALL)
