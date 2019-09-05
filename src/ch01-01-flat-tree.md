# Flat Tree
Flat Trees are the core data structure that power Dat's Hypercore feeds. They
allow us to deterministically represent a tree structure as a vector. This is
particularly useful because vectors map elegantly to disk and memory.

Because Flat Trees are deterministic and pre-computed, there is no overhead to
using them. In effect this means that Flat Trees are a specific way of indexing
into a vector more than they are their own data structure. This makes them
uniquely efficient and convenient to implement in a wide range of languages.

## Thinking About Flat Trees
You can represent a binary tree in a simple flat list using the following
structure:

```txt
      3
  1       5
0   2   4   6  ...
```

Let's rotate the tree on its side for notational purposes:

```txt
 0─┐
   1─┐
 2─┘ │
     3
 4─┐ │
   5─┘
 6─┘
```

Each number represents an **index** in a flat list. Given the tree:

```txt
 D─┐
   B─┐
 E─┘ │
     A
 F─┐ │
   C─┘
 G─┘
```

The way this would be expressed in-memory would be as the list (vector):
`[D B E A F C G]` or `[0 1 2 3 4 5 6]`.

## Depth

Indexes 0, 2, 4, 6 have a depth of 0. And indexes 1 and 5 have a depth of 1.

```text
depth = 2  ^        3
depth = 1  |    1       5
depth = 0  |  0   2   4   6  ...
```

If we convert the graph to a chart we could express it as such:

```text
depth = 0 | 0 2 4 6
depth = 1 | 1 5
depth = 2 | 3
depth = 3 |
```

Now let's add numbers up to 14:

```text
depth = 0 | 0 2 4 6 8 10 12 14
depth = 1 | 1 5 9 13
depth = 2 | 3 11
depth = 3 | 7
```

### Node Kinds

You might be noticing that the numbers at `depth = 0` is vastly greater than the
amount of numbers at every other depth. We refer to nodes at `depth = 0` as
`leaf nodes`, and nodes at every other depth as `parent nodes`.

```text
leaf nodes   | 0 2 4 6 8 10 12 14
parent nodes | 1 3 5 7 9 11 13
```

An interesting aspect of flat trees is that the number of `leaf nodes` and
number of `parent nodes` is in perfect balance. This comes to an interesting
insight:

- All __even indexes__ refer to `leaf nodes`.
- All __uneven indexes__ refer to `parent nodes`.

The depth of a tree node can be calculated by counting the number of trailing 1s
a node has in binary notation.

```txt
5 in binary = 101 (one trailing 1)
3 in binary = 011 (two trailing 1s)
4 in binary = 100 (zero trailing 1s)
```

## Offset
When reading about flat-trees the word `offset` might regularly pop up. This
refers to the offset from the left hand side of the tree.

In the following tree the indexes with an offset of 0 are: `[0 1 3 7]`:

```text
(0)┐
  (1)┐
 2─┘ │
    (3)┐
 4─┐ │ │
   5─┘ │
 6─┘   │
      (7)
```

In the next tree the indexes with an offset of 1 are: `[2 5 11]`:

```text
  0──┐
     1──┐
 (2)─┘  │
        3──┐
  4──┐  │  │
    (5)─┘  │
  6──┘     │
           7
  8──┐     │
     9──┐  │
 10──┘  │  │
      (11)─┘
 12──┐  │
    13──┘
 14──┘
```

## Relationships Between Nodes
When describing nodes we often also talk about the relationship between nodes.
This includes words such as `uncle`, and `parent`.

Take this example tree:

```txt
 0─┐
   1─┐
 2─┘ │
     3─┐
 4─┐ │ │
   5─┘ │
 6─┘   │
       7
 8
```

- __parent:__ A parent has two children under it, and is always odd-numbered.
    Node 3 is the parent of 1 and 5.
- __leaf:__ A node with no children. A leaf node is always even-numbered.
    Nodes 0, 2, 4, 6 and 8 are leaf nodes.
- __sibling:__ The other node that shares a parent with the current node. For
    example nodes 4 and 6 are siblings.
- __uncle:__ A parent's sibling. Node 1 is the uncle of nodes 4 and 6.
- __root:__ A top-most node where the full tree under it is complete (e.g. all
    parent nodes have 2 children). Node 3 is a root node.
- __span:__ The two nodes that are furthest away in the sub-tree. The span of
    node 1 is `0, 2`. The span of node 3 is `0, 6`.
- __right span:__ The left-most node in the span. The right span of node 1 is 2.
    The right span of node 3 is 6.

## References
- https://gist.github.com/jimpick/54adc72f11f38f1fe4bc1d45d3981708
- https://github.com/jimpick/hypercore-simple-ipld/blob/master/tree-test.js
- https://datatracker.ietf.org/doc/rfc7574/?include_text=1
- https://www.datprotocol.com/deps/0002-hypercore/
