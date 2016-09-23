all: GFA-spec.html GFA-spec.pdf

clean:
	rm -f GFA-spec.html GFA-spec.pdf

.PHONY: all clean

%.html: %.md
	pandoc -sS --toc --toc-depth=1 -o $@ $<

%.pdf: %.md
	pandoc -S --toc --toc-depth=1 -o $@ $<
