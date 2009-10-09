CFLAGS = -Wall -O3 -funroll-loops -I/usr/include
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLMKLIB = ocamlmklib

OCAMLOPTFLAGS =

OCAML_TEST_INC = -I `ocamlfind query oUnit`
OCAML_TEST_LIB = `ocamlfind query oUnit`/oUnit.cmxa

PROGRAMS = sha1sum sha256sum sha512sum

allshabytes = $(foreach n, 1 256 512, sha$(n).lib.o sha$(n)_stubs.o sha$(n).cmo)
allshaopts  = $(foreach n, 1 256 512, sha$(n).lib.o sha$(n)_stubs.o sha$(n).cmx)

all: sha1.cmi sha1.cma sha1.cmxa sha256.cma sha256.cmxa sha512.cma sha512.cmxa sha.cma sha.cmxa

bins: $(PROGRAMS)

sha1sum: shacommon.cmx sha1.cmxa sha256.cmxa sha512.cmxa shasum.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ -cclib -L. $+

sha256sum: sha1sum
	cp $< $@

sha512sum: sha1sum
	cp $< $@

sha.cma: shacommon.cmo $(allshabytes)
	$(OCAMLMKLIB) -o sha $(allshabytes)

sha.cmxa: shacommon.cmo $(allshaopts)
	$(OCAMLMKLIB) -o sha $(allshaopts)

sha1.cma: shacommon.cmo sha1.cmi sha1.lib.o sha1_stubs.o sha1.cmo
	$(OCAMLMKLIB) -o sha1 sha1.lib.o sha1_stubs.o sha1.cmo

sha1.cmxa: shacommon.cmx sha1.cmi sha1.lib.o sha1_stubs.o sha1.cmx
	$(OCAMLMKLIB) -o sha1 sha1.lib.o sha1_stubs.o sha1.cmx

sha256.cma: shacommon.cmo sha256.cmi sha256.lib.o sha256_stubs.o sha256.cmo
	$(OCAMLMKLIB) -o sha256 sha256.lib.o sha256_stubs.o sha256.cmo

sha256.cmxa: shacommon.cmx sha256.cmi sha256.lib.o sha256_stubs.o sha256.cmx
	$(OCAMLMKLIB) -o sha256 sha256.lib.o sha256_stubs.o sha256.cmx

sha512.cma: shacommon.cmo sha512.cmi sha512.lib.o sha512_stubs.o sha512.cmo
	$(OCAMLMKLIB) -o sha512 sha512.lib.o sha512_stubs.o sha512.cmo

sha512.cmxa: shacommon.cmx sha512.cmi sha512.lib.o sha512_stubs.o sha512.cmx
	$(OCAMLMKLIB) -o sha512 sha512.lib.o sha512_stubs.o sha512.cmx

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

%.o: %.c
	$(OCAMLC) -ccopt "$(CFLAGS)" -c -o $@ $<

%.lib.o: %.o
	mv $< $@

.PHONY: clean install uninstall doc
doc:
	[ -d html ] && rm -f html/* || mkdir html
	ocamldoc -html -d html *.mli

clean:
	rm -f *.o *.a *.cmo *.cmi *.cma *.cmx *.cmxa sha.test $(PROGRAMS)

install: sha1.cma sha1.cmxa sha256.cma sha256.cmxa sha512.cma sha512.cmxa sha.cma sha.cmxa META
	ocamlfind install sha META *.cmx sha1.cmi sha1.cma sha1.cmxa sha256.cmi sha256.cma sha256.cmxa sha512.cmi sha512.cma sha512.cmxa sha.cma sha.cmxa *.a *.so

uninstall:
	ocamlfind remove sha
