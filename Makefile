all: GFA-spec.pdf

clean:
	rm -f GFA-spec.pdf

.PHONY: all clean

%.pdf: %.md
	pandoc -So $@ $<
