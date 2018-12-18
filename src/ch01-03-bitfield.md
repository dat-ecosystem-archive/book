# Bitfield
## What is a bitfield?
Space-efficient data structure used to figure out which data you have and what
data you don't. Meant to always be kept in memory because it's small enough.

At its core, bitfields are a way of efficiently describing sets of numbers. You
can think of them as a series of bits. When a number at a position is 1, it
means that position is in the set. If a number is 0, that position isn't.

### Example
```txt
bits:  00101
index: 01234
```
The set above contains `2` and `4`. It's stored left to right, because that's
the way it's enumerated.

In Dat we use bitfields to describe which pieces of data we have, and which
pieces of data we don't. Also it's used internally to index data structures,
such as the Merkle Tree.

## Indexed Bitfields
The most common operations in Dat for bitfields is to either find a piece of
data that's missing, or checking if we have a piece of data.

Checking if we have a piece of data is straightforward, as all we have to do is
look in the bitfield in the position of the data and see if it's a `1`.

Finding a piece of data we're missing is a bit more tricky. Basically it'll
require a linear scan of the whole bitfield. In order to speed this up, we use
an Indexed Bitfield.

### Structure
At a high level Indexed Bitfields are a binary tree structure where each node is
made up out of 2 bits.

- `11` indicates all bits under this node are `1`s.
- `00` indicates all bits under this node are `0`s.
- `10` indicates bits under this node are a mixture of `1`s and `0`s.
- `01` is currently unused and reserved for (possible) future purposes.

We call this the Tree Index Scheme.

Consider this Indexed Bitfield, written as a sequence of bits:

```txt
01011101000000
```

Because the bits are indexed as a flat-tree, we can print it as a tree
structure:

```txt
       01
  01       00
01  11   00  00
```
By looking at the root node we can tell that there's nodes in the tree, but not
yet _which_ nodes are in the tree. By going one level lower however, it becomes
clear that there's nodes in one side of the tree, but no nodes in the other side
of the tree. This means we only need to check the children of the left node to
find out exactly which nodes we have.

A fun fact here is also: a completely zeroed-out buffer is a valid Indexed
Bitfield - it just means it's completely empty.

### Optimizing the Structure
Looking at a byte and looking at a bit is the same cost in a computer. You want
to optimize for getting the most information possible when looking at a byte.

Therefore in order get the most performance out of our structure, we want to
construct our tree using bytes instead of pairs of bits.

Consider the following scheme. Given two bytes: `A` `B`. Take each of them, and
split each of them into pairs of two bits. We'll use `a1 a2 a3 a4` to indicate
the pairs in `A`. And `b1 b2 b3 b4` to indicate the pairs in `B`.

The parent of `A` and `B` is `C`. `C` is constructed by applying the Tree Index
Scheme to each pair of bits.

```txt
                [a1 + a2, a3 + a4, b1 + b2, b3 + b4]
[a1, a2, a3, a4]                                    [b1, b2, b3, b4]
```

In the example above, we use the `+` operator to indicate the application of the
Tree Index Scheme.

In the future we might make this even more efficient using `SIMD` instructions,
which can operate on more bits at the same time.

## Lookup Tables
An efficient implementation of the previous scheme can be done using lookup
tables for values between between 0 and 256.

This is all solely for performance and completely optional. The important part
is that the indexing scheme is followed.

## Types of Bitfields
We have 3 bitfields:
- __Data Bitfield:__ Indicates which data you have, and which data you don't.
- __Indexed Bitfield:__ Helps efficiently search through the Data Bitfield using
  the Tree Index Scheme.
- __Merkle Tree Bitfield:__ Indicates which nodes in the Merkle Tree you have,
  and which nodes you don't.

This means that whenever you update the Data Bitfield, you must also update
the Indexed Bitfield.


### Updating a Byte
If we want to set an index in a bitfield to `false`, it would mean we needed to
flip a bit to `0`. Because we can only operate on bytes, the easiest way to
achieve this is to apply a bitmask.

Consider the following lookup table, in binary notation:

```rust
let data_update = vec![
  0b01111111, // 127
  0b10111111, // 191
  0b11011111, // 223
  0b11101111, // 239
  0b11110111, // 247
  0b11111011, // 251
  0b11111101, // 253
  0b11111110, // 254
];
```

There are 8 entries in this table, all of which have a different position of
which bit is set to zero. When you want to flip a bit to zero, you take the
index of the bit you want to flip, look up the entry in the table, and bitwise
AND the two numbers.

## Serialization
For every piece of data there's going to be 1 bit in the Data Bitfield. And
2 bits in the Merkle Tree Bitfield because there's a parent node and a leaf
node. There are going to be as many parents as there will be leaves.

Every time there's 16 bits in the Data Bitfield, the Indexed Bitfield needs 2
bits to indicate if it's all `1`s, `0`s, or a mixture. And 2 bits for the Tree
Index Scheme, totalling 4 bits in the Indexed Bitfield.

So this translates to the following ratios:
- __Data:__ 1024 bytes.
- __Merkle Tree:__ 2048 bytes.
- __Indexed Tree:__ 256 bytes.

## Run Length Encoding
When sending data over the wire, we want to compress the bitfields further. An
efficient way of doing this is by using Run Length Encoding (RLE).
TODO: explain the module. For now read the README.
- [mafintosh/bitfield-rle](https://github.com/mafintosh/bitfield-rle)
