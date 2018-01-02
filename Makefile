CFLAGS = -Wall -O3 -funroll-loops -fPIC -DPIC
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLMKLIB = ocamlmklib

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

OCAMLOPTFLAGS =

OCAML_TEST_INC = -I `ocamlfind query oUnit`
OCAML_TEST_LIB = `ocamlfind query oUnit`/oUnit.cmxa

PROGRAMS_BINS = sha1sum sha256sum sha512sum
PROGRAMS = $(addsuffix $(EXE), $(PROGRAMS_BINS))

allshabytes = $(foreach n, 1 256 512, sha$(n).lib.$(OBJ) sha$(n)_stubs.$(OBJ) sha$(n).cmo)
allshaopts  = $(foreach n, 1 256 512, sha$(n).lib.$(OBJ) sha$(n)_stubs.$(OBJ) sha$(n).cmx)

all: sha1.cmi sha1.cma sha1.cmxa sha256.cma sha256.cmxa sha512.cma sha512.cmxa sha.cma sha.cmxa

bins: $(PROGRAMS)

sha1sum$(EXE): sha1.cmxa sha256.cmxa sha512.cmxa shasum.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ -cclib -L. $+

sha256sum$(EXE): sha1sum$(EXE)
	cp $< $@

sha512sum$(EXE): sha1sum$(EXE)
	cp $< $@

sha.cma: $(allshabytes)
	$(OCAMLMKLIB) -o sha $(allshabytes)

sha.cmxa: $(allshaopts)
	$(OCAMLMKLIB) -o sha $(allshaopts)

sha1.cma: sha1.cmi sha1.lib.$(OBJ) sha1_stubs.$(OBJ) sha1.cmo
	$(OCAMLMKLIB) -o sha1 sha1.lib.$(OBJ) sha1_stubs.$(OBJ) sha1.cmo

sha1.cmxa: sha1.cmi sha1.lib.$(OBJ) sha1_stubs.$(OBJ) sha1.cmx
	$(OCAMLMKLIB) -o sha1 sha1.lib.$(OBJ) sha1_stubs.$(OBJ) sha1.cmx

sha256.cma: sha256.cmi sha256.lib.$(OBJ) sha256_stubs.$(OBJ) sha256.cmo
	$(OCAMLMKLIB) -o sha256 sha256.lib.$(OBJ) sha256_stubs.$(OBJ) sha256.cmo

sha256.cmxa: sha256.cmi sha256.lib.$(OBJ) sha256_stubs.$(OBJ) sha256.cmx
	$(OCAMLMKLIB) -o sha256 sha256.lib.$(OBJ) sha256_stubs.$(OBJ) sha256.cmx

sha512.cma: sha512.cmi sha512.lib.$(OBJ) sha512_stubs.$(OBJ) sha512.cmo
	$(OCAMLMKLIB) -o sha512 sha512.lib.$(OBJ) sha512_stubs.$(OBJ) sha512.cmo

sha512.cmxa: sha512.cmi sha512.lib.$(OBJ) sha512_stubs.$(OBJ) sha512.cmx
	$(OCAMLMKLIB) -o sha512 sha512.lib.$(OBJ) sha512_stubs.$(OBJ) sha512.cmx

tests: sha.test
	./sha.test

sha.test: sha1.cmxa sha256.cmxa sha512.cmxa sha.test.cmx

%.test:
	$(OCAMLOPT) -o $@ $(OCAML_BFLAGS) unix.cmxa $(OCAML_TEST_INC) $(OCAML_TEST_LIB) $+

%.test.cmo: %.test.ml
	$(OCAMLC) -c -o $@ $(OCAML_BFLAGS) -custom $(OCAML_TEST_INC) $<

%.test.cmx: %.test.ml
	$(OCAMLOPT) -c -o $@ $(OCAML_BFLAGS) $(OCAML_TEST_INC) $<

%.cmo: %.ml
	$(OCAMLC) -c -o $@ $<

%.cmi: %.mli
	$(OCAMLC) -c -o $@ $<

%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c -o $@ $<

%.$(OBJ): %.c
	$(OCAMLC) -ccopt "$(CFLAGS)" -c -o $@ $<

%.lib.$(OBJ): %.$(OBJ)
	mv $< $@

.PHONY: clean install uninstall doc
doc:
	[ -d html ] && rm -f html/* || mkdir html
	ocamldoc -html -d html *.mli

clean:
	rm -f *.$(OBJ) *.$(A) *.$(SO) *.cmo *.cmi *.cma *.cmx *.cmxa sha.test $(PROGRAMS)

install: sha1.cma sha1.cmxa sha256.cma sha256.cmxa sha512.cma sha512.cmxa sha.cma sha.cmxa META
	ocamlfind install sha META *.cmx sha1.cmi sha1.cma sha1.cmxa sha256.cmi sha256.cma sha256.cmxa sha512.cmi sha512.cma sha512.cmxa sha.cma sha.cmxa *.$(A) *.$(SO)

uninstall:
	ocamlfind remove sha
