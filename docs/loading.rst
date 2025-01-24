Loading new genomes
===================

Selecting "New" from the main menu takes you to the new project page,
where you can import two genomes to compare.


Sequence files
--------------

You can add the top and bottom genome files with one of:

* dragging and dropping from your file browser into the box
* typing the full path to the filename in the box
* typing an accession in the box. This can be a GenBank/RefSeq
  sequence accession, or an assembly accession starting
  with ``GCA_`` or ``GCF_``.

TNA will first check if what you put in the box is a file on your computer.
If it is not, then it checks to see if it "looks like" an accession. This
means that it starts with ``GCA_``, ``GCF_``, ``AC_``, ``NC_``, ``NG_``,
``NT_``, ``NW_``, ``NZ_``, or it starts with two letters followed by at
least six digits and then anything else afterwards - for example ``CP039850.1``.
If it looks like an accession then it will try to download
the sequence and annotation. Note that this is not sanity checked and providing
an accession that does not exist will result in errors upon trying to
download. It is intentionally permissive - allowing two letters plus dix digits
etc - so as to not rule out real accessions because it is not trivial to
specify exactly what counts as a real accession.

TNA automatically detects the format (and any compression)
of each sequence file based on its contents, not the name of the file.

TNA supports these file formats:

* FASTA
* FASTQ (loading sequencing reads is NOT recommended! The assumption is that
  you want to view contigs)
* GFF3, as long as the sequence(s) are included in the file as well as the
  annotation. TNA will show the annotation features.
* GenBank. TNA will use the sequence, but for now has partial support for the
  annotation. It will load the genes only, and no other features.
* EMBL. TNA will use the sequence, but for now has partial support for the
  annotation. It will load the genes only, and no other features.

TNA can read uncompressed files, and files compressed with gzip, bzip2 and
xz.





BLAST options
-------------

TNA runs ``blastn`` to compare the genomes. You can add options to the
``blastn`` call. Please note that these options are NOT sanity checked and
are simply added onto the end of the ``blastn`` call.

Please do not use any options relating to file input or output, since it will
cause TNA to crash. Specifically, TNA already uses the options ``-db``,
``-query``, ``-out``, and ``-outfmt``. Do not try to change them.

The default in the BLAST options box is ``-evalue 0.1``,
to remove obviously short/unlikely matches. This is different from the
BLASTN defaults, which has no e-value cutoff.
If you want no e-value cutoff, then delete the text from the box, so that it
is empty and the default BLAST settings are used.
It is beyond the scope of this help to go into the details of the extra
BLASTN options. Run ``blastn -help`` in a terminal to see the full help.


Start processing
----------------

Once the genome files are provided, the start button will change from
disabled to enabled. Press it and TNA will then:

* check the input genome files exist
* import the genomes
* make a BLAST index of the bottom genome
* run BLAST using the top genome as the query against the bottom genome
  database
* import the BLAST results
* switch to the genome comparison view

The progress is output in text at the bottom of the window. If anything
goes wrong, error messages will appear there.
