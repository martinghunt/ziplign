Frequently Asked Questions
==========================


Why the name TNA?
^^^^^^^^^^^^^^^^^

It stands for "TNA's Not ACT", following a geeky tradition of using
`recursive acronyms <https://en.wikipedia.org/wiki/Recursive_acronym>`_.
TNA is meant to be a "minimal ACT" (plus all the
extra features I wanted that ACT can't do).
ACT can do a lot of things that TNA cannot.
TNA is not ACT. However, TNA is essentially feature-complete for my use
cases.


Can I compare more than two genomes?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sorry, no. This would have been significantly harder to implement. ACT can do
it.


Why no Windows 10 support?
^^^^^^^^^^^^^^^^^^^^^^^^^^

Because:

1. I can't get BLAST to run. Everything else works.
2. I don't have a proper Windows 10 machine to test on (only a VM), so
   this is difficult to debug.

If you know how to run BLAST natively in Windows 10, please get in contact.


Why no Windows ARM support?
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Because there is no version of BLAST for Windows/ARM.
Everything else works.


Why do the tooltips have slightly blurry text?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This seems to be a known issue with Godot rendering.
Sorry but it probably won't get fixed in TNA unless it's changed in Godot.


Why are the save/load windows slightly blurry?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For the same reason as the tooltips. Please see the previous answer.
One way around it is to make a custom save/load UI instead of the built-in
ones the TNA currently uses, which is not worth the effort.


Why not use ACT instead?
^^^^^^^^^^^^^^^^^^^^^^^^

Go ahead and use ACT. Or use TNA. Up to you. Choose your favourite.

