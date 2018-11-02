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
- __parent node:__ A parent has two children under it, and is always
  odd-numbered. Node 3 is the parent of 1 and 5.
- __leaf node:__ A node with no children. A leaf node is always even-numbered.
  Nodes 0, 2, 4, 6 and 8 are leaf nodes.
- __sibling node:__ The other node that shares a parent with the current node.
  For example nodes 4 and 6 are siblings.
- __uncle node:__ A parent's sibling. Node 1 is the uncle of nodes 4 and 6.
- __root node:__ A top-most node where the full tree under it is complete (e.g.
  all parent nodes have 2 children). Node 3 is a root node.
- __node span:__ The two nodes that are furthest away in the sub-tree. The span
  of node 1 is `0, 2`. The span of node 3 is `0, 6`.
- __right node span:__ The left-most node in the span. The right span of node 1
  is 2. The right span of node 3 is 6.
