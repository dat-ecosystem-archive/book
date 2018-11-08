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
  in a tree. Also stores the length of the data.
- __signatures:__ We take the Root Hash of the Merkle Tree, and sign that one.
- __bitfield:__ Space-efficient data structure used to figure out which data you
  have and what data you don't.
- __key:__ Ed25519 Public Key (part of a keypair).
- __secret key:__ Ed25519 Secret Key (part of a keypair).

When you produce a new Signature, the index for the Signature is the same index
as for the data you appended to the Feed.

## Random Access Storage
Hypercore supports multiple persistence backends through the
`random-access-storage` interface. Each storage backend adheres to a
standardized interface to write, read and delete ranges of bytes.

There are many different backends available, but generally all implementations
implement the following backends:

- `random-access-memory`: stores bytes in-memory. Ideal for testing, and
  providing an initial implementation.
- `random-access-disk`: stores bytes on disk. Generally useful as Hypercore's
  first persistent backend.

Because Hypercore and Dat support partially downloading data, a useful feature
is to implement _sparse persistence_. This means that we can write data into
memory or to disk with spaces in between, but without paying any cost.

For example if we want to write bytes 0 to 10, and bytes 9877 to 11000, the
space between 10 and 9877 should not cost us anything.

This is generally implemented using _pagers_. A pager is a vector (or array)
where each entry is a range. If we want to access a particular range, we lookup
the correct entry in the pager, and allocate it if needed. This way we preserve
space we don't use.

It's generally good to use 1kb pages when accessing memory, and 4kb pages when
accessing disk (SSD). This ensures that data will be written as continuous
chunks, which is good for performance.
