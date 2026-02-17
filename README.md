# ∇ nabla

[![ci](https://github.com/taskie/nabla/actions/workflows/ci.yml/badge.svg)](https://github.com/taskie/nabla/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/taskie/nabla/branch/main/graph/badge.svg?token=QIC7IOY4PL)](https://codecov.io/gh/taskie/nabla)

**nabla** — *a differential operator for CLI tools.*

Runs a command and shows a unified diff between the original input and the command's output, letting you preview changes before applying them with `patch`.

## Installation

```sh
cargo install --git https://github.com/taskie/nabla
```

## Quick start

```sh
# Filter mode (default): pipe stdin through a command and diff
echo foo | nabla sed 's/foo/bar/g'

# File mode: process files specified after --
nabla sed 's/foo/bar/g' -- *.txt

# Apply the diff
nabla sed 's/foo/bar/g' -- *.txt | patch -p0
```

## How it works

nabla selects its operating mode automatically:

| Condition | Mode | Description |
|---|---|---|
| `-f FILE` given | File list | Read file paths from `FILE` (`-f -` for stdin) |
| `--` in arguments | File | Arguments after the last `--` are file paths |
| Otherwise | Filter | Read stdin, pipe through command, diff the output |

In **file mode**, nabla reads each file, runs the command with the file path appended, and diffs the output against the original content.

In **filter mode**, nabla passes stdin to the command's stdin and diffs `<stdin>` vs `<stdout>`.

## Examples

### Filter mode

```sh
echo foo | nabla sed 's/foo/bar/g'
```

```diff
--- <stdin>
+++ <stdout>
@@ -1 +1 @@
-foo
+bar
```

### File mode

```console
$ nabla sed 's/foo/bar/g' -- 1.txt
--- 1.txt
+++ 1.txt
@@ -1 +1 @@
-foo
+bar
```

> **Note:** If the command itself requires `--` as an argument, use `-f` to pass file paths instead.

### Reading file paths from stdin

```sh
find . -name '*.txt' | nabla -f - sed 's/foo/bar/g'
```

### Parallel execution

When processing multiple files, nabla uses all available CPU cores by default.
Use `-j` to limit the number of threads, or `-u` to allow unordered output for better throughput:

```sh
nabla -j4 sed 's/foo/bar/g' -- *.txt
nabla -u sed 's/foo/bar/g' -- *.txt
```

### Controlling file path position with `-I`

By default, nabla appends the file path as the last argument.
Use `-I` to place it at an arbitrary position:

```sh
nabla -I '{}' sh -c 'sed s/foo/bar/g < {}' -- *.txt
```

### Recipes

With `find`:

```sh
find . -name '*.txt' | nabla -f - sed 's/foo/bar/g'
find . -name '*.txt' -print0 | nabla -0 -f - sed 's/foo/bar/g'
find . -name '*.txt' -exec nabla sed 's/foo/bar/g' -- '{}' +
```

With `fd`:

```sh
fd '\.txt$' | nabla -f - sed 's/foo/bar/g'
fd -0 '\.txt$' | nabla -0 -f - sed 's/foo/bar/g'
fd '\.txt$' -X nabla sed 's/foo/bar/g' --
```

With `rg` (search-and-replace with diff preview):

```sh
rg -0l 'foo' -g '*.txt' | nabla -f - -0u rg 'foo' -r 'bar' -IN --passthru
```

## Usage

```console
$ nabla --help
nabla creates patch files by comparing command output with original files

Usage: nabla [OPTIONS] <CMD> [ARG]...

Arguments:
  <CMD>     Command to execute
  [ARG]...  Command arguments

Options:
  -0, --null                             Read NUL-delimited input
  -j, --jobs <JOBS>                      Approximate number of parallel jobs [default: 0]
  -u, --unordered                        Allow unordered output for faster parallel execution
  -f, --files-from <FILES_FROM>          Read file paths from a file
  -I, --replace-str <REPLACE_STR>        Replace occurrences of REPLACE_STR in arguments with the file path
  -h, --help                             Print help
  -V, --version                          Print version
```

## License

[MIT](LICENSE-MIT) OR [Apache-2.0](LICENSE-APACHE)
