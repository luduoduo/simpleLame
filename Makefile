CC=gcc
AR=ar
SYSROOT = 

INC_DIR= -I. -I.. -I./include -I./src/libmp3lame -I./src/mpglib -I./src/config


DEFINES = -DHAVE_CONFIG_H

CFLAGS += -g -O3 -ffast-math -funroll-loops -Wall -pipe -Wno-unused-but-set-variable
CFLAGS += --sysroot=$(SYSROOT)

#-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk \
-mmacosx-version-min=10.7 

MSG_COMPILING = Compiling libmp3lame:
MSG_AR = Ar lib:

OUTDIR = out
LIB_NAME = libmp3lame.a
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

all: show lib example
	@echo "Building has finished."

#for debug
show:
	@echo CC=$(CC)
	@echo CFLAGS=$(CFLAGS)

clean:
	-rm -f $(OBJS)
	-rm -f $(EXECS)
	-rm -rf $(SRCDIR_exec)/*.dSYM
	-rm -f ./out/*

	
lib: $(OBJS)
	@echo $(MSG_AR) $(OUTDIR)/$(LIB_NAME)
	@mkdir -p $(OUTDIR)
	@$(AR) rcs $(OUTDIR)/$(LIB_NAME) $^

%.o: %.c
	@echo $(MSG_COMPILING) $<
	@$(CC) -c $(DEFINES) $(CFLAGS) $(INC_DIR) $< -o $@


example: $(EXECS)

%: %.c lib
	@echo "Building excecuteble file : " $<
	@$(CC) $(DEFINES) $(CFLAGS) $(INC_DIR) $< -o $@ -L$(OUTDIR) -lmp3lame -lm


	
