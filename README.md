# nablex

[![ci](https://github.com/taskie/nablex/actions/workflows/ci.yml/badge.svg)](https://github.com/taskie/nablex/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/taskie/nablex/branch/main/graph/badge.svg?token=QIC7IOY4PL)](https://codecov.io/gh/taskie/nablex)

**nablex** — *diff what your command would change.*

![Example](images/example.gif)

## Installation

```sh
cargo install --git https://github.com/taskie/nablex
```

## Quick start

```sh
# Filter mode (default): pipe stdin through a command and diff
echo foo | nablex sed 's/foo/bar/g'

# File mode: process files specified after :::
nablex sed 's/foo/bar/g' ::: *.txt

# Apply the diff
nablex sed 's/foo/bar/g' ::: *.txt | patch -p0
```

## How it works

nablex selects its operating mode automatically:

| Condition | Mode | Description |
|---|---|---|
| `-f FILE` given | File list | Read file paths from `FILE` (`-f -` for stdin) |
| `:::` in arguments | File | Arguments after the last `:::` are file paths |
| Otherwise | Filter | Read stdin, pipe through command, diff the output |

In **file mode**, nablex reads each file, runs the command with the file path appended, and diffs the output against the original content.

In **filter mode**, nablex passes stdin to the command's stdin and diffs `<stdin>` vs `<stdout>`.

## Examples

### Filter mode

```sh
echo foo | nablex sed 's/foo/bar/g'
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
$ nablex sed 's/foo/bar/g' ::: 1.txt
--- 1.txt
+++ 1.txt
@@ -1 +1 @@
-foo
+bar
```

### Reading file paths from stdin

```sh
find . -name '*.txt' | nablex -f - sed 's/foo/bar/g'
```

### Parallel execution

When processing multiple files, nablex uses all available CPU cores by default.
Use `-j` to limit the number of threads, or `-u` to allow unordered output for better throughput:

```sh
nablex -j4 sed 's/foo/bar/g' ::: *.txt
nablex -u sed 's/foo/bar/g' ::: *.txt
```

### Controlling file path position with `-I`

By default, nablex appends the file path as the last argument.
Use `-I` to place it at an arbitrary position:

```sh
nablex -I '{}' sh -c 'sed s/foo/bar/g < {}' ::: *.txt
```

### Recipes

With `find`:

```sh
find . -name '*.txt' | nablex -f - sed 's/foo/bar/g'
find . -name '*.txt' -print0 | nablex -f - -0 sed 's/foo/bar/g'
find . -name '*.txt' -exec nablex sed 's/foo/bar/g' ::: '{}' +
```

With `fd`:

```sh
fd '\.txt$' | nablex -f - sed 's/foo/bar/g'
fd -0 '\.txt$' | nablex -f - -0 sed 's/foo/bar/g'
fd '\.txt$' -X nablex sed 's/foo/bar/g' :::
```

With `rg` (search-and-replace with diff preview):

```sh
rg -0l 'foo' -g '*.txt' | nablex -f - -0u rg 'foo' -r 'bar' -IN --passthru
```

## Usage

```console
$ nablex -h
nablex creates patch files by comparing command output with original files

Usage: nablex [OPTIONS] <CMD> [ARG]...

Arguments:
  <CMD>     Command to execute
  [ARG]...  Arguments for CMD; use ':::' to separate CMD args from file paths

Options:
  -0, --null                       Use NUL as the path delimiter instead of newline (for use with -f or find -print0)
  -j, --jobs <JOBS>                Number of parallel jobs (0 = auto-detect) [default: 0]
  -u, --unordered                  Allow unordered output for faster parallel execution
  -f, --files-from <FILE>          Read file paths from FILE ('-' for stdin)
  -I, --replace-str <REPLACE_STR>  Replace occurrences of REPLACE_STR in arguments with the file path
  -s, --skip-unreadable            Skip unreadable files with a warning instead of aborting
  -h, --help                       Print help (see more with '--help')
  -V, --version                    Print version
```

Run `nablex --help` for a full description of operating modes.

## License

[MIT](LICENSE-MIT) OR [Apache-2.0](LICENSE-APACHE)
