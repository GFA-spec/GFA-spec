# A proposal for a comprehensive assembly format

Jason Chin, Richard Durbin, and myself (Gene Myers) found ourselves together at a workshop
meeting in Dagstuhl Germany and hammered out an initial proposal for an assembly format.
We thought [GFA](https://github.com/pmelsted/GFA-spec) was a good start point and built a
more comprehensive
design around it.  We are calling this preliminary version the "Dagstuhl Assembly Format" or
[DAS](DAS-spec.md) and offer it up here for comment, criticism, and suggestions with the hope that
eventually some version of it might find adoption.

The reason that we want a standard is that we find that
in general, *different* development teams build assemblers, visualizers, and editors because
of the complexity and distinct nature of the three tasks.  While these tools should certainly
use tailored encodings internally for efficiency, the nexus between the three efforts
would benefit from a standard encoding format that would make them all interoperable.

![Fig. 1](READ.Fig1.png)

The white paper is [here](DAS-spec.md)
