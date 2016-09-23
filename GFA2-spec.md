# **GFA 2.0: Proposal**

## PROLOG

GFA2 is a generalization of GFA that allows one to specify an assembly graph in either less detail,
e.g. just the topology of the graph, or more detail, e.g. the multi-alignment of reads giving
rise to each sequence.  It is further designed to be a able to represent a string
graph at any stage of assembly, from the graph of all overlaps, to a final resolved assembly
of contig paths with multi-alignments.  Apart from meeting these needs, the extensions also
supports other assembly and variation graph types.

The proposal if for a *core standard*.  As will be seen later in
the technical specification, the format is **extensible** in that additional description lines
can be added and additional SAM tags can be appended to core description lines.

In overview, an assembly is a graph of vertices called **segments** representing sequences
that are connected by **edges** that denote local alignments between the vertex sequences.
At a minimum one must specify the length of the sequence represented, further specifying the
actual sequence is optional.  In the direction of more detail, one can optionally specify a
collection of external sequences, called **fragments**, from which the sequence was derived (if
applicable) and how they multi-align to produce the sequence.  Similarly, the specification
of an edge need only describe the range of base pairs aligned in each string, and optionally
contain a **trace** or a **CIGAR string** to describe the alignment of the edge.  Traces are a
space-efficient Dazzler assembler concept that allow one to efficiently reconstruct an
alignment in linear time, and CIGAR strings are a SAM concept explicitly detailing the
columns of an alignment.  Many new technologies such a Hi-C and BioNano maps organize segments
into scaffolds along with traditional data sets involving paired reads, and so a **gap** edge
concept is also introduced so that order and orientaiton between disjoint contigs of an
assembly can be described.  Finally, one can describe and attach a name to any **path** or
**subgraph** in the encoded string graph.

## GRAMMAR

```
<spec>     <- ( <header> | <segment> | <edge> | <gap> | <group> )+

<header>   <- H {VN:Z:2.0} {TS:i:<trace spacing>}

<segment>  <- S <sid:id> <slen:int> <sequence>

<fragment> <- F <sid:id> [+-] <external:id>
                  <sbeg:pos> <send:pos> <fbeg:pos> <fend:pos> <alignment>

<edge>     <- E <eid:id> <sid1:id> [+-] <sid2:id>
                         <beg1:pos> <end1:pos> <beg2:pos> <end2:pos> <alignment>

<gap>      <- G <eid>:id> <sid1:id> [+-] <sid2:id> <dist:int> <var:int>

<group>    <- P[UO] <name:id> <item>([ ]<item>)*

    <id>        <- [!-~]+
    <item>      <- <sid:id> | <eid:id>
    <pos>       <- {$}<int>
    <sequence>  <- * | [A-Za-z]+
    <alignment> <- * | <trace array> | <CIGAR string>

      <CIGAR string> <- ([0-9]+[MX=DIP])+
      <trace array>  <- <int>(,<int>)*
```

In the grammar above all symbols are literals other than tokens between <>, the derivation
operator <-, and the following marks:

  * {} enclose an optional item
  * | denotes an alternative
  * * zero-or-more
  * + one-or-more
  * [] a set of one character alternatives.

Like GFA, GFA2 is tab-delimited in that every lexical token is separated from the next
by a single tab.

Each descriptor line must begin with a letter and lies on a single line with no white space
before the first symbol.   The tokens that generate descriptor lines are \<header\>, \<segment\>,
\<fragment\>, \<edge\>, \<gap\>, and \<group\>.
Any line that does not begin with a recognized code (i.e. H, S, F, E, G, or P) can be ignored.
This will allow users to have additional descriptor lines specific to their special processes.
Moreover, the suffix of any GFA2 descriptor line may contain any number of user-specific SAM
tags which are ignored by software designed to support the core standard.

## SEMANTICS

The header contains an optional 'VN' SAM-tag version number, 2.0, and an optional 'TS' SAM-tag specifying
the trace point spacing for any Dazzler traces specified to accelerate alignment computation.
Any number of header lines containing SAM-tags may occur.

A segment is specified by an S-line giving a user-specified ID for the
sequence, its length in bases, and the string of bases denoted by the segment or * if absent.
The length does not need to be the actual length of the sequence, if given, but is rather
an indication to a drawing program of how long to draw the representation of the segment.
The segment sequences and any CIGAR strings referring to them if present follow the
*unpadded* SAM convention.

Fragments, if present, are encoded in F-lines that give (a) the segment they belong to, (b) the
orientation of the fragment to the segment, (c) an external ID that references a sequence
in an external collection (e.g. a database of reads or segments in another GFA2 or SAM file),
(d) the interval of the vertex segment that the external string contributes to, and (e)
the interval of the fragment that contributes to to segment.  One concludes with either a
trace or CIGAR string detailing the alignment, or a \* if absent.

Edges are encoded in E-lines that in general represent a local alignment between arbitrary
intervals of the sequences of the two vertices in question. One gives first an edge ID and
then the segment ID’s of the two vertices and a + or – sign between them to indicate whether
the second segment should be complemented or not.  An edge ID does not need to be unique or
distinct from a segment ID, *unless* you plan to refer to it in a P-line (see below).  This
allows you to use something short like a single *-sign as the id when it is not needed.

One then gives the intervals of each segment that align, each as a pair of *positions*.  A position
is either an integer or the special symbol $ followed immediately by an integer.
If an integer, the position is the distance from the *left* end of the segment,
and if $ followed by an integer, the distance from the *right* end
of the sequence.  This ability to define a 0-based position from either end of a segment
allows one to conveniently address end-relative positions without knowing the length of
the segments.  Note carefully, that the segment and fragment intervals in an F-line are
also positions.

Note carefully, that the positions intervals are always intervals in the segment in its normal
orientation.  If a minus sign is specified, then the interval of the second segment is
reverse complemented in order to align with the interval of the first segment.  That is,
<code>S s1 - s2 b1 e1 b2 e2</code> aligns s1[b1,e1] to the reverse complement of s2[b2,e2].

A field for a CIGAR string or trace describing the alignment is last, but may be absent
by giving a \*.  One gives a CIGAR string to describe an exact alignment relationship between
the two segments.  A trace string by contrast is given when one simply wants an accelerated
method for computing an alignment between the two intervals.  If a \* is given as the alignment
note that it is still possible to compute the implied alignment by brute force.

The GFA2 concept of edge generalizes the link and containment lines of GFA.  For example a GFA
edge which encodes what is called a dovetail overlap (because two ends overlap) is simply a GFA2
edge where end1 = $0 and beg2 = 0 or beg1 = 0 and end2 = $0.   A GFA containment is
modeled by the case where beg2 = 0 and end2 = $0 or beg1 = 0 and end1 = $0.  The figure
below illustrates:

![Illustration of position and edge definitions](GFA2.Fig1.png)

Special codes could be adopted for dovetail and containment relationships but the thought is
there is no particular reason to do so, the use of the special characters for terminal positions
makes their identification simple both algorithmically and visually, and the more general
scenario allows interesting possibilities.  For example, one might have two haplotype bubbles
shown in the “Before” picture below, and then in a next phase choose a path through the
bubbles as the primary “contig”, and then capture the two buble alternatives as a vertex
linked with generalized edges shown in the “After” picture.  Note carefully that you need a
generalized edge to capture the attachment of the two haplotype bubbles in the “After” picture.

![Example of utility of general edges](GFA2.Fig2.png)
 
While one has graphs in which vertex sequences actually overlap as above, one also frequently
encounters models in which there is no overlap (basically edge-labelled models captured in a
vertex-labelled form).  This is captured by edges for which beg1 = end1 and beg2 = end2 (i.e.
0-length overlap)!

While not a concept for pure DeBrujin or long-read assemblers, it is the case that paired end
data and external maps often order and orient contigs/vertices into scaffolds with
intervening gaps.  To this end we introduce a “gap” edge described in G-lines that give the
estimated gap distance between the two vertex sequences and the variance of that estimate
or 0 if no estimate is available.  Relationships in E-lines are fixed and known, where as
in a G-line, the distance is an estimate and the line type is intended to allow one to
define assembly **scaffolds**.

A group encoding on a P-line allows one to name and specify a subgraph of the overall graph.
Such a collection could for example be hilighted by a drawing program on
command, or might specify decisions about tours through the graph.  The P is immediately
follwed by U or O indicating either an *unordered* or *ordered* collection.  The remainder of
the line then consists of a name for the collection followed by a non-empty list of ID's
refering to segments and/or edges that are *separated by single spaces* (i.e. the list is
in a single column of the tab-delimited format).  An unordered collection refers to
the subgraph induced by the vertices and edges in the collection (i.e. one adds all edges
between a pair of segments in the list and one adds all segments adjacent to edges in the
list.)   An ordered collection captures paths in the graph consisting of the listed objects
and the implied adjacent objects between consecutive objects in the list (e.g.
the edge between two consecutive segments, the segment between two consecutive edges, etc.)

Note carefully that there may be several edges between a given pair of segments, so in
in this event it is necessary that edges have unique IDs that can be referred to as a
segment pair does not suffice.  The convention is that every edge has an id, but this
id need only be unique and distinct from the set of segment ids when one wishes to refer
to the edge in a P-line.  So an id in a P-line refers first to a segment id, and if there
is no segment with that id, then to the edge with that id.  All segment id's must be
unique, and it is an error if an id in a P-line does not refer to a unique edge id
when a segment with the id does not exist.

## EXTENSIONS

```
<link>     <- L <eid:id> <sid1:id> [+-] <sid2:id> [+-]
                         <ovl1:int> <ovl2:int> {<alignment>}
```

Some users want a specific specification for edges that encode dovetail overlaps reminiscent
of the L-line in GFA.  The table below gives the direct translation from an L-line into
the more general E-line, and serves effectively as the definition of an L-line's semantics:

```
L s1 + s2 + o1 o2       <==>      E s1 + s2 $o1  $0   0  o2
L s1 + s2 - o1 o2       <==>      E s1 - s2 $o1  $0 $o2  $0
L s1 - s2 + o1 o2       <==>      E s1 - s2   0  o1   0  o2
L s1 - s2 - o1 o2       <==>      E s1 + s2   0  o1 $o2  $0
```

## BACKWARD COMPATIBILITY WITH GFA

GFA2 is a superset of GFA, that is, everything that can be encoded in GFA can be encoded
in GFA2, with a relatively straightforward transformation of each input line.

On the otherhand, a GFA parser, even one that accepts optional SAM-tags at the end of a
defined line type, and which ignores line types not defined in GFA, will not accept a
GFA2 specification because of changes in the defined fields of the S- and P-lines.
Acheving this also makes no sense because GFA2 extends what was encoded in the L- and
C-lines of GFA with a single E-line generalization.  So any useful GFA2 reader must
read E-lines, and therefore must be an extension of a GFA parser anyway.

The syntactic conventions, however, are identical to GFA.  Each description line begins
with a single letter and has a fixed set of fields that are tab-delimited.  The changes
are as follows:

1. There is an integer length field in S-lines.

2. The L- and C-lines have been replaced by a consolidated E-line.

3. The P-line has been enhanced to encode both subgraphs and paths, and can take
   edge id's, obviating the need for orientation signs and alignments between segments.

4. There is a new F-line for describing multi-alignments.

5. Alignments can be trace length sequences as well as CIGAR strings.

6. Positions have been extended to include a notation for 0-based position with respect
   to *either* end of a segment (the default being with respect to the beginning).
