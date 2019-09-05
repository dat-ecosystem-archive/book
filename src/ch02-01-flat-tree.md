# flat-tree
`flat-tree` is one of the first modules that should be implemented for the Dat
protocol. See [Key Concepts: Flat Tree](/ch01-01-flat-tree.html) for an overview
of how Flat Trees work.

## Core API
The core flat-tree API consists of several methods that can calculate the nodes
relative to each other.

### Children
Returns both children of a node. It cannot return any children when querying a
leaf node, so the result must be a `Null`, `Maybe`, or `Option` type, depending
on the language used.
```rust
pub fn children_with_depth(i: usize, depth: usize) -> Option<(usize, usize)>
```

### count
Returns how many nodes are under the tree that the node spans.
```rust
pub fn count_with_depth(i: usize) -> usize
```

### depth
Returns the depth of a node at a given index.
is removed from the left-most node at its current depth
```rust
pub fn depth(i: usize) -> usize
```

### full_roots
Returns a list of all the full roots (subtrees where all nodes have either 2 or
0 children).
```rust
pub fn full_roots(i: usize) -> Vec<usize>{
```

### index
Return the index for a node at a given depth and offset.
```rust
pub fn index(depth: usize, offset: usize) -> usize
```

### left_child
Return the left child of the node at index.
```rust
pub fn left_child(i: usize) -> Option<usize>
```

### left_span
Returns the left-most child of the node at index.
```rust
pub fn left_span(i: usize) -> usize
```

### offset
Returns the offset of a node at a given index. The offset of a node is how far
it is removed from the left-most node at its current depth
```rust
pub fn offset(i: usize) -> usize
```

### parent
Returns the parent of a node.
```rust
pub fn parent(i: usize) -> usize
```

### right_child
Return the right child of the node at index.
```rust
pub fn right_child(i: usize) -> Option<usize>
```

### right_span
Returns the right-most child of the node at index.
```rust
pub fn right_span(i: usize) -> usize
```
### left_span
Returns the left-most child of the node at index.
```rust
pub fn right_span(i: usize) -> usize
```

### sibling
Returns the node that shares the same parent node.
```rust
pub fn sibling(i: usize) -> usize
```

### spans
Returns a pair of the left-most node in the tree, and the right-most node in the
tree.
```rust
pub fn spans(i: usize) -> (usize, usize)
```

### uncle
Returns the parent's sibling node.
```rust
pub fn uncle(i: usize) -> usize
```

## Iterator API
Some upstream modules require stateful traversal of the tree. It can be
convenient to expose a stateful iterator module as part of `flat-tree` for those
cases.

The iterator should be a constructor that takes an initial index, and exposes
methods to move to child nodes, parent nodes, etc. The iterator should also
expose the index so it can be stored or used for other computations.

## Optimizations
### Calculate Depth
The depth of a node can be calculated by counting the number of tailing zeros in
a number. Languages such as Rust expose `<num>.trailing_zeros()` which counts
the amount of zeros at the end of a number (`cttz` intrinsic). By combining a
bitwise negation (`!` or `NOT` operation) with the `.trailing_zeros()` method,
the amount of trailing ones can be counted. On x86 machines this should be
around 3 instructions when inlined.

### Re-use the depth parameter
Sometimes when calling multiple functions on the same index, depending on the
execution environment it can be efficient to reuse the `depth` parameter.

However if the optimized depth method is used, there's no strict need to expose
the `with_depth*` methods, as the compiler will detect the duplicate
computation, and remove it anyway. Mileage may vary, but this technique has been
tested on LLVM output for the Rust version. In the worst case there might be
penalty of up 3 instructions per call, which seems like a negligible penalty.

### Calculate children
Calculating whether a node has children can be sped up by quickly checking if a
number is even or uneven. If a number is uneven, it's already guaranteed to be a
child node, so it can't have child nodes.

### Spans
Similarly for spans. If an even number is targeted, it is at the bottom of the
tree, so it will only span itself. Therefor it's easy to implement an `is_even`
check, and return the index that was passed in if it's true.

## Full Roots
To prevent allocations `full-roots` could also write to either a pre-allocated
vector, or a stack-allocated collection instead.
