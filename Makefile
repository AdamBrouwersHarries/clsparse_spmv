# Compiler
CC = g++

# Universal C flags
CFLAGS = -std=c++11 -O3 -g -Wall 

# Get the host and shell, to determine include directories and link options
HOST = $(shell hostname)
UNAME = $(shell uname)
CDIR = $(shell pwd)
# CLSPARSE_V = 0.8.0.0
CLSPARSE_V = 0.10.2.0
CLSPARSE_DIR = 
CLSPARSE_PDIR = 

# Test the hostname against a list of known hosts to determine where skelcl is installed
ifeq ($(HOST),arsibalt)
	CLSPARSE_PDIR += /Users/Adam/Development
	CLSPARSE_DIR += /Users/Adam/Development/clSPARSE_lib
endif
ifeq ($(HOST),$(filter $(HOST),bob monza suzuka))
	CLSPARSE_PDIR += /home/s1467120
	CLSPARSE_DIR += /home/s1467120/clSPARSE_lib
endif
ifeq ($(HOST),$(filter $(HOST), charles01.inf.ed.ac.uk charles02.inf.ed.ac.uk charles03.inf.ed.ac.uk charles04.inf.ed.ac.uk charles05.inf.ed.ac.uk charles06.inf.ed.ac.uk charles07.inf.ed.ac.uk charles08.inf.ed.ac.uk charles09.inf.ed.ac.uk charles10.inf.ed.ac.uk ))
	CLSPARSE_PDIR += /disk/scratch/s1467120
	CLSPARSE_DIR += /disk/scratch/s1467120/clSPARSE_lib
endif
ifeq ($(HOST),nemunas)
	CLSPARSE_PDIR += /home/adam/Development
	CLSPARSE_DIR += /home/adam/Development/clSPARSE_lib
endif

# Based on the clSPARSE root directory, define the include directories
CLSPARSE_INCLUDE = $(CLSPARSE_DIR)/include/

# Add the include directories to a single variable, which we can pass to $(CC)
INCLUDE = -I$(CLSPARSE_INCLUDE) -I$(CDIR)

# Determine the extra linker directories for SkelCL
CLSPARSE_LIBDIR = $(CLSPARSE_DIR)/lib64/

# Define a single general linker string for $(CC)
LINK = -L$(CLSPARSE_LIBDIR) -lm

# Add more to the linker string, depending on the platform (Darwin = OSX, Linux = Linux)
ifeq ($(UNAME),Darwin)
	LINK += -lc++ -framework OpenCL
endif
ifeq ($(UNAME),Linux)
	LINK += -lOpenCL
endif

LINK += -lclSPARSE

# General rule to trigger the others, depend on the makefile so that everything recompiles when the makefile changes
all: Makefile spmv.cpp spmv_vectorised.cpp spmv_adaptive.cpp $(CLSPARSE_DIR)
	$(CC) spmv.cpp $(INCLUDE) $(CFLAGS) $(LINK) -o spmv
	$(CC) spmv_vectorised.cpp $(INCLUDE) $(CFLAGS) $(LINK) -o spmv_v
	$(CC) spmv_adaptive.cpp $(INCLUDE) $(CFLAGS) $(LINK) -o spmv_a

# Clean by simply deleting the $(OBJ) and $(BIN) directories
clean: 
	rm -rf spmv
	rm -rf *.tar.gz

$(CLSPARSE_DIR): clSPARSE-$(CLSPARSE_V)-Linux-x64.tar.gz
	tar -xzf clSPARSE-$(CLSPARSE_V)-Linux-x64.tar.gz
	mv clSPARSE-$(CLSPARSE_V)-Linux-x64 clSPARSE_lib
	mv clSPARSE_lib $(CLSPARSE_PDIR)/clSPARSE_lib

clSPARSE-$(CLSPARSE_V)-Linux-x64.tar.gz: 
	wget https://github.com/clMathLibraries/clSPARSE/releases/download/v$(CLSPARSE_V)/clSPARSE-$(CLSPARSE_V)-Linux-x64.tar.gz
