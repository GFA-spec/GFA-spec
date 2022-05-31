---
title: Graphical Fragment Assembly (GFA) Format Specification
author: The GFA Format Specification Working Group
date: 2022-02-11
---

The master version of this document can be found at  
<https://github.com/GFA-spec/GFA-spec>

# The GFA Format Specification

The purpose of the GFA format is to capture sequence graphs as the product of an assembly, a representation of variation in genomes, splice graphs in genes, or even overlap between reads from long-read sequencing technology.

The GFA format is a tab-delimited text format for describing a set of sequences and their overlap. The text is encoded in UTF-8 but is not allowed to use a codepoint value higher than 127. The first field of the line identifies the type of the line. Header lines start with `H`. Segment lines start with `S`. Link lines start with `L`. A containment line starts with `C`. A path line starts with `P`.

## Terminology

+ **Segment**: a continuous sequence or subsequence.
+ **Link**: an overlap between two segments. Each link is from the end of one segment to the beginning of another segment. The link stores the orientation of each segment and the amount of basepairs overlapping.
+ **Containment**: an overlap between two segments where one is contained in the other.
+ **Path** or **Walk**: an ordered list of oriented segments, where each consecutive pair of oriented segments are supported by a link record.

## Line structure

Each line in GFA has tab-delimited fields and the first field defines the type of line. The type of the line defines the following required fields. The required fields are followed by optional fields.

| Type | Description |
|------|-------------|
| `#`  | Comment     |
| `H`  | Header      |
| `S`  | Segment     |
| `L`  | Link        |
| `C`  | Containment |
| `P`  | Path        |
| `W`  | Walk (since v1.1) |

## Optional fields

All optional fields follow the `TAG:TYPE:VALUE` format where `TAG` is a two-character string that matches `/[A-Za-z][A-Za-z0-9]/`. Each `TAG` can only appear once in one line. A `TAG` containing lowercase letters are reserved for end users. A `TYPE` is a single case-sensitive letter which defines the format of `VALUE`.

| Type | Regexp                                                | Description
|------|-------------------------------------------------------|------------
| `A`  | `[!-~]`                                               | Printable character
| `i`  | `[-+]?[0-9]+`                                         | Signed integer
| `f`  | `[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?`              | Single-precision floating number
| `Z`  | `[ !-~]+`                                             | Printable string, including space
| `J`  | `[ !-~]+`                                             | [JSON][], excluding new-line and tab characters
| `H`  | `[0-9A-F]+`                                           | Byte array in hex format
| `B`  | `[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+` | Array of integers or floats

[JSON]: http://json.org/

For type `B`, array of integers or floats, the first letter indicates the type of numbers in the following comma separated array. The letter can be one of `cCsSiIf`, corresponding to `int8_t` (signed 8-bit integer), `uint8_t` (unsigned 8-bit integer), `int16_t`, `uint16_t`, `int32_t`, `uint32_t` and `float`, respectively.

## Segment and path names

Path and segment records are identified by a unique name. All record types share the same namespace, so a path may not have the same name as a segment.

Names must not contain whitespace characters nor start with `*` or `=` nor contain the strings `+,` (plus comma) and `-,` (minus comma). All other printable ASCII characters are allowed. Names are case sensitive.

# `#` Comment line

Comment lines begin with `#` and are ignored. 

## Required fields

| Column | Field        | Type      | Regexp | Description
|--------|--------------|-----------|--------|------------
| 1      | `RecordType` | Character | `#`    | Record type

# `H` Header line

## Required fields

| Column | Field        | Type      | Regexp | Description
|--------|--------------|-----------|--------|------------
| 1      | `RecordType` | Character | `H`    | Record type

## Optional fields

| Tag  | Type | Description
|------|------|------------
| `VN` | `Z`  | Version number

# `S` Segment line

## Required fields

| Column | Field        | Type      | Regexp              | Description
|--------|--------------|-----------|---------------------|------------
| 1      | `RecordType` | Character | `S`                 | Record type
| 2      | `Name`       | String    | `[!-)+-<>-~][!-~]*` | Segment name
| 3      | `Sequence`   | String    | `\*\|[A-Za-z=.]+`    | Optional nucleotide sequence

The Sequence field is optional and can be `*`, meaning that the nucleotide sequence of the segment is not specified. When the sequence is not stored in the GFA file, its length may be specified using the `LN` tag, and the sequence may be stored in an external FASTA file.

## Optional fields

| Tag   | Type | Description    |
|-------|------|----------------|
| `LN`  | `i`  | Segment length |
| `RC`  | `i`  | Read count     |
| `FC`  | `i`  | Fragment count |
| `KC`  | `i`  | k-mer count    |
| `SH`  | `H`  | SHA-256 checksum of the sequence |
| `UR`  | `Z`  | URI or local file-system path of the sequence. If it does not start with a standard protocol (e.g. ftp), it is assumed to be a local path. |

# `L` Link line

Links are the primary mechanism to connect segments. Links connect oriented segments. A link from `A` to `B` means that the end of `A` overlaps with the start of `B`. If either is marked with `-`, we replace the sequence of the segment with its reverse complement, whereas a `+` indicates the segment sequence is used as-is.

The length of the overlap is determined by the `CIGAR` string of the link. When the overlap is `0M` the `B` segment follows directly after `A`. When the `CIGAR` string is `*`, the nature of the overlap is not specified. The `CIGAR` string must be constructed so that the corresponding end of sequence `A` in the orientation given by `FromOrient` is the reference and the start of `B` in the orientation given by `ToOrient` is the query.

## Required fields

| Column | Field        | Type      | Regexp                   | Description
|--------|--------------|-----------|--------------------------|------------------
| 1      | `RecordType` | Character | `L`                      | Record type
| 2      | `From`       | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 3      | `FromOrient` | String    | `+\|-`                    | Orientation of From segment
| 4      | `To`         | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 5      | `ToOrient`   | String    | `+\|-`                    | Orientation of `To` segment
| 6      | `Overlap`    | String    | `\*\|([0-9]+[MIDNSHPX=])+`| Optional `CIGAR` string describing overlap

The Overlap field is optional and can be `*`, meaning that the CIGAR string is not specified.

## Optional fields

| Tag   | Type | Description
|-------|------|------------
| `MQ`  | `i`  | Mapping quality
| `NM`  | `i`  | Number of mismatches/gaps
| `RC`  | `i`  | Read count
| `FC`  | `i`  | Fragment count
| `KC`  | `i`  | k-mer count
| `ID`  | `Z`  | Edge identifier

# `C` Containment line

A containment line represents an overlap between two segments where one (the `Contained` segment)
is contained in the other (the `Container` segment). The `Pos` field stores the leftmost
position of the contained segment in the container segment in its forward orientation
(i.e. before this is oriented according to the `ContainerOrient` sign).

## Example

The following line describes the containment of segment 2 in the reverse complement of segment 1,
starting at position 110 of segment 1 (in its forward orientation).
```
C  1 - 2 + 110 100M
```


## Required fields

| Column | Field             | Type      | Regexp                   | Description
|--------|-------------------|-----------|--------------------------|------------
| 1      | `RecordType`      | Character | `C`                      | Record type
| 2      | `Container`       | String    | `[!-)+-<>-~][!-~]*`      | Name of container segment
| 3      | `ContainerOrient` | String    | `+\|-`                   | Orientation of container segment
| 4      | `Contained`       | String    | `[!-)+-<>-~][!-~]*`      | Name of contained segment
| 5      | `ContainedOrient` | String    | `+\|-`                   | Orientation of contained segment
| 6      | `Pos`             | Integer   | `[0-9]*`                 | 0-based start of contained segment
| 7      | `Overlap`         | String    | `\*\|([0-9]+[MIDNSHPX=])+` | CIGAR string describing overlap

## Optional fields

| Tag   | Type | Description
|-------|------|------------
| `RC`  | `i`  | Read coverage
| `NM`  | `i`  | Number of mismatches/gaps
| `ID`  | `Z`  | Edge identifier

# `P` Path line

## Required fields

| Column | Field          | Type      | Regexp                    | Description
|--------|----------------|-----------|---------------------------|--------------------
| 1      | `RecordType`   | Character | `P`                       | Record type
| 2      | `PathName`     | String    | `[!-)+-<>-~][!-~]*`       | Path name
| 3      | `SegmentNames` | String    | `[!-)+-<>-~][!-~]*`       | A comma-separated list of segment names and orientations
| 4      | `Overlaps`     | String    | `\*\|([0-9]+[MIDNSHPX=])+` | Optional comma-separated list of CIGAR strings

The CIGAR strings in the `Overlaps` field are optional, and may be replaced by a single `*` character, in which case the `CIGAR` strings are determined by fetching the `CIGAR` string from the corresponding link records, or by performing a pairwise overlap alignment of the two sequences. If specified, the `Overlaps` field must have one fewer values than the number of segment names and orientations in the `SegmentNames` field.

## Optional fields

None specified.

## Example

```
H	VN:Z:1.0
S	11	ACCTT
S	12	TCAAGG
S	13	CTTGATT
L	11	+	12	-	4M
L	12	-	13	+	5M
L	11	+	13	+	3M
P	14	11+,12-,13+	4M,5M
```

The resulting path is:

```
11 ACCTT
12  CCTTGA
13   CTTGATT
14 ACCTTGATT
```

# `W` Walk line (since v1.1)

A walk line describes an oriented walk in the graph. It is only intended for a
graph without overlaps between segments. W-line was added in GFA v1.1 and was
not defined in the original GFAv1.

## Required fields

| Column | Field             | Type      | Regexp                   | Description
|--------|-------------------|-----------|--------------------------|------------
| 1      | `RecordType`      | Character | `W`                      | Record type
| 2      | `SampleId`        | String    | `[!-)+-<>-~][!-~]*`      | Sample identifier
| 3      | `HapIndex`        | Integer   | `[0-9]+`                 | Haplotype index
| 4      | `SeqId`           | String    | `[!-)+-<>-~][!-~]*`      | Sequence identifier
| 5      | `SeqStart`        | Integer   | `\*\|[0-9]+`             | Optional Start position
| 6      | `SeqEnd`          | Integer   | `\*\|[0-9]+`             | Optional End position (BED-like half-close-half-open)
| 7      | `Walk`            | String    | `([><][!-;=?-~]+)+`      | Walk

For a haploid sample, `HapIndex` takes 0. For a diploid or polyploid sample,
`HapIndex` starts with 1. For two W-lines with the same
(`SampleId`,`HapIndex`,`SeqId`), their [`SeqSart`,`SeqEnd`) should have no
overlaps. A `Walk` is defined as
```txt
<walk> ::= ( `>' | `<' <segId> )+
```
where `<segId>` corresponds to the identifier of a segment. A valid walk must
exist in the graph.

## Example

```txt
H	VN:Z:1.1
S	s11	ACCTT
S	s12	TC
S	s13	GATT
L	s11	+	s12	-	0M
L	s12	-	s13	+	0M
L	s11	+	s13	+	0M
W	NA12878	1	chr1	0	11	>s11<s12>s13
```

# `J` Jump/Gap line (since v1.2)

While not a concept for pure DeBrujin or long-read assemblers, it is the case that paired end data 
and external maps often order and orient contigs/vertices into scaffolds with intervening gaps. 
To this end we introduce a gap edge described in J-lines that give an arbitrary or estimated gap distance between the two segment sequences.
The gap is between the first segment at left and the second segment at right where the segments are oriented according to their sign indicators. 
The next integer gives the arbitrary or expected distance between the first and second segment in their respective orientations. 
Relationships in E-lines are fixed and known, where as in a G-line, the distance is an estimate and the line type is intended to allow one to define assembly scaffolds.

J-line was added in GFA v1.2 and was not defined in the original GFAv1. In addition, since J-lines can contribute to paths (P-lines), these have been further specified in v1.2.
Particularly, a new separator `;` is introduced as opposed to `,` to distinguish whether the path is intended to use have a gap or an overlap link between the two segments being considered.

## Required fields

| Column | Field        | Type      | Regexp                   | Description
|--------|--------------|-----------|--------------------------|------------------
| 1      | `RecordType` | Character | `J`                      | Record type
| 2      | `From`       | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 3      | `FromOrient` | String    | `+\|-`                   | Orientation of From segment
| 4      | `To`         | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 5      | `ToOrient`   | String    | `+\|-`                   | Orientation of `To` segment
| 6      | `Overlap`    | String    | `[0-9]+`                 | Arbitrary or expected distance between the segments

## Example

```
H	VN:Z:1.2
S	11	ACCTT
S	12	TCAAGG
S	13	CTTGATT
J	11	+	12	-	10
J	12	-	13	+	10
J	11	+	13	+	3
P	14	11+;12-;13+	;,;
```
