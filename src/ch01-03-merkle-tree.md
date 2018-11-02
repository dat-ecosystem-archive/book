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

## Root Nodes
If the number of leaf nodes is a multiple of 2 the flat tree will only have a
single root. Otherwise it'll have more than one.

```txt
Roots for record 0 (stored at leaf 0): [ 0 ]
0: 0
```

```txt
Roots for record 1 (stored at leaf 2): [ 1 ]
0: 0─┐
     1
1: 2─┘
```

```txt
Roots for record 2 (stored at leaf 4): [ 1, 4 ]
0: 0─┐  
     1  
1: 2─┘  
        
2: 4    
```

```txt
Roots for record 3 (stored at leaf 6): [ 3 ]
0: 0─┐  
     1─┐
1: 2─┘ │
       3
2: 4─┐ │
     5─┘
3: 6─┘  
```

```txt
Roots for record 4 (stored at leaf 8): [ 3, 8 ]
0: 0─┐    
     1─┐  
1: 2─┘ │  
       3  
2: 4─┐ │  
     5─┘  
3: 6─┘    
          
4: 8      
```

```txt
Roots for record 5 (stored at leaf 10): [ 3, 9 ]
0:  0──┐      
       1──┐   
1:  2──┘  │   
          3   
2:  4──┐  │   
       5──┘   
3:  6──┘      
              
4:  8──┐      
       9      
5: 10──┘ 
```

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
