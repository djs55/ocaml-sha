CC = gcc
CFLAGS = -Wall -O3 -funroll-loops
OCAMLC = ocamlc
OCAMLOPT = ocamlopt

OCAMLOPTFLAGS =

OCAML_TEST_INC = -I `ocamlfind query oUnit`
OCAML_TEST_LIB = `ocamlfind query oUnit`/oUnit.cmxa

PROGRAMS = sha1sum sha256sum sha512sum

all: sha1.cmi sha1.cma sha1.cmxa sha256.cma sha256.cmxa sha512.cma sha512.cmxa

bins: $(PROGRAMS)

sha1sum: sha1.cmxa sha256.cmxa sha512.cmxa shasum.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ $+

sha256sum: sha1sum
	cp $< $@

sha512sum: sha1sum
	cp $< $@

sha1.cma: sha.cmo sha1.cmi sha1.lib.o sha1_stubs.o sha1.cmo
	$(OCAMLC) -a -o $@ -custom sha1.lib.o sha1_stubs.o sha1.cmo

sha1.cmxa: sha.cmx sha1.cmi sha1.lib.o sha1_stubs.o sha1.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -o $@ sha1.lib.o sha1_stubs.o sha1.cmx

sha256.cma: sha256.cmi sha256.lib.o sha256_stubs.o sha256.cmo
	$(OCAMLC) -a -o $@ -custom sha256.lib.o sha256_stubs.o sha256.cmo

sha256.cmxa: sha256.cmi sha256.lib.o sha256_stubs.o sha256.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -o $@ sha256.lib.o sha256_stubs.o sha256.cmx

sha512.cma: sha512.cmi sha512.lib.o sha512_stubs.o sha512.cmo
	$(OCAMLC) -a -o $@ -custom sha512.lib.o sha512_stubs.o sha512.cmo

sha512.cmxa: sha512.cmi sha512.lib.o sha512_stubs.o sha512.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -o $@ sha512.lib.o sha512_stubs.o sha512.cmx

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
	$(CC) $(CFLAGS) -c -o $@ $<

%.lib.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.a *.cmo *.cmi *.cma *.cmx *.cmxa sha.test $(PROGRAMS)
