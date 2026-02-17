# nabla

[![ci](https://github.com/taskie/nabla/actions/workflows/ci.yml/badge.svg)](https://github.com/taskie/nabla/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/taskie/nabla/branch/main/graph/badge.svg?token=QIC7IOY4PL)](https://codecov.io/gh/taskie/nabla)

*a differential operator for CLI tools.*

nabla creates patch files by comparing command output with original files.

![Example](images/example.gif)

## Examples

### Basic usage

``` console
$ cat 1.txt
foo
$ nabla sed 's/foo/bar/g' -- 1.txt
--- 1.txt
+++ 1.txt
@@ -1 +1 @@
-foo
+bar
$ nabla sed 's/foo/bar/g' -- 1.txt | patch -p0
patching file 1.txt
$ cat 1.txt
bar
```

### With multiple files

``` sh
nabla sed 's/foo/bar/g' -- *.txt
```

> **Note:** `--` is used to separate command arguments from file paths.
> If the command itself requires `--` as an argument, use `-f` to pass file paths instead.

### Filter mode (default)

``` sh
echo foo | nabla sed 's/foo/bar/g'
```

Output:

``` diff
--- <stdin>
+++ <stdout>
@@ -1 +1 @@
-foo
+bar
```

### With file list from stdin

``` sh
echo 1.txt | nabla -f - sed 's/foo/bar/g'
```

### With `find`

``` sh
find . -name '*.txt' | nabla -f - sed 's/foo/bar/g'
# or
find . -name '*.txt' -print0 | nabla -0 -f - sed 's/foo/bar/g'
# or
find . -name '*.txt' -exec nabla sed 's/foo/bar/g' -- '{}' +
```

### With `fd`

``` sh
fd '\.txt$' | nabla -f - sed 's/foo/bar/g'
# or
fd -0 '\.txt$' | nabla -0 -f - sed 's/foo/bar/g'
# or
fd '\.txt$' -X nabla sed 's/foo/bar/g' --
```

### With `rg`

``` sh
rgdiff() {
    pat="$1"
    rep="$2"
    shift 2
    rg -0l "$pat" "$@" | nabla -0u -f - rg "$pat" -r "$rep" -IN --passthru
}

rgdiff foo bar -g '*.txt'
```

## Usage

``` console
$ nabla --help
nabla creates patch files by comparing command output with original files

Usage: nabla [OPTIONS] <CMD> [ARG]...

Arguments:
  <CMD>     Command to execute
  [ARG]...  Command arguments

Options:
  -0, --null                     Read NUL-delimited input
  -j, --jobs <JOBS>              Approximate number of parallel jobs [default: 0]
  -u, --unordered                Allow unordered output for faster parallel execution
  -f, --files-from <FILES_FROM>  Read file paths from a file
  -h, --help                     Print help
  -V, --version                  Print version
```

## License

MIT or Apache-2.0
