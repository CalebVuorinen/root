# Module.mk for cfitsio module
# Copyright (c) 2010 Rene Brun and Fons Rademakers
#
# Author: Claudi Martinez, 24/07/2010

MODNAME      := fitsio
MODDIR       := $(ROOT_SRCDIR)/graf2d/$(MODNAME)
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

FITSIODIR    := $(MODDIR)
FITSIODIRS   := $(FITSIODIR)/src
FITSIODIRI   := $(FITSIODIR)/inc

##### libFITSIO #####
FITSIOL      := $(MODDIRI)/LinkDef.h
FITSIODS     := $(call stripsrc,$(MODDIRS)/G__FITSIO.cxx)
FITSIODO     := $(FITSIODS:.cxx=.o)
FITSIODH     := $(FITSIODS:.cxx=.h)

FITSIOH      := $(filter-out $(MODDIRI)/LinkDef%,$(wildcard $(MODDIRI)/*.h))
FITSIOS      := $(filter-out $(MODDIRS)/G__%,$(wildcard $(MODDIRS)/*.cxx))
FITSIOO      := $(call stripsrc,$(FITSIOS:.cxx=.o))

FITSIODEP    := $(FITSIOO:.o=.d) $(FITSIODO:.o=.d)

FITSIOLIB    := $(LPATH)/libFITSIO.$(SOEXT)
FITSIOMAP    := $(FITSIOLIB:.$(SOEXT)=.rootmap)

# used in the main Makefile
ALLHDRS       += $(patsubst $(MODDIRI)/%.h,include/%.h,$(FITSIOH))
ALLLIBS       += $(FITSIOLIB)
ALLMAPS       += $(FITSIOMAP)

# include all dependency files
INCLUDEFILES += $(FITSIODEP)

##### local rules #####
.PHONY:         all-$(MODNAME) clean-$(MODNAME) distclean-$(MODNAME)

include/%.h:    $(FITSIODIRI)/%.h
		cp $< $@

$(FITSIOLIB):   $(FITSIOO) $(FITSIODO) $(ORDER_) $(MAINLIBS) $(FITSIOLIBDEP)
		@$(MAKELIB) $(PLATFORM) $(LD) "$(LDFLAGS)" \
		   "$(SOFLAGS)" libFITSIO.$(SOEXT) $@ "$(FITSIOO) $(FITSIODO)" \
		   "$(FITSIOLIBEXTRA) $(CFITSIOLIBDIR) $(CFITSIOLIB)"

$(call pcmrule,FITSIO)
	$(noop)

$(FITSIODS):    $(FITSIOH) $(FITSIOL) $(ROOTCLINGEXE) $(call pcmdep,FITSIO)
		$(MAKEDIR)
		@echo "Generating dictionary $@..."
		$(ROOTCLINGSTAGE2) -f $@ $(call dictModule,FITSIO) -c -writeEmptyRootPCM $(FITSIOH) $(FITSIOL)

$(FITSIOMAP):   $(FITSIOH) $(FITSIOL) $(ROOTCLINGEXE) $(call pcmdep,FITSIO)
		$(MAKEDIR)
		@echo "Generating rootmap $@..."
		$(ROOTCLINGSTAGE2) -r $(FITSIODS) $(call dictModule,FITSIO) -c $(FITSIOH) $(FITSIOL)

all-$(MODNAME): $(FITSIOLIB)

clean-$(MODNAME):
		@rm -f $(FITSIOO) $(FITSIODO)

clean::         clean-$(MODNAME)

distclean-$(MODNAME): clean-$(MODNAME)
		@rm -f $(FITSIODEP) $(FITSIODS) $(FITSIODH) $(FITSIOLIB) $(FITSIOMAP)

distclean::     distclean-$(MODNAME)

##### extra rules ######
$(FITSIOO) $(FITSDO): CXXFLAGS += $(CFITSIOINCDIR:%=-I%)
