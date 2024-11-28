TNA data folder
===============

This is an advanced topic, and only of use for debugging or to understand
the details of what TNA is doing.

TNA stores its data somewhere in your home folder. The location depends on the
operating system, and is chosen by Godot (the language used to write TNA).

They are (probably):

* Windows: ``%APPDATA%\tna``
* macOS: ``~/Library/Application Support/tna``
* Linux: ``~/.local/share/tna``

The entire folder can be deleted. When TNA starts, it will
be recreated and any missing files replaced. But you will lose any changes
made to your settings because they are saved to a file inside the folder.


Contents of the data folder
---------------------------

Config file
^^^^^^^^^^^

Settings (theme choice etc) are stored in the file ``config``.
If it is deleted, TNA will recreate it, filled with the default options.


Binary files
^^^^^^^^^^^^

TNA relies on extra programs, which are put in the ``bin/`` folder:

1. ``tnahelper``, made specifically for TNA. It handles all the extra computation
   outside of viewing the genomes: reading genome files, running blast and
   parsing the output etc. The source code is here:
   https://github.com/martinghunt/tnahelper. If it is not present when
   TNA starts up, it downloads the binary matching the current OS and
   architecture.
2. BLAST programs (``makeblastbd`` and ``blastn``). These are downloaded from
   the NCBI's ftp site when TNA starts, if they are not there already.
   On Windows, there will also be some library (dll) files in this
   folder.


Test data
^^^^^^^^^

The test data is in the folder ``example_data``. This is made by ``tnahelper``
and is two small GFF3 files.


Other files
^^^^^^^^^^^

Log files are automatically written inside the ``logs/`` folder. There is
``current_proj/``, which stores imported genome files and BLAST results.
It is deleted and new files put in there each time new genomes are
imported. The Godot engine stores cached files to do with graphics inside
``shader_cache/``.

