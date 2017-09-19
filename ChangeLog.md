## CHANGED

* All ID's, except external Fragment IDs, are now in *one* name space and every ID in a
definitional context must be unique.  External fragment IDs are in another name space.
If * is specified in place of an ID on edge, gap, and group lines, then that item does
not have an ID and is presumably not referred to elsewhere (i.e. U- or O-lines).

* Sequences in S-lines were defined as <code>[a-zA-Z]+</code>.  Unnecessarily restrictive.  Changed
to any printable sequence excluding space, i.e. <code>[!-~]+</code>.

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

* In order to encompass all use-cases desired by the various parties, and to properly specify gap
relationships, a majority voted that *references* to objects are signed in those context where
it makes sense and/or is necessary.  An identifier followed by + or - is a signed-reference and
orients the underlying segment, edge, or path accordingly.  The sign is *not* a separate field
but a post-fix mark on the identifier, analogous to the postfix $ on integer positions.

* In regard to SAM-tags, only the 'VN' and 'TS' tags are explicitly in the specification and must
be interpreted by applications.  Two lists of optional tags will be maintained called the
**Core List** and the **Community List**.
The Core list will contain initially all GFA1 tags
and any additions must be by community consensus.
The Community list can more loosely contain any tags proposed by any user.
The general expectation is that tags would initially be proposed on the community list, and
if over time become popular, then could migrate to the core list.
