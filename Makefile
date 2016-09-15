all: GFA-spec.html GFA-spec.pdf

clean:
	rm -f GFA-spec.html GFA-spec.pdf

.PHONY: all clean

%.html: %.md
	pandoc --toc -sS -o $@ $<

%.pdf: %.md
	pandoc --toc -S -o $@ $<
