# Trash

A simple tool for programatically trashing selected files in MacOS Finder.

Supports files passed as arguments or from standard input, either as absolute or
relative paths.

## Installation

### Prerequisites

- macOS 10.15 (Catalina) or later
- Xcode and the Command Line Tools installed

### From source

Clone the repository and navigate to the project directory:

```sh
git clone https://github.com/bzimmer/trash.git
cd trash
```

Build:

```sh
task build
```

## Usage

```
trash [-0] [--] [files...]
  -0: Expect NUL (`\0`)-terminated filename strings on stdin
  --: End of options processing; all subsequent arguments are files
```

Either absolute and relative paths may be supplied, and may be mixed in the same
invocation. Relative paths will be resolved from the current working directory.

Paths may be passed as arguments, or from standard input, but not both. If
supplied via arguments whilst stdin has data available, then stdin will be
ignored and the arguments will be used, and a warning will be issued. This
warning is suppressed by the `--` option.

Always supply the `--` option when passing filename(s) via arguments from within
another script/application. Not only does it silence the warning, this prevents
misbehaviour when a relative path begins with a hyphen.

## Examples

### Trash files passed as arguments:

```sh
trash file1.txt file2.txt
```

### Find and trash files with a PDF extension in your Documents folder and subfolders:

```sh
fd -0 -e pdf . ~/Documents | trash -0
```

Alternatively:

```sh
fd -e pdf . ~/Documents -X trash {}
```

### Trash a file supplied from user input:

```sh
read -p 'file: ' FILENAME
trash -- "$FILENAME"
```

## Credits

Shamelessly borrowed the concept and much of the code from
[reveal](https://github.com/inopinatus/reveal), a tool I used nearly daily. The
primary changes are reformatting and the action of revealing files was changed
to trashing them.
