############################################################
##   MGRID library compilation

LDIR := MGRID

####### Files

# Library
MGRID_LIB = $(PRJLIB)/libt_mgrid.a

# Modules
MGRID_MOD = BASEFIELD.$(MOD)    \
            DEFFIELD.$(MOD)     \
            GENFIELD.$(MOD)     \
            LIMITER.$(MOD)      \
            MATFREE.$(MOD)      \
            MGRID.$(MOD)

# Objects
MGRID_OBJ = $(MGRID_MOD:.$(MOD)=.o)      \
            calcboco_connect.o           \
            calcboco_connect_match.o     \
            calcboco_connect_per_match.o \
            calcboco_ust.o               \
            calcboco_ust_extrapol.o      \
            calcboco_ust_sym.o           \
            calc_gradient.o            \
            calc_gradient_limite.o     \
            convert_to_svm.o           \
            convert_to_svm_cub.o       \
            convert_to_svm_4wang.o     \
            convert_to_svm_4kris.o     \
            raffin_iso_tri.o           \
            distrib_field.o            \
            extractpart_grid.o         \
            getpart_grid.o             \
            gmres_free.o               \
            integ_ustboco.o            \
            postlimit_monotonic.o      \
            postlimit_barth.o          \
            prb_grid_vol.o             \
            precalc_grad_lsq.o
            #minmax_limiter.o

D_MGRID_OBJ = $(MGRID_OBJ:%=$(PRJOBJ)/%)

D_MGRID_SRC := $(MGRID_OBJ:%.o=$(LDIR)/%.f90)


####### Build rules

all: $(MGRID_LIB)

$(MGRID_LIB): $(D_MGRID_OBJ)
	@echo ---------------------------------------------------------------
	@echo \* Compiling library $(MGRID_LIB)
	@rm -f $(MGRID_LIB)
	@$(AR) ruv $(MGRID_LIB) $(D_MGRID_OBJ)
	@echo \* Creating library index
	@$(RAN)    $(MGRID_LIB)
	@echo ---------------------------------------------------------------
	@echo \* LIBRARY $(MGRID_LIB) created
	@echo ---------------------------------------------------------------

MGRID_clean:
	-rm $(MGRID_LIB) $(D_MGRID_OBJ) $(MGRID_MOD) MGRID/depends.make


####### Dependencies

MGRID/depends.make: $(D_MGRID_SRC)
	(cd MGRID ; ../$(MAKEDEPENDS))

include MGRID/depends.make


