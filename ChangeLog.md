## CHANGED

* All ID's are now in *one* name space.  Edge id's can still be shared when they do not need to be
unique, but segment, group, and referenced edge's must all have unique ID's relative to each other.

* Sequences in S-lines were defined as <code>[a-zA-Z]+</code>.  Unecessarily restrictive.  Changed
to any printable sequence excluding space, i.e <code>[!-~]+</code>.

* There was some discussion about restricting headers to the first few lines, but in the end the
consensus was to leave the specification free of any line order restrictions.

* The P[UO]-line headers have been split into a U-line and an O-line.

* In addition to a *default* trace spacing that can be specified in a header with the 'TS' SAM-tag,
one can also place an optional <code> <int>: </code> prior to an integer trace list, to specify a
specific trace spacing for that particular trace.

## PROPOSED

* The G specification is incomplete as one cannot express <code> <---- gap ----> </code>.  Propose to solve it by using position syntax:
```
G * A + B  g v  ==>  A ------> g1 -------> B
G * A - B  g v  ==>  A ------> g1 <------- B
G * A + B $g v  ==>  B ------> g1 -------> A
G * A - B $g v  ==>  B <------ g1 -------> A
```
The alternative would be to bring back signs on each segment in both G- and E-lines.

## ISSUES

* The situation in regard to the use of SAM-tags is unclear.  Currently the proposal has two header
SAM-tags, VN and TS, that *must* be understood by a GFA2 parser.  Should there be others?  If not,
then one could make VN and TS required fields, so that all SAM-tags become custom user extensions,
or ...
