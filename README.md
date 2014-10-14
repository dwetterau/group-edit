group-edit
==========

This uses [Firebase](https://www.firebase.com) and an intention preserving conflict avoidance strategy based on 
[this research](https://hal.inria.fr/file/index/docid/71240/filename/RR-5580.pdf) to 
provide a real-time collaboration experience in a textarea element.

It relies on efficient diffs on the text content to produce necessary updates to propagate to other viewers. 
Offline updates are always able to be applied. Writes by competing viewers will not be interleaved and the 
algorithm tries to preserve the cursor position that makes sense for each viewer.

A demo of it in action is available [here](https://grouped.firebaseapp.com).

## WIP
- Converting textarea to contenteditable div elements
- Creating new algorithm for conflict resolution
