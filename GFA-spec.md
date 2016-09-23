---
title: Graphical Fragment Assembly (GFA) Format Specification
author: The GFA Format Specification Working Group
date: 2016-09-15
---

The master version of this document can be found at  
<https://github.com/GFA-spec/GFA-spec>

# The GFA Format Specification

The purpose of the GFA format is to capture sequence graphs as the product of an assembly, a representation of variation in genomes, splice graphs in genes, or even overlap between reads from long-read sequencing technology.

The GFA format is a tab-delimited text format for describing a set of sequences and their overlap. The first field of the line identifies the type of the line. Header lines start with `H`. Segment lines start with `S`. Link lines start with `L`. A containment line starts with `C`. A path line starts with `P`. A walk line starts with `W`.

## Terminology

+ **Segment** a continuous sequence or subsequence.
+ **Link** an overlap between two segments. Each link is from the end of one segment to the beginning of another segment. The link stores the orientation of each segment and the amount of basepairs overlapping.
+ **Containment** an overlap between two segments where one is contained in the other.
+ **Path** an ordered list of oriented segments, where each consecutive pair of oriented segments are supported by a link record.
+ **Walk** a sequence defined as an ordered series of alignments to segments of the graph.

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
| `W`  | Walk        |

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
| 3      | `Sequence`   | String    | `\*|[A-Za-z=.]+`    | Optional nucleotide sequence

Segment names must not contain whitespace characters or start with `*` or `=`. All other printable ASCII characters are allowed. Names are case sensitive.

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

The length of the overlap is determined by the `CIGAR` string of the link. When the overlap is `0M` the `B` segment follows directly after `A`. When the `CIGAR` string is `*`, the nature of the overlap is not specified.

## Required fields

| Column | Field        | Type      | Regexp                   | Description
|--------|--------------|-----------|--------------------------|------------------
| 1      | `RecordType` | Character | `L`                      | Record type
| 2      | `From`       | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 3      | `FromOrient` | String    | `+|-`                    | Orientation of From segment
| 4      | `To`         | String    | `[!-)+-<>-~][!-~]*`      | Name of segment
| 5      | `ToOrient`   | String    | `+|-`                    | Orientation of `To` segment
| 6      | `Overlap`    | String    | `\*|([0-9]+[MIDNSHPX=])+`| Optional `CIGAR` string describing overlap

The Overlap field is optional and can be `*`, meaning that the CIGAR string is not specified.

## Optional fields

| Tag   | Type | Description
|-------|------|------------
| `MQ`  | `i`  | Mapping quality
| `NM`  | `i`  | Number of mismatches/gaps
| `RC`  | `i`  | Read count
| `FC`  | `i`  | Fragment count
| `KC`  | `i`  | k-mer count

# `C` Containment line

This line can be used to describe mapping between segments in the graph and input sequences. It is useful for graphs built from assembled genomes, e.g. pan-genome analysis graphs.

## Required fields

| Column | Field        | Type      | Regexp                   | Description
|--------|--------------|-----------|--------------------------|------------
| 1      | `RecordType` | Character | `C`                      | Record type
| 2      | `From`       | String    | `[!-)+-<>-~][!-~]*`      | Name of From segment
| 3      | `FromOrient` | String    | `+|-`                    | Orientation of From segment
| 4      | `To`         | String    | `[!-)+-<>-~][!-~]*`      | Name of To segment
| 5      | `ToOrient`   | String    | `+|-`                    | Orientation of To segment
| 6      | `Pos`        | Integer   | `[0-9]*`                 | 0-based start of contained segment
| 7      | `Overlap`    | String    | `\*|([0-9]+[MIDNSHPX=])+`| CIGAR string describing overlap

## Optional fields

| Tag   | Type | Description
|-------|------|------------
| `RC`  | `i`  | Read coverage
| `NM`  | `i`  | Number of mismatches/gaps

# `P` Path line

## Required fields

| Column | Field          | Type      | Regexp                    | Description
|--------|----------------|-----------|---------------------------|--------------------
| 1      | `RecordType`   | Character | `P`                       | Record type
| 2      | `PathName`     | String    | `[!-)+-<>-~][!-~]*`       | Path name
| 3      | `SegmentNames` | String    | `[!-)+-<>-~][!-~]*`       | A comma-separated list of segment names and orientations
| 4      | `Overlaps`     | String    | `\*|([0-9]+[MIDNSHPX=])+` | Optional comma-separated list of CIGAR strings

The `Overlaps` field is optional and can be `*`, in which case the `CIGAR` strings are determined by fetching the `CIGAR` string from the corresponding link records, or by performing a pairwise overlap alignment of the two sequences.

# `W` Walk line

Walks describe sequences in terms of a series of mappings (steps) to the segments of the graph.
Each step in the path represents the mapping between part of the sequence encoded in the walk and a particular segment.
The step contains a offset and CIGAR, which allows it to describe differecse between the walk's sequence and the underlying graph.
Each `W` line refers to a single step, which is uniquely identified by its rank among steps that comprise the walk.

There are no limitations about where successive steps in the walk may map.
Links between the ends of the records are not required.
Walks may thus be defined without modification of the segments and links of the graph, such as by aligning sequences to the graph.

## Required fields

| Column | Field          | Type      | Regexp                    | Description
|--------|----------------|-----------|---------------------------|--------------------
| 1      | `RecordType`   | Character | `W`                       | Record type
| 2      | `SegmentName`  | String    | `[!-)+-<>-~][!-~]*`       | Traversed segment
| 3      | `WalkName`     | String    | `[!-)+-<>-~][!-~]*`       | Walk name
| 4      | `MappingRank`  | Integer   | `[0-9]*`                  | The rank of this element in the walk which it is part of
| 5      | `Orientation`  | String    | `+|-`                     | Orientation of traversal relative to segment
| 6      | `Offset`       | Integer   | `[0-9]*`                  | The 0-based offset from the beginning of the segment on the given strand
| 7      | `Mapping`      | String    | `\*|([0-9]+[MIDNSHPX=])+` | `CIGAR` string describing mapping of walk to the segment

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
P	x	11+,12-,13+	4M,5M
W	11	y	1	+	0	1M
W	12	y	2	-	0	1M
W	13	y	3	+	0	7M
```

The resulting path (x) and walk (y) are equivalent.

```
11 ACCTT
12  CCTTGA
13   CTTGATT
x  ACCTTGATT
y  ACCTTGATT
```
