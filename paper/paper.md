---
title: 'Ziplign: a simple-to-use interactive tool to compare bacterial genomes'
tags:
  - Bioinformatics
  - Genomics
  - Microbiology
authors:
  - name: Martin Hunt
    orcid: 0000-0002-8060-4335
    equal-contrib: false
    corresponding: true
    affiliation: "1, 2, 3, 4" # (Multiple affiliations must be quoted)
  - name: Zamin Iqbal
    orcid: 0000-0001-8466-7547
    equal-contrib: false # (This is how you can denote equal contributions between multiple authors)
    affiliation: 5
affiliations:
 - name: European Molecular Biology Laboratory - European Bioinformatics Institute, Hinxton, UK
   index: 1
 - name: Nuffield Department of Medicine, University of Oxford, Oxford, UK
   index: 2
 - name: National Institute of Health Research Oxford Biomedical Research Centre, John Radcliffe Hospital, Headley Way, Oxford, UK
   index: 3
 - name: Health Protection Research Unit in Healthcare Associated Infections and Antimicrobial Resistance, University of Oxford, Oxford, UK
   index: 4
 - name: Milner Centre for Evolution, University of Bath, UK
   index: 5
date: 1 April 2025
bibliography: paper.bib
---


# Summary
Ziplign is a user-friendly interactive application to visually compare two
bacterial genome sequences and their annotation. It requires no command-line
use, and is intended to make genome-comparison easily accessible to the
biologist. Genome files can be directly drag-and-dropped into Ziplign, or will be
automatically downloaded when an accession is provided. All commonly-used file
formats and compression are supported. The comparison between genomes is
generated using NCBI blast+[@blast], which is run for the user, and then the
two genomes, their annotation, and sequence matches are displayed by Ziplign. A
screenshot of Ziplign is shown in \autoref{fig1}.



![Figure 1 Screenshots of Ziplign comparing the Shigella flexneri 2a genome
GCF\_000007405.1 [@flexneri] - shown at the top - with the Escherichia
coli K-12 substr. MG1655 GCF\_000005845.2 [@k12] - shown at the bottom.
BLAST matches are shown in red when the direction of
the match is the same in both genomes, and in blue when they are in opposite
directions. To reduce noise in the screenshot, only matches of at least 2000bp
and 95% identity are shown (configurable by the user via the panel on the
left). Annotation features on the forward/reverse strand are shown in the
top/bottom of each contig. a) Default view, showing the complete genomes and
their overall structural similarities. b) Zoomed to the base-pair level,
matching nucleotides marked with black lines, SNPs are in orange, and
non-parallel black lines denote indels in the
alignment.\label{fig1}](fig1.pdf){width=100%}


# Statement of need
Comparing two bacterial genome sequences is a fundamental task in genomics,
used in numerous scenarios: comparing closely related strains to discern
differences such as the overall structure and any rearrangements, the presence
or absence of important features such as virulence factors or anti-microbial
genes, or to identify horizontal gene transfer. Genome assemblies can be
compared to each other or against a reference genome for debugging or
determining the most accurate assembly. Whilst many command line tools are
available for processing samples at scale and report statistics, it is
invaluable to visually and interactively compare two genomes. This is often
the simplest way to truly understand the differences between two
sequences.

To our knowledge ACT[@act] and Mauve[@mauve] are the only existing tools
for displaying genomes and matches between them in an interactive manner -
however both tools are no longer supported. Since ACT is based on
Artemis[@artemis], it incorporates the extensive feature set implemented in
Artemis. However, ACT has a number of limitations. It can be difficult for
non-technical users to install and use, Java must be installed, the user must
provide (most likely via running command line tools) a genome comparison file,
multi-sequence genomes are not supported out of the box, and alignment details
including SNPs and small insertions and deletions are not shown. Mauve is simple
to run but it displays global alignments of locally collinear blocks shared
between genomes,
meaning that repeats may not be shown. We tested this using a 1000bp randomly
generated sequence sampled uniformly from A,C,G,T characters,
comparing it to a second contig comprising two identical copies of the first
1000bp sequence, and Mauve showed no matches
(also tested again using a 10,000bp sequence).

Here we introduce Ziplign, which fills the need for an easy-to-install and
simple-to-use genome comparison tool. It is heavily inspired by ACT, with a
very similar user interface, but is significantly easier to install and
use.


# Usage and availability
Ziplign is intended for microbiologists with no command line experience. As such,
no use of a terminal is required. First, two genomes must be provided, either
with an NCBI accession or by dragging-and-dropping local files. FASTA, FASTQ,
GFF3, EMBL and GenBank file formats are supported, optionally with gzip, bzip2
or xz compression. Genome sequences and annotation are automatically
downloaded when an accession is used. Ziplign runs blastn from the NCBI blast+
suite to generate the matches between the two genomes. The blastn
options are configurable by the user.

Genomes are displayed at the top and bottom of the window, with BLAST matches
shown between them (Figure 1). The view can be zoomed and panned using mouse,
trackpad or keyboard controls, or with buttons in the control panel on the
left. Features include searching by nucleotide sequence or annotation, contig
reordering, and reverse complementing contigs. Ziplign can save and load an entire
“project” - the genomes, annotations, and BLAST matches - using a single binary
file, removing the need to store the original files.

Ziplign is available for Windows 11, macOS, and Linux operating systems from
GitHub [https://github.com/martinghunt/ziplign](https://github.com/martinghunt/ziplign),
under the MIT license.
Comprehensive documentation is hosted on ReadTheDocs
[https://ziplign.readthedocs.io/en/](https://ziplign.readthedocs.io/en/).


# Implementation
Ziplign is primarily written in GDScript, the scripting language of the free, open
source, MIT licensed, game engine Godot
([https://godotengine.org](https://godotengine.org),
[https://github.com/godotengine/godot](https://github.com/godotengine/godot)).
This handles the graphical user
interface (GUI), and displaying and interacting with all the genome and
comparison data. Bioinformatics tasks such as parsing sequence/BLAST files and
downloading genomes are processed using a separate command line program called
zlhelper
[https://github.com/martinghunt/zlhelper](https://github.com/martinghunt/zlhelper),
also with the MIT license, written in the Go programming language. All command
line programs are hidden from the user, so that the only interaction is simply
with the GUI.


# Acknowledgements
The authors thank Daniel Anderson, Jane Hawkey and Leah Roberts for testing
Ziplign, and Thomas Hunt for making the Ziplign icon.
Martin Hunt was supported by the National Institute for Health Research (NIHR)
Health Protection Research Unit in Healthcare Associated Infections and
Antimicrobial Resistance at Oxford University in partnership with the UK
Health Security Agency (UKHSA) (NIHR200915), and supported by the NIHR
Biomedical Research Centre, Oxford. The views expressed in this publication
are those of the authors and not necessarily those of the NHS, the National
Institute for Health Research, the Department of Health or the UKHSA.


# References
