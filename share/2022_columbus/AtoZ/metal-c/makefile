#===========
#Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
#Broadcom Inc. corporate affiliate that distributes this software.
#===========
# makefile boilerplate to build the JNI implementation (C++), metal C code, and

CXX=xlc++
CC=xlc
ASM=as

MTL_OPTS=metal,\
 langlvl(extended),\
 sscom,\
 nolongname,\
 inline,\
 genasm,\
 inlrpt,\
 csect,\
 nose,\
 lp64,\
 list,\
 warn64,\
 optimize(2),\
 list,\
 showinc,\
 showmacro,\
 source,\
 aggregate

MTL_FLAGS=-S -W "c,$(MTL_OPTS)"

MACLIBS=-ISYS1.MACLIB \
 -ICBC.SCCNSAM

MTL_HEADERS=-I/usr/include/metal

JAVA_HOME := /usr/lpp/java/J8.0_64

DLL_CPP_FLAGS=-W "c,lp64,langlvl(extended),dll,xplink,exportall"\
 -qsearch=$(JAVA_HOME)/include \
 -qsource \
 -g \
 -c

DLL_BND_FLAGS=-W "l,lp64,dll,dynam=dll,xplink,map,list" \
 -g \
 -qsource

ASM_FLAGS=-mrent

SIDEDECKPATH = $(JAVA_HOME)/bin/j9vm
SIDEDECK = libjvm

PREFIX := "../lib/"

all: libemailserv.so

install:
	mkdir -p $(PREFIX)
	cp -vp *.so $(PREFIX)
	extattr +p $(PREFIX)/*.so
	ls -E $(PREFIX)

libemailserv.so: ZosEmail.o MtlcMail.o
	$(CXX) $(DLL_BND_FLAGS) -o $@ $^ > $*.bind.lst
	extattr +p $@

ZosEmail.o: ZosEmail.cpp
	$(CXX) $(DLL_CPP_FLAGS) -qlist=$*.cpp.lst -o $@ $^

MtlcMail.o: MtlcMail.s
	$(ASM) $(ASM_FLAGS) -a=$*.asm.lst $(MACLIBS) -o $@ $^

MtlcMail.s: MtlcMail.c
	$(CC) $(MTL_FLAGS) -qlist=$*.mtl.lst $(MTL_HEADERS) -o $@ $^

clean:
	rm *.o
	rm *.lst
	rm *.x
	rm *.so
	rm *.dbg
