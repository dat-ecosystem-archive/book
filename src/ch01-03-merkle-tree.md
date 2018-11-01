# Merkle Tree
The format of the each node in the Merkle Tree on disk is a series of 40 byte
buffers. The first 32 bytes is the hash. The next 8 bytes is the byte size of
the spanning tree.

```txt
  0──┐
     1──┐
  2──┘  │
        3──┐
  4──┐  │  │
     5──┘  │
  6──┘     │
           7
  8──┐
     9
 10──┘
```

## Storage Format
The format for storing nodes is:
- 32 byte header which starts with a magic number to indicate what type of file
  it is.
- Then a series of nodes, where each index in the sequence corresponds to a
  position in the Flat Tree.

To read the 6th node from disk (flat tree node `#5`), you'd use an offset into
the file of `32 + 5 * 40`, and then read `40` bytes. The first 32 bytes are the
hash. The last 8 bytes is the combined length of the data nodes `#4` and `#6` are
referencing. The length is encoded as `uint64` Big Endian.
