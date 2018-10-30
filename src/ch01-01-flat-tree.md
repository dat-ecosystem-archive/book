# Flat Tree
Flat Trees are the core data structure that powers the Dat protocol.

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

Indexes 0, 2, 4, 6 have a depth of 0. And indexes 1, 5, 9 have a depth of 1.

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

## References
- https://gist.github.com/jimpick/54adc72f11f38f1fe4bc1d45d3981708
- https://github.com/jimpick/hypercore-simple-ipld/blob/master/tree-test.js
- https://datatracker.ietf.org/doc/rfc7574/?include_text=1
- https://www.datprotocol.com/deps/0002-hypercore/
