Settings
========

The settings menu can be accessed using the "Settings" button in the main
menu.

Settings are automatically saved when you return to the main menu.
Changes are persistent between closing and re-opening TNA.

The options are:

* Theme: the color theme can be changed from the default "Light" to various
  other themes.
* Open TNA data folder: this will open your file manager at the
  built-in :doc:`folder where TNA stores user data </data_folder>`.
  This can be useful when debugging
  or when uninstalling TNA. In normal circumstances, you probably won't
  need to use this.
* Mouse wheel sensitivity: increase or decrease the amount of zoom when moving
  the mouse wheel. The default is "1". The number chosen here
  is multiplied by an internal value for each mouse wheel movement. This means
  to move half as much, set the option to 0.5. To double the amount moved, set
  it to 2. If you want to turn it off completely, then set it to 0 (zero). Large
  values are not recommended, because one wheel movement will make TNA jump
  straight to maximum or minimum zoom.
* Invert mouse wheel: use this to swap the effect of up/down on the mouse
  wheel, if you think zoom happens in the wrong direction
* Trackpad zoom sensitivity: change the sensitivity of two-finger up/down
  movement to zoom using a trackpad. Similarly to the mouse wheel description,
  think of this as a multiplier, with the default being 1.
* Invert trackpad zoom: use this to swap the effect of up/down on the
  trackpad, if you think zoom happens in the wrong direction
* Trackpad left/right sensitivity: change the sensitivity of two-finger
  left/right movement.
* Trackpad pinch sensitivity: change the sensitivity of pinch-zoom gesture
  on a trackpad.
* Share BLAST usage with NCBI: by default, the command line BLAST program
  sends some data to the NCBI, as described in their
  `privacy statement <https://www.ncbi.nlm.nih.gov/books/NBK569851/>`_.
  By default, TNA turns *off* this setting so that no data is shared. You can
  turn it back on if you choose.
* Max BLAST matches on screen: the maximum number of BLAST matches to show.
  Displaying too many will significantly impact memory usage.
  The default of 500 should be enough - a lot more than this and the screen
  ends up filled in to the point where it is impossible to see anything useful.
* FASTA line length: the length of each line when copying/pasting sequence.
  Must be a non-negative integer. Put zero to have no line breaks in sequences.
