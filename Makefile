all:
	ocaml setup.ml -build
oasis:
	oasis setup
	ocaml setup.ml -configure
clean:
	rm -rf _build
	rm -rf *.byte *.native
	rm -rf log/*
cleanall:
	rm -rf _build setup.* myocamlbuild.ml _tags
	rm -rf *.byte *.native
	rm -rf lib/META lib/*.mldylib lib/*.mllib
	rm -rf log/*
