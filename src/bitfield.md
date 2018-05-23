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

If we take the same bits and express it as a flat tree, it looks like this:

```txt
       01
  01       00
01  11   00  00
```

There's a fun implication here: a completely zeroed-out buffer is a valid
Indexed Bitfield - it just means it's completely empty. Even if you express it
as a tree.

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

## Serialization - how to structure on disk
## Implementation

## Run Length Encoding (RLE)
TODO: explain the module. For now read the README.
- https://github.com/mafintosh/bitfield-rle
