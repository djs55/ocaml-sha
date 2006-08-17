CC = gcc
CFLAGS = -Wall -O3 -funroll-loops
OCAMLC = ocamlc
OCAMLOPT = ocamlopt

OCAMLOPTFLAGS =

OCAML_TEST_INC = -I `ocamlfind query oUnit`
OCAML_TEST_LIB = `ocamlfind query oUnit`/oUnit.cmxa

all: sha1.cmi sha1.cma sha1.cmxa

sha1sum: sha1.cmxa sha1sum.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ $+

sha1.cma: sha1.cmi sha1_stubs.o sha1.cmo
	$(OCAMLC) -a -o $@ -custom sha1_stubs.o sha1.cmo

sha1.cmxa: sha1.cmi sha1_stubs.o sha1.cmx
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -a -o $@ sha1_stubs.o sha1.cmx

tests: sha1.test
	./sha1.test

sha1.test: sha1.cmxa sha1.test.cmx

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

clean:
	rm -f *.o *.a *.cmo *.cmi *.cma *.cmx *.cmxa sha1.test sha1sum
