############################################################
##   Compilation de la librairie EQNS

LDIR := EQNS

####### Files

EQNS_LIB = $(PRJLIB)/libt_eqns.a

EQNS_MOD = EQNS.$(MOD)      \
           LIMITER.$(MOD)   \
           MENU_NS.$(MOD)


EQNS_OBJ := $(EQNS_MOD:.$(MOD)=.o)    \
            calc_flux_hlle.o          \
            calc_flux_hllc.o          \
            calc_flux_viscous.o       \
            calc_ns_timestep.o        \
            calc_roe_states.o         \
            calc_varcons_ns.o         \
            calc_varprim_ns.o         \
	    calc_visc_suther.o        \
            calcboco_ns.o             \
            def_boco_ns.o             \
            def_init_ns.o             \
            def_model_ns.o            \
            hres_ns_muscl.o           \
            init_boco_ns.o            \
            init_ns_ust.o             \
            integration_ns_ust.o      \
            setboco_ns_flux.o         \
            setboco_ns_inlet_sub.o    \
            setboco_ns_inlet_sup.o    \
            setboco_ns_isoth.o        \
            setboco_ns_outlet_sub.o   \
            setboco_ns_outlet_sup.o

D_EQNS_OBJ := $(EQNS_OBJ:%=$(PRJOBJ)/%)

D_EQNS_SRC := $(EQNS_OBJ:%.o=$(LDIR)/%.f90)


####### Build rules

all: $(EQNS_LIB)

$(EQNS_LIB): $(D_EQNS_OBJ)
	@echo ---------------------------------------------------------------
	@echo \* Cr�ation de la librairie $(EQNS_LIB)
	@touch $(EQNS_LIB) ; rm $(EQNS_LIB)
	@$(AR) ruv $(EQNS_LIB) $(D_EQNS_OBJ)
	@echo \* Cr�ation de l\'index de la librairie
	@$(RAN)    $(EQNS_LIB)
	@echo ---------------------------------------------------------------
	@echo \* LIBRAIRIE $(EQNS_LIB) cr��e
	@echo ---------------------------------------------------------------

EQNS_clean:
	-rm  $(EQNS_LIB) $(D_EQNS_OBJ) $(EQNS_MOD)


####### Dependencies


EQNS/depends.make: $(D_EQNS_SRC)
	(cd EQNS ; ../$(MAKEDEPENDS))

include EQNS/depends.make





