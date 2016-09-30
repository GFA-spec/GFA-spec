## CHANGED

* All ID's are now in *one* name space and every ID in a definitional context must be unique.
If * is specified in place of an ID on edge, gap, and group id's, then that item does not
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

* X and = are removed from CIGAR string, which are now restricted to MDIP.

* The convention for positions has changed to a Heng's suggestion.  A $ is now a *sentinel* that
follows an integer position if and only if that position is the end of the segment.  It will be
considered an error for such a position not to be so marked.  One can still test if an edge is
a dovetail or containment because the $ effectively tells you the segment length.

## PROPOSED

* The G specification is incomplete as one cannot express <code> <---- gap ----> </code>.
Durbin likes the bidirected edge marks and Myers seconds.  To wit:
```
G * A >> B g v  ==>  A ------> g -------> B
G * A >< B g v  ==>  A ------> g <------- B
G * A <> B g v  ==>  A <------ g -------> B
G * A << B g v  ==>  A <------ g <------- B
```

## ISSUES

* The situation in regard to the use of SAM-tags is unclear.  Currently the proposal has two header
SAM-tags, VN and TS, that *must* be understood by a GFA2 parser.  Should there be others?  If not,
then one could make VN and TS required fields, so that all SAM-tags become custom user extensions,
or ...
