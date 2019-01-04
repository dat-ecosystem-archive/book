# memory-pager

Data in Hypercore streams can be replicated out of order. This means that you
could both have the first message in a feed, and the millionth message in a
feed. To ensure that we don't allocate space for a million messages when we only
have two we make use of a data structure called a _memory pager_.

Memory pagers work by having a vector of pointers to fixed-sized byte buffers.
Each buffer (or page, if you will) is only allocated once there it has data that
needs to be written into it.

## Example
### Writing
Say we have a memory pager with pages that are 4 kilobytes long each. The
initial state would be:

```txt
[]
```

All we have is an empty list with no values.

> 4 kilobytes is a reasonable default for pages, as it maps directly to most
> operating system's page internal paging structures. This means that this can
> generally efficiently be allocated & cleared.

Let's say we want to write the 2000th byte. We need to figure out which page
this will be on. We can do this by dividing the index by the page size, and the
resulting number (integer) is the page we want to index. E.g. `2000 / 1024` =
`1`.

> In languages that don't support integer division, the equivalent of
> `Math.floor()` should be called on the resulting value.

Now that we have the right page number, we need to find the right index on the
page. We can do this by using the modulo operator. E.g. `2000 % (1024 - 1)`
results in index `997`. We subtract 1 from the page size because the first entry
is located a position 0, not position 1.

Putting this together, we need to write the 997th byte on the second page (index
1). This would look as:

```txt
[
  None,
  Some(Vec), // 1024 bytes
]
```

The first page isn't allocated so we put a `None` (or `null`) value there. The
second page (index 1) *is* allocated, so we keep a pointer into the buffer. All
gaps in between bytes are kept as None types.

## Reading
Reading values from the pager can be split up into two operations:

- reading a value from an empty page
- reading a value from an existent page

It's generally recommended that any value read from the memory pager can be an
empty variant (`None` or `null`), as it might not have been written yet. This is
similar to accessing values in most vector implementations.

When a value is read from an empty page, if the page is empty the resulting
value will be empty too.

If the page exists, the index into the buffer must be calculated (see the
Writing section), and that value can be returned.

## Implementation
We can get the page by dividing the index by the page size:

```rust
let page_num = index / (page_size - 1);
let page = get_page(page_num); // get the page from our list.
```

To get the adjusted index into the page, we need to translate the page index:

```rust
let page_index = index % (page_size - 1);
```

Putting these together:

```rust
fn set(index: usize, value: T) {
  let page_num = index / (self.page_size - 1);
  let page = match self.pages.get(page_num) {
    Some(page) => page,
    None => /* allocate a new page and return it */,
  }
  let page_index = index % (page_size - 1);
  page[page_index] = value;
}
```

## References
- [mafintosh/memory-pager](https://github.com/mafintosh/memory-pager)
- [datrs/memory-pager](https://github.com/datrs/memory-pager)
