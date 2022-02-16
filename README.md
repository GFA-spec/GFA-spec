# GFA: Graphical Fragment Assembly (GFA) Format Specification

We are developing the specification of the Graphical Fragment Assembly (GFA) format. Your contribution is welcome. Please open up issues or submit pull requests.

+ GFA 2.0 is at [GFA2.md](GFA2.md)
+ GFA 1.0 is at [GFA1.md](GFA1.md)

# Implementations

## GFA 2

+ [ABySS](https://github.com/bcgsc/abyss)
+ [Cuttlefish](https://github.com/COMBINE-lab/cuttlefish)
+ [dsh-bio](https://github.com/heuermh/dishevelled-bio)
+ [gfakluge](https://github.com/edawson/gfakluge)
+ [gfalint](https://github.com/sjackman/gfalint)
+ [GfaPy](https://github.com/ggonnella/gfapy)
+ [GfaViz](https://github.com/ggonnella/gfaviz)

## GFA 1

+ [ABySS](https://github.com/bcgsc/abyss)
+ [Assembly Cytoscape3 App](http://apps.cytoscape.org/apps/assembly)
+ [Bandage](https://github.com/asl/Bandage)
+ [bcalm2](https://github.com/GATB/bcalm)
+ [bfgraph](https://github.com/pmelsted/bfgraph)
+ [cactus pangenome pipeline](https://github.com/ComparativeGenomicsToolkit/cactus/blob/master/doc/pangenome.md)
+ [Canu](https://github.com/marbl/canu)
+ [Cuttlefish](https://github.com/COMBINE-lab/cuttlefish)
+ [dsh-bio](https://github.com/heuermh/dishevelled-bio)
+ [fermi mag2gfa](https://github.com/lh3/mag2gfa)
+ [gbwt](https://github.com/jltsiren/gbwt)
+ [gfabase](https://github.com/mlin/gfabase)
+ [gfakluge](https://github.com/edawson/gfakluge)
+ [GfaPy](https://github.com/ggonnella/gfapy)
+ [GfaViz](https://github.com/ggonnella/gfaviz)
+ [jts/DALIGNER](https://github.com/jts/daligner)
+ [lh3/gfa1](https://github.com/lh3/gfa1)
+ [lh3/gfatools](https://github.com/lh3/gfatools)
+ [lmrodriguezr/gfa](https://github.com/lmrodriguezr/gfa)
+ [McCortex](https://github.com/mcveanlab/mccortex)
+ [miniasm](https://github.com/lh3/miniasm)
+ [ODGI toolkit](https://github.com/pangenome/odgi)
+ [PanGenome Graph Builder (pggb)](https://github.com/pangenome/pggb)
+ [RGFA](https://github.com/ggonnella/RGFA)
+ [seqwish](https://github.com/ekg/seqwish)
+ [SPAdes](http://cab.spbu.ru/software/spades/)
+ [TwoPaCo](https://github.com/medvedevgroup/TwoPaCo)
+ [Unicycler](https://github.com/rrwick/Unicycler)
+ [vg](https://github.com/ekg/vg)
+ [w2rap](https://github.com/bioinfologics/w2rap-contigger)

# Resources

+ [Examples](https://github.com/sjackman/assembly-graph) of sequence overlap graphs (assembly graphs) in a variety of formats

# GFA 1.0

GFA 1 was first suggested in a [blog post](http://lh3.github.io/2014/07/19/a-proposal-of-the-grapical-fragment-assembly-format) by Heng Li (@lh3) and further developed in a [second post](http://lh3.github.io/2014/07/23/first-update-on-gfa).
Its original purpose was to represent assembly graphs.

## Pangenome models and extensibility

The GFA model was then adopted by Erik Garrison and others to represent [pangenome reference systems](https://doi.org/10.17863/CAM.41621).
From 2015, P-lines have been employed to provide a positional system in pangenome graphs. These are now used in several tools (e.g. vg toolkit, odgi, and the maintained fork of Bandage).

W-lines were suggeseted by Heng Li (@lh3) as an extension to GFA 1 for representing lossy haplotype information in pangenome graphs.
This need arises when building a pangenome graph using sequences with masked repeats, or when imputing short read data into a pangenome reference model.

GFA 1 maintains backward compatibility with these and future user-level extensions by allowing parsers to not consider all line types.

# GFA 2.0: Graphical Fragment Assembly (GFA2) Format Specification 2.0

Jason Chin, Richard Durbin, and myself (Gene Myers) found ourselves together at a workshop
meeting in Dagstuhl Germany and hammered out an initial proposal for an assembly format.
We started with [GFA 1](GFA1.md) and proceeded to build a
more comprehensive design around it.  After extensive revision and discussion on Github with
the GFA group including Shaun Jackman, Heng Li, and Giorgio Gonnella, we arrived at
[GFA 2.0](GFA2.md). The standard is an evolving effort, and your contribution is welcome. Please open up issues or submit pull requests.

The basic reason for having a standard format is that we find that
in general, *different* development teams build assemblers, visualizers, and editors because
of the complexity and distinct nature of the three tasks.  While these tools should certainly
use tailored encodings internally for efficiency, the nexus between the three efforts
benefits from a standard encoding format that would make them all interoperable.

![Fig. 1](images/READ.Fig1.png)

