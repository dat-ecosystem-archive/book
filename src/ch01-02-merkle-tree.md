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

## Hypercore Files
A Hypercore's internal structure typically consist of these files:

- __data:__ a file containing the data added to the Hypercore.
- __tree:__ a file containing the Merkle tree of hashes derived from the data.
- __signatures:__ a file containing the cryptographic signatures of the hashes
    in the tree file.
- __bitfield:__ a file to keep track of which data we have locally, and which
    data is part of the network.
- __public key:__ a file containing the public key. This is used for verifying
    content.
- __secret key:__ a file containing the signing key. This is used for adding new
    content, and is only available on Hypercores you've created.

> The names we're using to refer to files here is also the way they're referred
> to in Hypercore's specs and implementations. When inspecting a `.dat`
> directory you'll see these terms used as suffixes. For example
> as `content.tree`, or `metadata.signatures`.

The tree file is responsible for verifying the integrity of the data that's
being appended to the feed.

The signature file is responsible for ensuring the integrity of the entire tree
at any given state. Every entry in the signature file verifies the current state
of the entire tree file.

> Not every Hypercore is the same. In most implementations of Dat it's possible
> to choose how data is stored. For server applications it makes sense to store
> it in a single file. But for desktop applications it can sometimes make sense
> to store content directly on disk. For example in the case of (hyper)media
> files.

Let's look at how these files relate to each other to create a Hypercore feed.

## Merkle Trees In Theory

Whenever data is added to Hypercore, a new entry is created in the data file. We
then hash the data, and write that hash to a tree file's leaf node. If the leaf
node has a sibling, the parent node's hash can be computed. If the new parent
node has a sibling, we can compute a new parent node above it. We recurse upward
until no more parent nodes can be computed, at which point we'll have reached a
root node.

When there are no more hashes left to compute, we gather all the root nodes in
the tree, concatenate them, hash them, and sign them with our private key. We
then store the signature in our signatures file at the same index of the leaf
node that was added.

This might all sound a little abstract though, so let's look at an example.

## Merkle Trees In Practice
We're starting off with an empty Hypercore feed. We're planning to add 4 pieces
of data to it, one by one: `[A B C D]`.

### Entry 1
Let's add our first piece of data to Hypercore. We insert the value "A" as our
first entry. In order, the following actions happen:

1. We append the data to the data file.
2. We compute a hash (`#0`) from the data, and store it at index `0` in our tree file.
3. We gather all root nodes from our tree file (which is just the node at index
   0 right now), and compute a cryptographic signature from the hash.
4. We append the signature to our signatures file.

__data__
```txt
0: A
```

__tree__
```txt
0: #0 = hash(data[0])
```

__signatures__
```txt
0: sig(#0)
```

### Entry 2
Let's add our second entry to hypercore. We now have more nodes, which means
things are a little different:

1. We append the data to the data file.
2. We compute a hash from the data (`#2`), and store it at index `1` in our tree file.
3. Because `#2` has a sibling hash, we compute a new parent hash (`#1`), and store
   it at index `1`.
3. We gather all root nodes from our tree file, and compute a cryptographic
   signature from the hash. The only root node currently available is `#1`. Note that while we compute `#1` from our tree file, we do not store it there. Only even-numbered hashes are stored in the tree file as the odd-numbered ones can be calculated from them.
4. We append the signature to our signatures file.

> When we talk about "computing a parent hash" it means we concatenate (`+`) the
> hashes from both child nodes, and hash the result. Hashes are always the same
> length, which means every node in the tree is the same length.

__data__
```txt
0: A
1: B
```

__tree__
```txt
0: #0 = hash(data[0]) ─┐
                       #1 = hash(#0 + #2)
1: #2 = hash(data[1]) ─┘
```

__signatures__
```txt
0: sig(#0)
1: sig(#1)
```

### Entry 3
So far so good. We're well on our way to building a full tree-structure! Let's
continue on our journey, and add our third entry: `C`.

1. We append the third piece data to the data file at index `2`.
2. We compute a hash from the data (`#4`), and store it at index `2` in our tree file.
3. We now have two root hashes: `#1` and `#4`. So we concatenate them, hash the
   result, and sign the result.
4. We append the signature to our signatures file.

__data__
```txt
0: A
1: B
2: C
```

__tree__
```txt
0: #0 = hash(data[0]) ─┐
                       #1 = hash(tree[0] + tree[1])
1: #2 = hash(data[1]) ─┘

2: #4 = hash(data[2])
```

__signatures__
```txt
0: sig(#0)
1: sig(#1)
2: sig(#1 + #4)
```

### Entry 4
Let's add the final piece of data to our feed. This will balance out a tree, and
bring us back to only one root hash!

1. We append the fourth piece data to the data file at index `3`.
2. We compute a hash from the data (`#6`), and store it at index `3` in our tree file.
3. Our only root hash is `#3`, so we sign it and compute the signature.
4. We append the signature to our signatures file.

__data__
```txt
0: A
1: B
2: C
3: D
```

__tree__
```txt
0: #0 = hash(data[0]) ─┐
                       #1 = hash(#0 + #2) ─┐
1: #2 = hash(data[1]) ─┘                   │
                                           #3 = hash(#1 + #5)
2: #4 = hash(data[2]) ─┐                   │
                       #5 = hash(#4 + #6) ─┘
3: #6 = hash(data[3]) ─┘
```

__signatures__
```txt
0: sig(#0)
1: sig(#1)
2: sig(#1 + #4)
3: sig(#3)
```

## Verifying A Merkle Tree
TODO

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
