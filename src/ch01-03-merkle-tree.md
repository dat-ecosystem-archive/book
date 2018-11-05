# Merkle Tree
Merkle Trees in Dat are specialized [Flat Trees](./ch01-01-flat-tree) that
contain the content of the archives.

In this section we'll cover how Merkle Trees work, and how we use them inside
Hypercore.

## What Are Merkle Trees?
Wikipedia defines a Merkle Tree as:

> A hash tree or Merkle tree is a tree in which every leaf node is labelled with
> the hash of a data block and every non-leaf node is labelled with the
> cryptographic hash of the labels of its child nodes.

In `flat-tree` terminology this means all leaf nodes (even numbers) contain
hashes of data, and all uneven numbers (parent nodes) contain hashes.

Take the following tree:
```txt
  0──┐
     1──┐
  2──┘  │
        3
  4──┐  │
     5──┘
  6──┘
```

- Nodes 0, 2, 4, and 6 contain the hashes of data.
- Node 1 contains the hash of hashes from nodes 0 and 2.
- Node 5 contains the hash of hashes from nodes 4 and 6.
- Node 3 contains the hash of hashes from nodes 1 and 5.

## Merkle Trees In Hypercore
A Hypercore's internal structure typically typically of these files:

- __data file:__ a file containing the data added to the Hypercore.
- __tree file:__ a file containing the Merkle tree of hashes derived from the
    data.
- __signature file:__ a file containing the cryptographic signatures of the
    hashes in the tree file.
- __bitfield file:__ a file to keep track of which data we have locally, and
    which data is part of the network.
- __public key:__ a file containing the public key. This is used for verifying
    content.
- __secret key:__ a file containing the signing key. This is used for adding new
    content, and is only available on Hypercores you've created.

> We're referring to the file containing the Merkle tree as the "tree file"
> to keep the terminology in this guide consistent with the Dat protocol
> specifications and implementations.

The tree file is responsible of verifying the integrity of the data that's
being appended to the feed.

The signature file is responsible for ensuring the integrity of the entire tree
at any given state. Every entry in the signature file verifies the current state
of the entire tree file.

> Not every Hypercore is the same. In most implementations of Dat it's possible
> to choose how data is stored. For server applications it makes sense to store
> it in a single file. But for desktop applications it can sometimes make sense
> to store content directly on disk. For example in the case of (hyper)media
> files.

Whenever data is added to Hypercore, a new entry is created in the data file. We
then then hash

This might all sound a little abstract though, so let's look at an example.

## Merkle Trees In Practice
We're starting off with an empty Hypercore feed. We're planning to add 5 pieces
of data to it, one by one: `[A B C D E]`.

Let's start off by adding the first piece of data to the file.

### Todo
- If a data entry into the Merkle tree has a sibling, it'll try and complete as
  much of the tree above it as possible.
- When a new entry to the tree is added, a new signature must be added to the
  signatures file too.
- The way signatures are added is by gathering all the Root nodes (e.g. nodes
  with no siblings), and concatenating them, and computing their hash. Once the
  hash is computed, we use our private key to sign the hash, and store the
  resulting signature at the next unfilled position in the signatures tree.

```txt
Roots for record 0 (stored at leaf 0): [ 0 ]
0: 0

Roots for record 1 (stored at leaf 2): [ 1 ]
0: 0─┐
     1
1: 2─┘

Roots for record 2 (stored at leaf 4): [ 1, 4 ]
0: 0─┐
     1
1: 2─┘

2: 4
```

## Root Nodes
If the number of leaf nodes is a multiple of 2 the flat tree will only have a
single root. Otherwise it'll have more than one.

## Storage Format
The format of the each node in the Merkle Tree on disk is a series of 40 byte
buffers. The first 32 bytes is the hash. The next 8 bytes is the byte size of
the spanning tree.

The format for storing nodes is:
- 32 byte header which starts with a magic number to indicate what type of file
  it is.
- Then a series of nodes, where each index in the sequence corresponds to a
  position in the Flat Tree.

To read the 6th node from disk (flat tree node `#5`), you'd use an offset into
the file of `32 + 5 * 40`, and then read `40` bytes. The first 32 bytes are the
hash. The last 8 bytes is the combined length of the data nodes `#4` and `#6` are
referencing. The length is encoded as `uint64` Big Endian.

## References
- https://gist.github.com/jimpick/54adc72f11f38f1fe4bc1d45d3981708
- https://github.com/datrs/tree-index/issues/7#issuecomment-419086236
