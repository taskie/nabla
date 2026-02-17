# nabla

[![ci](https://github.com/taskie/nabla/actions/workflows/ci.yml/badge.svg)](https://github.com/taskie/nabla/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/taskie/nabla/branch/main/graph/badge.svg?token=QIC7IOY4PL)](https://codecov.io/gh/taskie/nabla)

*a differential operator for CLI tools.*

nabla creates patch files by comparing command outputs with original files.

![Example](images/example.gif)

## Examples

### Basic usage

``` console
$ cat 1.txt
foo
$ echo 1.txt | nabla sed 's/foo/bar/g'
--- 1.txt
+++ 1.txt
@@ -1 +1 @@
-foo
+bar
$ echo 1.txt | nabla sed 's/foo/bar/g' | patch -p0
patching file 1.txt
$ cat 1.txt
bar
```

### With a single argument

``` sh
nabla -x sed 's/foo/bar/g' 1.txt
```

### With multiple arguments

``` sh
nabla -X sed 's/foo/bar/g' -- *.txt
```

### As a filter

``` sh
echo foo | nabla -F sed 's/foo/bar/g'
```

Output:

``` diff
--- <stdin>
+++ <stdout>
@@ -1 +1 @@
-foo
+bar
```

### With `find`

``` sh
find . -name '*.txt' | nabla sed 's/foo/bar/g'
# or
find . -name '*.txt' -print0 | nabla -0 sed 's/foo/bar/g'
# or
find . -name '*.txt' -exec nabla -x sed 's/foo/bar/g' '{}' ';'
# or
find . -name '*.txt' -exec nabla -X sed 's/foo/bar/g' -- '{}' +
```

### With `fd`

``` sh
fd '\.txt$' | nabla sed 's/foo/bar/g'
# or
fd -0 '\.txt$' | nabla -0 sed 's/foo/bar/g'
# or
fd '\.txt$' -x nabla -x sed 's/foo/bar/g'
# or
fd '\.txt$' -X nabla -X sed 's/foo/bar/g' --
```

### With `rg`

``` sh
rgdiff() {
    pat="$1"
    rep="$2"
    shift 2
    rg -0l "$pat" "$@" | nabla -0u rg "$pat" -r "$rep" -IN --passthru
}

rgdiff foo bar -g '*.txt'
```

## Usage

``` console
$ nabla --help
nabla creates patch files by comparing command outputs with original files

Usage: nabla [OPTIONS] <CMD> [ARG]...

Arguments:
  <CMD>     Command to execute
  [ARG]...  Command arguments

Options:
  -0, --null                     Handle null-separated input items
  -j, --threads <THREADS>        The approximate number of threads to use [default: 0]
  -u, --unordered                Produce fast unordered output in multi-threaded execution
  -X, --multi-args               Interpret arguments after last '--' as file names
  -x, --single-arg               Interpret the last argument as a file name
  -f, --files-from <FILES_FROM>  File containing file names
  -F, --filter                   Show diff between CMD's stdin and stdout
  -h, --help                     Print help
  -V, --version                  Print version
```

## License

MIT or Apache-2.0
