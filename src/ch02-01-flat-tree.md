# flat-tree
`flat-tree` is one of the first modules that should be implemented for the Dat
protocol. See [Key Concepts: Flat Tree](/ch01-01-flat-tree.html) for an overview
of how Flat Trees work.

## Core API
The core flat-tree API consists of several methods that can calculate the nodes
relative to each other.

### children
Returns both children of a node. It cannot return any children when querying a
leaf node, 
```rust
pub fn children_with_depth(i: usize, depth: usize) -> Option<(usize, usize)>
```

### count
### depth
Returns the depth of a node at a given index.
is removed from the left-most node at its current depth
```rust
pub fn depth(i: usize) -> usize
```

### full_roots
### index
Return the index for a node at at given depth and offset.
```rust
pub fn index(depth: usize, offset: usize) -> usize
```

### left_child
### left_span
### offset
Returns the offset of a node at a given index. The offset of a node is how far
it is removed from the left-most node at its current depth

### parent
### right_child
### right_span
### sibling
### spans
### uncle

## Iterator API

## Optimizations
### Calculate Depth
The depth of a node can be calculated

### Re-use the depth parameter
Sometimes when calling multiple functions on the same index, depending on the
execution environment it can be efficient to reuse the `depth` parameter.
Between those calls.

In the case of 
