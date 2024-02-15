
DC?=ldc2
#LIB_DFILES=$(shell find arsd-webassembly -name "*.d" -printf "DFILES+=%p\n")
ifndef DFILES
include dfiles.mk
else
dfiles.mk:
endif

DFLAGS+=-i=.
DFLAGS+=--d-version=CarelessAlocation
DFLAGS+=-i=std
DFLAGS+=-Iarsd-webassembly/
DFLAGS+=-L-allow-undefined
DFLAGS+=-ofserver/omg.wasm
DFLAGS+=-mtriple=wasm32-unknown-unknown-wasm 
#cmd /c "ldc2 
#-i=. 
#--d-version=CarelessAlocation 
#-i=std -Iarsd-webassembly/ 
#-L-allow-undefined -ofserver/omg.wasm 
#-mtriple=wasm32-unknown-unknown-wasm 
#DFLAGS+=arsd-webassembly/core/arsd/aa arsd-webassembly/core/arsd/objectutils 
#DFLAGS+=arsd-webassembly/core/internal/utf 
#DFLAGS+=arsd-webassembly/core/arsd/utf_decoding 
DFLAGS+=hello 
#DFLAGS+=arsd-webassembly/object.d
#DFLAGS:=-i=. --d-version=CarelessAlocation -i=std -Iarsd-webassembly/ -L-allow-undefined -ofserver/omg.wasm -mtriple=wasm32-unknown-unknown-wasm arsd-webassembly/core/arsd/aa arsd-webassembly/core/arsd/objectutils arsd-webassembly/core/internal/utf arsd-webassembly/core/arsd/utf_decoding hello arsd-webassembly/object.d
all:
	$(DC) $(DFLAGS) $(DFILES)

dfiles.mk:
	find arsd-webassembly -name "*.d" -printf "DFILES+=%p\n" > $@

#cmd /c "ldc2 -i=. --d-version=CarelessAlocation -i=std -Iarsd-webassembly/ -L-allow-undefined -ofserver/omg.wasm -mtriple=wasm32-unknown-unknown-wasm arsd-webassembly/core/arsd/aa arsd-webassembly/core/arsd/objectutils arsd-webassembly/core/internal/utf arsd-webassembly/core/arsd/utf_decoding hello arsd-webassembly/object.d"
