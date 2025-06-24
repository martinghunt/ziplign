A brief history of Ziplign
==========================

If you are interested in why Ziplign was made in the first place, and some of the
details of the implementation, then please read on.


Motivation
----------

`Artemis <http://sanger-pathogens.github.io/Artemis/Artemis/>`_ and
`ACT  <http://sanger-pathogens.github.io/Artemis/ACT/>`_
are excellent programs, both of which I use heavily.
Sadly, they are no longer really actively maintained.
There are lots of great genome viewers
out there - obviously `IGV <https://igv.org>`_
being very popular. Implementing yet another genome
viewer is probably not a good use of time.

However, there is no tool for me that can do what ACT does. It is extremely
comprehensive (because it essentially has the functionality of Artemis).
But there are features that I always wish it had:

* proper support for multi-FASTA files (you can hack to get around this)
* run BLAST for you, instead of needing to provide your own comparison file
* show base-level alignment between genomes (SNPs, indels). I have always
  wanted to see these when zoomed in to the sequence level.
* easier contig reordering, and also be able to reverse complement individual
  contigs
* out of the box support for Apple silicon. It does run on Apple silicon, but
  needs a bit of Java-related hacking to do so. This seems beyond the
  skills of less technical users
* save and load a "project" - ie both genomes and the comparison file - instead
  of needing to keep 3 files around for each use of ACT

I was playing around with the game engine `Godot <https://godotengine.org>`_,
and tested how difficult it would be to get the basic functionality of ACT
working. This was just showing rectangles (contigs), parallelograms/triangles
(blast matches), and being able to slide the top and bottom genomes around and
have the blast matches follow suit.
It turned out to work quite well as a proof of concept.
This then grew into Ziplign.

The aim of Ziplign was always to be a minimal implementation of the essential
things I want from ACT and nothing more: view two genomes, plus the
features listed above.  It's pronounced "zipline" and is a
backronym: "Zoomable Interactive Paired-genome aLIGnment Navigator" (or
have fun making up your own acronym).
I rarely use ACT to view more than two genomes,
so early on I decided (to save a lot of implementation pain) to only support
two genomes. This is baked in and will not change.


Under the hood
--------------

I wanted Ziplign to be cross-platform, which was another reason to use Godot.
It can export a project to Windows, Mac, and Linux (and x86 and ARM
architecture). It can also make Android and i(pad)OS apps - which I thought
about making, but I don't think it's possible to get them to run BLAST.
It would have been nice to have an ipad app, but it is too locked down
to make this practical.

This was my first project using Godot (and indeed a GUI of any kind).
Handling all the 2D graphics in Godot is relatively easy, what with it
being a game engine.
Displaying genomes and BLAST matches was probably the simplest part.
The biggest challenge of making Ziplign was the GUI:
adding menus, buttons, and then in particular being able to change colour
themes etc.
Most of this comes down
to Ziplign not being a game, but a tool. Although Godot is set up to make such
a program (its own IDE is made in Godot),
it is primarily for making games.

There is, unsurprisingly,
no "bio-Godot". Seeing as Ziplign would need to run BLAST as a separate program,
I decided to offload all the heavy lifting bioinformatics tasks to a separate
program as well, called `zlhelper <https://github.com/martinghunt/zlhelper>`_.
This also needed to be cross-platform,
and so is written in the Go programming language. It parses sequence files,
handles reading compressed files, runs BLAST and parses its output. The plus
side of using Go is that it can compile stand-alone binaries for Windows,
macOS and Linux, and both ARM and x86 architecture.
