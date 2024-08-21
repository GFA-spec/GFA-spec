---
title: Graphical Fragment Assembly (GFA) Format Specification
author: The GFA Format Specification Working Group
date: 2022-06-07
---

The master version of this document can be found at  
<https://github.com/GFA-spec/GFA-spec>

# The GFA Format Specification

The purpose of the GFA format is to capture sequence graphs as the product of an assembly, a representation of variation in genomes, splice graphs in genes, or even overlap between reads from long-read sequencing technology.

The GFA format is a tab-delimited text format for describing a set of sequences and their overlap. The text is encoded in UTF-8 but is not allowed to use a codepoint value higher than 127. The first field of the line identifies the type of the line. Header lines start with `H`. Segment lines start with `S`. Link lines start with `L`. Jump lines (since v1.2) start with `J`. A containment line starts with `C`. A path line starts with `P`. Walk lines (since v1.1) start with `W`.

## Terminology

+ **Segment**: a continuous sequence or subsequence.
+ **Link**: an overlap between two segments. Each link is from the end of one segment to the beginning of another segment. The link stores the orientation of each segment and the amount of basepairs overlapping.
+  **Jump**: (since v1.2) a connection between two oriented segments. Similar to link, but does not imply a direct adjacency between the segments, instead providing an estimated distance between the segments. Main use case is to specify segment relations across assembly gaps.
+ **Containment**: an overlap between two segments where one is contained in the other.
+ **Path**: an ordered list of oriented segments, where each consecutive pair of oriented segments is supported by a link or a jump record.
+ **Walk**: (since v1.1) an ordered list of oriented segments, intended for pangenome use cases. Each consecutive pair of oriented segments must correspond to a 0-overlap link record.

## Line structure

Each line in GFA has tab-delimited fields and the first field defines the type of line. The type of the line defines the following required fields. The required fields are followed by optional fields.

| Type | Description |
|------|-------------|
| `#`  | Comment     |
| `H`  | Header      |
| `S`  | Segment     |
| `L`  | Link        |
| `J`  | Jump (since v1.2)        |
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

## Extension to use jump connections (since v1.2)

Version 1.2 expands the `P`-line format for using jump connections given by the `J`-lines (see "`J` Jump line" section).
Semicolon (`;`) can now be used as a separator in `SegmentNames` in addition to a comma (`,`) to indicate the usage of a jump connection (defined by `J`-line), rather than a link connection (defined by `L`-line).
If specified, the `Overlaps` field uses the `[-+]?[0-9]+J` format (note the `J` at the end to match the style of a `CIGAR` string) to refer to the jump connection with a particular estimated distance, and `.` if corresponding `J`-line does not provide distance estimate.

| Column | Field          | Type      | Regexp                    | Description
|--------|----------------|-----------|---------------------------|--------------------
| 1      | `RecordType`   | Character | `P`                       | Record type
| 2      | `PathName`     | String    | `[!-)+-<>-~][!-~]*`       | Path name
| 3      | `SegmentNames` | String    | `[!-)+-<>-~][!-~]*`       | A comma/semicolon-separated list of segment names and orientations
| 4      | `Overlaps`     | String    | `\*\|([0-9]+[MIDNSHPX=]\|\[-+]?[0-9]+J\|.)+` | Optional comma-separated list of CIGAR strings and distance estimates

### Example

```
H	VN:Z:1.2
S	11	ACCTT
S	12	TCAAGG
S	13	CTTGATT
L	11	+	12	-	4M
J	11	+	12	-	*	SC:i:1
J	12	-	13	+	10
P	first	11+,12-	*
P	second	11+;12-	*
P	third	11+;12-;13+	.,10J
```

Note how usage of different delimiters in the first two paths disambiguates between the usage of a link vs a shortcut jump the same pair of oriented segments.

# `W` Walk line (since v1.1)

A walk line describes an oriented walk in the graph. It is only intended for a
graph without overlaps between segments. W-line was added in GFA v1.1 and was
not defined in the original GFAv1.
Note that W-lines can not use jump connections (introduced in v1.2).

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
(`SampleId`,`HapIndex`,`SeqId`), their [`SeqStart`,`SeqEnd`) should have no
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

# `J` Jump line (since v1.2)

Jump lines are the mechanism to define the connections of segments which can not be associated with a particular overlap or sequence. Basic usecase is to represent 'gaps' corresponding to unassembled regions, most commonly due to absence or low quality of sequencing data.

`J`-lines specification generally follows one for `L`-lines, using columns 2-4 to specify connected segments and their respective orientations. 
The only difference is that 6th column specifies a signed integer `Distance` (instead of the `Overlap` `CIGAR` string) -- estimated distance between the segments.
The `Distance` can take a `*` value, meaning that the distance is not specified (estimate is unavailable).
Note that the `Distance` can take negative integer values, hinting at an undetected overlap.

Since v1.2 jump connections can be used in the `P`-lines. 
Note that to specify usage of a jump connection rather than a regular link within a path one should use a different separator (`;` instead of `,`). For details and examples see "Extension to use jump connections" subsection the `P`-line description.

`J`-lines can also be used to specify _shortcut_ connections that do not correspond to any missing overlap or absent sequence.
Shortcuts are primarily intended to be used within the `P`-lines to define arbitrary assembly scaffolds.
Shortcut `J`-lines must be marked with a special tag: `SC:i:1`.

## Required fields

| Column | Field        | Type      | Regexp                   | Description
|--------|--------------|-----------|--------------------------|------------------
| 1      | `RecordType` | Character | `J`                      | Record type
| 2      | `From`       | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 3      | `FromOrient` | String    | `+\|-`                   | Orientation of From segment
| 4      | `To`         | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 5      | `ToOrient`   | String    | `+\|-`                   | Orientation of `To` segment
| 6      | `Distance`   | String    | `\*\|[-+]?[0-9]+`        | Optional estimated distance between the segments

## Optional fields

| Tag  | Type | Description
|------|------|------------
| `SC` | `i`  | 1 indicates indirect shortcut connections. Only 0/1 allowed.

## Example

The following lines describe the jump between reverse complement of segment 1 and segment 2, with estimated distance of 100 and the  'shortcut' between segment 2 and reverse complement of segment 3 with unspecified distance.
```
J  1 - 2 + 100
J  2 + 3 - * SC:i:1
```
