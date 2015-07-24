---
title: Graphical Fragment Assembly (GFA) Format Specification
author: The GFA Format Specification Working Group
date: 2015-07-24
---

# Master document

The master version of this document can be found at  
<https://github.com/pmelsted/GFA-spec>

# The GFA Format Specification
The purpose of the GFA format is to capture sequence graphs as the product of an
assembly, a representation of variation in genomes, splice graphs in genes, or
even overlap between reads from long-read sequencing technology.

The GFA format is a tab-delimited text format for describing a set of sequences and their overlap. . The first field of the line identifies the type of the line. Header lines start with `H`. Segment lines start with `S`. Link lines start with `L`. A containment line starts with `C`.

## An example



## Terminology

+ **Segment** a continuous sequence or subsequence.
+ **Link** an overlap between two segments. Each link is from the end of one segment to
the beginning of another segment. The link stores the orientation of each segment and
the amount of basepairs overlapping.
+ **Containment** an overlap between two segments where one is contained in the other.
+ **Path** an ordered list of oriented segments that, where each consecutive segments
 are supported by a link w.r.t. the orientation. In cases where there are multiple links
 supporting an overlap it should be explicitly indicated.

## Line structure

Each line in GFA has tab-delimited fields and the first field defines the type of line.

| Line | Type|
|------|:----|
|`H`  |  Header line |
|`S`  |  Segment line |
|`L`  |  Link line |
|`C`  |  Containment line |
|`P`  |  Path line |

## Header line

The header line has only optional fields of the form `TAG:TYPE:VALUE` following
the convention defined in the SAM format. The following fields  are defined
for the Header line

| Tag | Type |  description|
|-----|------|:------------|
|`VN` | `Z`  |  Version number|

## Segment line


|Col| Field     | Type   |  Regexp/Range     |   Brief description |
|----|:---------|:------  |:-------------------|:-----------------|
|2   |  `Name`     |String  | `[!-)+-<>-~][!-~]*`  | Segment name |
|3   | `Sequence`  |String  | `\*|[A-Za-z=.]+`     | The nucleotide sequence |

The Sequence field can be `*` meaning that the sequence is not stored in the GFA file.

### Optional fields

| Tag   | Type | Description    |
|-------|------|----------------|
| `LN`  | `i`  | Segment length |
| `RC`  | `i`  | Read count     |
| `FC`  | `i`  | Fragment count |
| `KC`  | `i`  | k-mer count    |

## Link line

Links are the primary mechanism to connect segments. Links are bidirected, they go
from oriented segments. A link from `A` to `B` means that the end of `A` overlaps with
the end of `B`, if either is marked with `-` we replace the sequence of the segment
with it's reverse complement. The length of the overlap is determined by the `CIGAR`
string of the link. When the overlap is `0M` the `B` segment follows directly after `A`,
... (explain how to interpret the overlap between segments, also for non-`M` it is not
  symmetric).



| Col | Field     |   Type  |   Regexp/Range    |          Brief description |
|-----|:----------|:------|:-------------------|:-----------------|
|2  |   `From`      | String |  `[!-)+-<>-~][!-~]*`      | name of segment |
|3  |   `FromOrient`| String |  `+|-`                    | orientation of From segment |
|4  |   `To`        | String |  `[!-)+-<>-~][!-~]*`      | name of segment |
|5  |   `ToOrient`  | String |  `+|-`                    | orientation of To segment |
|6  |   `Overlap`   | String |  `\*|([0-9]+[MIDNSHPX=])+`| CIGAR string describing overlap |

### Optional fields

| Tag   | Type | Description       |
|-------|------|-------------------|
| `MQ`  | `i`  | Mapping quality   |
| `NM`  | `i`  | # mismatches/gaps |
| `RC`  | `i`  | Read count        |
| `FC`  | `i`  | Fragment count    |
| `KC`  | `i`  | k-mer count       |

## Containment line

## Optional fields

# Recommended Practices for the GFA format

# Reusing existing FASTA files

# A proposal of the Grapical Fragment Assembly format

### Introduction

Almost three years ago, there was a lengthy discussion in the Assemblathon
mailing list about a generic format for fragment assemmbly. The end product is
[the FASTG format][fastg]. In the discussion, I have expressed several major
concerns with the format. The top one is that it is mathematically wrong. Three
years later, FASTG is still not widely used. At this point, [Adam
Phillippy][adamtalk] and [Pall Melsted][pmelsted] openly called for a generic
assembly format again. I also feel the pressing necessity of standardization, so
decided to give a try myself. This is the Graphical Fragment Assembly format, or
GFA in abbreviation.

In this post, I will start from the theoretical basis of assembly graph,
describe the format and finally discuss the potential issues with the proposal.

I showed an earlier version of this format to Richard Durbin, Daniel Zerbino and
Benedict Paten last night in Oxford. That version was a variant of FASTA. When I
was formalizing the format in this post, I found FASTA is too crowded and too
limited. Following the suggestion of Daniel, I finally adopted a format similar
to [ASQG][asqg] and the PSMC output.

### Theory

DNA sequence assembly is often (though not always) represented as a graph.
There are multiple types of graphs including de Bruijn graph, overlap graph,
unitig graph and string graph. They are all [birected graph][bigraph]. Briefly,
in this graph, each vertex is a sequence and each arc is an overlap. Because
DNA sequences have two strands, an arc may have four directions, representing
the four possible overlaps: forward-forward, forward-reverse, reverse-forward
and reverse-reverse. It should be noted that a k-mer de Bruijn graph is
equivalent to an overlap graph for k-mer reads with (k-1)-mer overlaps.
It is a bidirected graph, too.

The critical problem with FASTG is that it puts sequneces on arcs/edges. It is
unable to describe a simple topology such as `A->B; C->B; C->D` without adding a
dummy node, which breaks the theoretical elegance of assembly graphs. Due to the
historical confusion between vertices and edges, I will avoid using these
terminologies. I will use a *segment* for a piece of sequence and a *link* for a
connection between segments.

### The GFA format

Although we can describe an assembly graph with bidirected arcs, I find in
practice, it is easier and more explicit to describe links between the ends of
segments. [Gene Myers][gmyers] took a similar approach in his [string graph
paper][stringg]. Based on this observation, I *uniquely* label the 5'-end and
the 3'-end of each segment. The following shows an assembly graph with seven
segments in GFA:

    H  VN:Z:1.0
    S  1  2  CGATGCAA  *
    L  2  3  5M
    S  3  4  TGCAAAGTAC  *
    L  3  6  0M
    S  5  6  TGCAACGTATAGACTTGTCAC  *  RC:i:4
    L  6  8  1M1D2M1S
    S  7  8  GCATATA  *
    L  7  9  0M
    S  9 10  CGATGATA  *
    S 11 12  ATGA  *
    C  9 11  2  4M

If we name a segment with the two *ordered* integers, the example above is
equivalent to a bidirected graph `1:2>->3:4; 5:6>->3:4; 5:6>-<7:8<->9:10` with
`11:12` contained in `9:10`. The `H` line is the header. An `S` line describes a
segment which consists of 5'-end label, 3'-end label, sequence and
pseudo-quality. An `L` line represents a link which consists of the labels of
the two ends and a CIGAR that describes the overlap alignment taking the first
end as the target/upper sequence. The CIGAR can describe symmetric overlaps
(e.g. `5M`), assembly gaps (e.g. `10N`), gapped overlaps, open-end alignments
(e.g. `1M1D2M1S`; heading `S` for clipping on the second sequence and tailing
`S` on the first), or unaligned overlaps (e.g. `5S10I8D2S`; no `M` operators).
It is related to but different from the CIGAR used in SAM. A `C` line represents
a containment, which is only relevant to read-to-read overlaps.

For all lines, additional information is described with tags in a format
identical to SAM. Predefined tags include:

    Line  Tag  Type  Meaing
    -----------------------------------------------------------------------
     H    VN    Z    Version number
     H    QT    A    Type of pseudo-quality. Valid values: `Q`, `D` or `K`
     S    RC    i    # reads assembled into the segment
    L/C   MQ    i    Mapping quality of the overlap/containment
     L    NM    i    # mismatches/gaps
     S    LN    i    Segment length

### Discussions

1. If this format cannot encode your assembly, please let me know. Thank you.
Suggestions on making GFA work would be appreciated even more. :-)

2. It is unusual to uniquely label the two ends of a segment. [ABySS][abyss], [SGA][sga] and
most other assemblers uniquely label a segment. In my view, end-labeling has a
few advantages: a) it requires fewer operations for reverse-complementing and
unambiguous merging; b) by representing a bidirected arc with `A+,B-`, we are
still converting `A` to two labels; c) my own assembler only works with
end-labeling. I think it should always be easy to convert the segment-labeling
to the end-labeling but not vice versa. Unless there are strong arguments
against end-labeling, I will keep it.

3. Use a string to label an end. I like integers for efficiency, but don't
object to strings in principle.

4. I don't like the CIGAR I proposed. It is too complex. If you can find a
cleaner way to describe all kinds of overlaps and gaps, please let me know.
These complex overlaps are not uncommon in a long-read assembly or for
scaffolding.

5. In FASTG, we can encode a simple "bubble" with `ACGT[C,T]TAGT`. Although GFA
can describe this assembly, it needs to add three more segments and four links,
which are quite heavy. One option is to allow such simple bubbles on the `S`
line with a specific header tag indicating that the file contains small bubbles.
Is it a good idea? How many assemblers can take advantage of this potential
addition?

6. If we can agree on a format, I can write a parser and a few basic tools such
as flip, unambiguous merge and perhaps more complex operations such as tip
trimming and bubble popping if I have time.

7. Any other suggestions?

### Update

Considering to replace end-labeling with the more common segment-labeling. The
example above will look like (better or worse?):

    H  VN:Z:1.0
    S  1  CGATGCAA  *
    L  1  +  2  +  5M
    S  2  TGCAAAGTAC  *
    L  3  +  2  +  0M
    S  3  TGCAACGTATAGACTTGTCAC  *  RC:i:4
    L  3  +  4  -  1M1D2M1S
    S  4  GCATATA  *
    L  4  -  5  +  0M
    S  5  CGATGATA  *
    S  6  ATGA  *
    C  5  +  6  +  2  4M

[fastg]: http://fastg.sourceforge.net
[adamtalk]: http://www.iscb.org/ismb-mm/media-ismb2014/talks
[pmelsted]: http://pmelsted.wordpress.com/2014/07/17/dear-assemblers-we-need-to-talk-together/
[bigraph]: http://en.wikipedia.org/wiki/Bidirected_graph
[asqg]: https://github.com/jts/sga/wiki/ASQG-Format
[stringg]: http://bioinformatics.oxfordjournals.org/content/21/suppl_2/ii79.abstract
[gmyers]: http://en.wikipedia.org/wiki/Eugene_Myers
[abyss]: http://www.bcgsc.ca/platform/bioinfo/software/abyss
[sga]: https://github.com/jts/sga

# First update on GFA

I was out of the town in the past few days, so have not been able to focus on
GFA. Now I am back to work to give the first update on the format based on the
comments from many people, which I appreciate a lot.

In comparison to my initial proposal, the first and the major change is to name
segments instead of the ends of segments. This seems the consensus so far.
Secondly, I am thinking to move the quality field on the "S" line to an
optional tag. Not many assemblers produce quality or per-base read depth.
Thirdly, more people prefer to explictly encode bubbles as multiple segments,
rather than inline them in the sequence. I will use explicit bubbles at least
in the initial iteration.

Here is the graph from the previous post in the updated format:

    H  VN:Z:1.0
    S  1  CGATGCAA
    L  1  +  2  +  5M
    S  2  TGCAAAGTAC
    L  3  +  2  +  0M
    S  3  TGCAACGTATAGACTTGTCAC  RC:i:4
    L  3  +  4  -  1M1D2M1S
    S  4  GCATATA
    L  4  -  5  +  0M
    S  5  CGATGATA
    S  6  ATGA
    C  5  +  6  +  2  4M

A little bit more formally, GFA consists of four types of lines indicated by
the first letter at each line. The format of each line is:

    Line  Fixed fields                                 Comments
	---------------------------------------------------------------
	 H    N/A                                          Header
	 S    segName,segSeq                               Segment
	 L    segName1,segOri1,segName2,segOri2,CIGAR      Link
	 C    segName1,segOri1,segName2,segOri2,pos,CIGAR  Contained

Here is a list of predefined tags:

    Line  Tag  Type  Comments
    -----------------------------------------------------------------------
      H   VN    Z    Version number
     L/S  RC    i    # reads that support the segment/link
     L/S  FC    i    # fragments that support the segment/link
     L/S  KC    i    # k-mer that support the segment/link
     L/C  MQ    i    Mapping quality of the overlap/containment
     L/C  NM    i    # mismatches/gaps
      S   LN    i    Segment length

Discussions and open issues:

1. How to describe complex overlaps with simple syntax. Currently, GFA uses a
   CIGAR, but I think it is bit overcomplicated.

2. Random access to GFA. I am not quite sure how this is useful in practice,
   but it is worth thinking.

3. Small bubbles. Although I said that a few others and I would prefer to
   encode bubbles as explicit segments in the initial iteration, I know a few
   would like a better representation.

4. Where to keep the read-to-contig alignment. My preference is to keep them in
   a separate BAM file.

5. Where to keep the segment sequences. My preference is to keep them in GFA.
   Nonetheless, we still allow to put a "*" at the sequence field. We can still
   describe the topology without the sequence data.

6. "Twin edges". A link can be represented in two directions. My preference is
   to allow both directions. The parser should throw a warning or an error if
   the two directions are inconsistent.

In the next step, I will write a standalone parser for GFA and clean up a few
dirty corners meanwhile. I will also try to write a few converters for existing
assembly formats by various assemblers and implement a few basic tools. If you
have any suggestions, please let me know. After all, I am not so experienced in
de novo assemblies as most of the readers.

Finally, I should emphasize that the format has not been fixed at all, far from
it. Please keep the comments coming. The discussions so far are very helpful to
me. Thank you!
