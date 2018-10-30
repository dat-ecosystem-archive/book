# Terminology
The following terms are used when describing the Dat Protocol.

## Terminology Currently in Use
- __feed:__ The main data structure in Hypercore. Append-only log that uses
  multiple data structures and algorithms to safely store data.
- __data:__ Atomic pieces of data that are written to the feed by users.
- __keypair:__ An `Ed25519` keypair used to encrypt data with.
- __signature:__ Certificate that proves a data structure was created by a
  specific keypair.
- __tree:__ A binary tree mapped as a `flat-tree` to keep an index of the
  current data.
- __flat-tree:__ Mapping of a series of integers to a binary tree structure.
- __bitfield:__ Space-efficient data structure used to figure out which data you
  have and what data you don't. Meant to always be kept in memory because it's
  small enough.
- __run-length-encoding (RLE):__ Basic compression scheme used to compress
  bitfields when sending over the wire.
