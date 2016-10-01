## CHANGED

* All ID's are now in *one* name space and every ID in a definitional context must be unique.
If * is specified in place of an ID on edge, gap, and group lines, then that item does not
have an ID and is presumably not referred to elsewhere (i.e. U- or O-lines).

* Sequences in S-lines were defined as <code>[a-zA-Z]+</code>.  Unecessarily restrictive.  Changed
to any printable sequence excluding space, i.e <code>[!-~]+</code>.

* There was some discussion about restricting headers to the first few lines, but in the end the
consensus was to leave the specification free of any line order restrictions.

* The P[UO]-line headers have been split into a U-line and an O-line.

* A 'TS' SAM-tag in a header defines a *default* trace spacing to use with all traces, unless the
line containing the trace has a 'TS' SAM-tag after the fixed fields specifying a spacing to use
with that specific trace.

* The README2.md and README.md have been consolidated into README.md.

* The L-line extension has been removed.

* X and = are removed from CIGAR strings, which are now restricted to MDIP.

* The convention for positions has changed to Heng's proposal.  Namely, a $ is now a *sentinel* that
follows an integer position if and only if that position is the end of the segment.  It will be
considered an error for such a position not to be so marked.  One can still test if an edge is
a dovetail or containment because the $ effectively tells you the segment length.

* The variance field in G-lines can now be either an integer or a * when not known.

## PROPOSED

* The G specification is incomplete as one cannot express <code> <---- gap ----> </code>.
Using 2 orientation signs seems the simplist and most consistent way to address this.  That is:
```
G * A + B + g v  ==>  A ------> g -------> B
G * A + B - g v  ==>  A ------> g <------- B
G * A - B + g v  ==>  A <------ g -------> B
G * A - B - g v  ==>  A <------ g <------- B
```
However, Richard feels strongly that the sign has a different meaning in E- and F-, so we
should use:
```
G * A >> B g v  ==>  A ------> g -------> B
G * A >< B g v  ==>  A ------> g <------- B
G * A <> B g v  ==>  A <------ g -------> B
G * A << B g v  ==>  A <------ g <------- B
```

* Vis a vis SAM-tags, I would suggest that any tag other than 'VN' and 'TS' are user specific.
We suggest readers should be able to parse SAM-tags occurring after the fixed fields of a line,
but they do not need to retain or intepret any of them.
