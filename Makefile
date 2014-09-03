.PHONY: default all opt demo doc install uninstall clean
default: all opt demo
all:
	ocamlc -c multiarmed.mli
	ocamlc -c multiarmed.ml
	ocamlc -a -o multiarmed.cma multiarmed.cmo
opt:
	ocamlc -c multiarmed.mli
	ocamlopt -c multiarmed.ml
	ocamlopt -a -o multiarmed.cmxa multiarmed.cmx
demo:
	ocamlopt -o demo multiarmed.mli multiarmed.ml demo.ml
	./demo 10 100_000 10_000
doc:
	mkdir -p html
	ocamldoc -html -d html multiarmed.mli
install:
	ocamlfind install multiarmed META \
		$$(ls *.mli *.cm[ioxa] *.cmxa *.o *.a 2>/dev/null)
uninstall:
	ocamlfind remove multiarmed
clean:
	rm -f *.cm[ioxa] *.o *.cmxa *.a *~
	rm -rf html
	rm -f demo
