CC=gcc
LD=ld
AR=ar
SYSROOT = 
LIB_TYPE = solib


INC_DIR= -I. -I.. -I./include -I./src/libmp3lame -I./src/mpglib -I./src/config


DEFINES = -DHAVE_CONFIG_H

CFLAGS += -g -O3 -ffast-math -funroll-loops -Wall -pipe -Wno-unused-but-set-variable
CFLAGS += --sysroot=$(SYSROOT)
ifeq ($(LIB_TYPE), solib)
	CFLAGS += -fPIC
endif


MSG_COMPILING = Compiling libmp3lame:
MSG_AR = Generate lib:

ifeq ($(LIB_TYPE), solib)
	LIB_TARGET=solib
	LIB_NAME = libmp3lame.so
else
	LIB_TARGET=lib
	LIB_NAME = libmp3lame.a
endif

OUTDIR = out
SRCDIR_liblame = ./src/libmp3lame
SRCDIR_vecotr = ./src/libmp3lame/vector
SRCDIR_mpglib = ./src/mpglib
SRCS += $(wildcard $(SRCDIR_liblame)/*.c) \
		$(wildcard $(SRCDIR_vecotr)/*.c) \
		$(wildcard $(SRCDIR_mpglib)/*.c) 
				
OBJS := $(SRCS:.c=.o)

SRCDIR_exec += ./example
SRCS_exec += $(wildcard $(SRCDIR_exec)/*.c)

EXECS := $(basename $(SRCS_exec))

all: show $(LIB_TARGET) example
	@echo "Building has finished."


#for debug
show:
	@echo CC=$(CC)
	@echo CFLAGS=$(CFLAGS)
	@echo The generated lib will be $(LIB_NAME)

clean:
	-rm -f $(OBJS)
	-rm -f $(EXECS)
	-rm -rf $(SRCDIR_exec)/*.dSYM
	-rm -f ./out/*


solib: $(OBJS)
	@echo $(MSG_AR) $(OUTDIR)/$(LIB_NAME)
	@mkdir -p $(OUTDIR)
	@$(LD) -shared -o $(OUTDIR)/$(LIB_NAME) $^
	
	
lib: $(OBJS)
	@echo $(MSG_AR) $(OUTDIR)/$(LIB_NAME)
	@mkdir -p $(OUTDIR)
	@$(AR) rcs $(OUTDIR)/$(LIB_NAME) $^


%.o: %.c
	@echo $(MSG_COMPILING) $<
	@$(CC) -c $(DEFINES) $(CFLAGS) $(INC_DIR) $< -o $@


example: $(EXECS)

%: %.c $(LIB_TARGET)
	@echo "Building excecuteble file : " $<
	@$(CC) $(DEFINES) $(CFLAGS) $(INC_DIR) $< -o $@ -L$(OUTDIR) -lmp3lame -lm


	
