all: pdf

PDFS =	GFAv1.pdf

pdf: $(PDFS)

GFAv1.pdf: GFAv1.tex GFAv1.ver


.SUFFIXES: .tex .pdf .ver
.tex.pdf:
	pdflatex $<
	while grep -q 'Rerun to get [a-z-]* right' $*.log; do pdflatex $< || exit; done

.tex.ver:
	echo "@newcommand*@commitdesc{`git describe --always --dirty`}@newcommand*@headdate{`git rev-list -n1 --format=%aD HEAD $< | sed '1d;s/.*, *//;s/ *[0-9]*:.*//'`}" | tr @ \\ > $@


mostlyclean:
	-rm -f *.aux *.idx *.log *.out *.toc *.ver

clean: mostlyclean
	-rm -f $(PDFS)


.PHONY: all pdf mostlyclean clean
