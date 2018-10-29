# Storage
You can represent a binary tree in a simple flat list using the following
structure:

```txt
      3
  1       5
0   2   4   6  ...
```

## Headers
All the files in Dat's Storage are considered SLEEP files. However, not all
files require a header. Only the files that have a variable algorithm (such as
hashing, signing) require a SLEEP header.

## Usage in Dat
When you append data, you basically update the Merkle Tree. Updating the Merkle
Tree creates a new Root Hash of the Merkle Tree. For security we need to sign
this Root Hash, so people can trust it's the new one.

It's important to know that everything in Hypercore is a byproduct of appending
data to the Feed. This includes Signatures, Hashes, Root Nodes and more.

### Types of Storage
- __data:__ The concatenated data that was appended to the feed.
- __merkle tree:__ The hashes of the data, and hashes of hashes of data - stored
  in a tree. Also stores the length of the datta.
- __signatures:__ We take the Root Hash of the Merkle Tree, and sign that one.
- __bitfield:__ Space-efficient data structure used to figure out which data you
  have and what data you don't.
- __key:__ Ed25519 Public Key (part of a keypair).
- __secret key:__ Ed25519 Secret Key (part of a keypair).

When you produce a new Signature, the index for the Signature is the same index
as for the data you appended to the Feed.
