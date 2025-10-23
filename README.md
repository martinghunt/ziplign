# Ziplign

Ziplign is a free application to visualise the comparison of two bacterial genomes.
It is intended to be easy to use: you just need to drag and drop two sequence
files to compare. Ziplign will run BLAST for you and show you the results.
There is no need to use a terminal or type any commands.

Documentation: https://ziplign.readthedocs.io/en/

## Quick start


### Download Ziplign

Download the [latest release](https://github.com/martinghunt/ziplign/releases/latest)
for your operating system. It is available for Linux, Mac, and Windows 11.
If you are using Linux, then make the downloaded file
executable (eg `chmod 755`).

Double-click the downloaded file to run Ziplign.
The first time Ziplign is run, it will download some extra programs such
as BLAST. This might take some time depending on internet speed.



### Test data

Check if the install is OK using the test data.

1. Press the "New" button - this is the screen for loading new genomes.
2. Press the icon with a tick at the top right,
which will fill in the boxes to use the
built in test data. There is a screenshot in the
[test data](https://ziplign.readthedocs.io/en/stable/installation.html#use-the-test-data)
documentation.
3. Press the "Start" button at the bottom. This will process the
test data and then switch to viewing the two genomes.

You should now be able to move around and zoom using the buttons near the top
left and/or the cursor keyboard keys. Zoom using the mouse wheel,
or pinch gesture on a trackpad.


### Real data

Get back to the main menu using the back arrow at the top left, or by pressing
"q".

1. Press the "New" button again.
2. To compare two genomes that are in files on your computer, drag and drop
one file into the "Top genome file" box, and
a second genome into the "Bottom genome file" box.
3. Press the "Start" button at the bottom. Ziplign will run BLAST between the genomes and then
switch to viewing them.

Alternatively, genome accessions can be used instead of files on your
computer, and Ziplign will download the genomes from the NCBI.
As described in more detail in the [sequence files](https://ziplign.readthedocs.io/en/stable/loading.html#sequence-files)
documentation, most common accession formats can be used, such as `GCA_*`, `NC_*` etc.
For example, the S. flexneri and E. coli K12 genomes `GCF_000007405.1` and
`GCF_000005845.2`.


### Further reading

Please see the full documentation at: https://ziplign.readthedocs.io/en/.

Highlights of Ziplign include:
* [Search](https://ziplign.readthedocs.io/en/stable/searching.html) for sequence
or annotation features
* [Basic editing](https://ziplign.readthedocs.io/en/stable/contig_editing.html).
Contigs can be reordered and reverse-complemented.
* [Save/Load](https://ziplign.readthedocs.io/en/stable/saving_n_loading.html)
a project in a single file that stores both genomes and BLAST results.

