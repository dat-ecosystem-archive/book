# Merkle Tree Stream

We covered how Dat's Merkle Trees work in the [Merkle Tree
Chapter](/ch01-02-merkle-tree.html). In this chapter we'll discuss how to
implement it, and what to look out for when optimizing.

## Core Abstraction
At its core, the merkle tree stream is a stateful algorithm. It takes data in
(leaf nodes), hashes it, and computes as many parent hashes as it can.

At its core this can be expressed as a stateful class that has a `.append()` or
`.next()` method. Internally it keeps track of three properties:

- An index to keep track of how far along in the sequence we are.
- A vector of hashes.
- The current roots.

To prevent allocations, both the vector of hashes and current roots could be
passed in externally, but this is not a requirement.

## Methods
`merkle-tree-stream` should operate as a generic structure without tying itself
to any particular hash function. This means that when creating an instance, the
methods have to be passed in. The following methods are generally required:

- __leaf:__ takes data in, and produces a hash of the data.
- __parent:__ takes two hashes, and produces a new hash.

In strictly typed languages, both the input `data`, and `hash` need to be passed
as type parameters into the generic function. In dynamically typed languages,
both can generally be expressed as byte array.

## Async
In practice it's perfectly fine to write the stream as a synchronous method.
For most implementations of Dat I/O typically tends to be the bottleneck, but on
a live system that might not always be the case (e.g. contention with other
resources). So to improve the overall performance of `merkle-tree-stream`, it
can be useful to schedule work over multiple cores.

The first candidate for parallelization is hashing the leaf nodes.
