CFLAGS = -Wall -O3 -funroll-loops -I/usr/include
OCAMLFIND = ocamlfind
OCAMLC = $(OCAMLFIND) ocamlc -safe-string
OCAMLOPT = $(OCAMLFIND) ocamlopt -safe-string
OCAMLMKLIB = $(OCAMLFIND) ocamlmklib

# on unix architecture we just use the default value
EXE=
OBJ=o
A=a
SO=so

# on windows architecture redefine some values
ifeq "$(shell ocamlc -config | fgrep 'os_type:')" "os_type: Win32"
	EXE=.exe
	SO=dll
ifeq "$(shell ocamlc -config | fgrep 'ccomp_type:')" "ccomp_type: msvc"
	OBJ=obj
	A=lib
endif
endif

PROGRAMS_BINS = sha1sum sha256sum sha512sum
PROGRAMS = $(addsuffix $(EXE), $(PROGRAMS_BINS))

allclibs = $(foreach n, 1 256 512, sha$(n).lib.$(OBJ) sha$(n)_stubs.$(OBJ))

allbytes = hash.cmo $(allclibs)
allopts  = hash.cmx $(allclibs)

all: hash.cmi hash.cma hash.cmxa

bins: $(PROGRAMS)

hash_test: hash.cma hash_test.ml
	$(OCAMLC) -o $@ -custom -linkpkg -package oUnit -cclib -L. hash.cma hash_test.ml

sha1sum$(EXE): hash.cma cksum.ml
	$(OCAMLC) -o $@ -custom -cclib -L. hash.cma cksum.ml

sha256sum$(EXE): sha1sum$(EXE)
	ln -f $< $@

sha512sum$(EXE): sha1sum$(EXE)
	ln -f $< $@

hash.cma: $(allbytes)
	$(OCAMLMKLIB) -o hash $(allbytes)

hash.cmxa: $(allopts)
	$(OCAMLMKLIB) -o hash $(allopts)

tests: hash_test
	./hash_test

%.cmo: %.ml %.cmi
	$(OCAMLC) -c -o $@ $<

%.cmi: %.mli
	$(OCAMLC) -c -o $@ $<

%.cmx: %.ml
	$(OCAMLOPT) -c -o $@ $<

%.$(OBJ): %.c
	$(OCAMLC) -ccopt "$(CFLAGS)" -c -o $@ $<

%.lib.$(OBJ): %.$(OBJ)
	mv $< $@

.PHONY: clean install uninstall doc
doc:
	[ -d html ] && rm -f html/* || mkdir html
	ocamldoc -html -d html *.mli

clean:
	rm -f *.$(OBJ) *.$(A) *.$(SO) *.cmo *.cmi *.cma *.cmx *.cmxa *.cmt *.cmti hash_test $(PROGRAMS)

install: hash.cma hash.cmxa META
	ocamlfind install sha META hash.cm* *.$(A) *.$(SO)

uninstall:
	ocamlfind remove sha
