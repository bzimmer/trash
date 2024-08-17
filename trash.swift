#!/usr/bin/swift

import AppKit
import Foundation

enum ExitCode: Int32 {
  case success
  case fileDoesNotExist
  case unknownError
}

let progname = URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent

func warn(_ message: String, when: Bool = true) {
  guard when else { return }
  fputs("\(message)\n", stderr)
}

func warnx(_ message: String, when: Bool = true) {
  warn("\(progname): \(message)", when: when)
}

func usage() {
  warn("usage: \(progname) [-0] [--] [files...]")
  warn("  -0: Expect NUL ('\\0')-terminated filename strings on stdin")
  warn("  --: End of options processing; all subsequent arguments are files")
  exit(1)
}

func isInputAvailable() -> Bool {
  var pollFD = pollfd(fd: STDIN_FILENO, events: Int16(POLLIN), revents: 0)
  return poll(&pollFD, 1, 0) > 0 && (pollFD.revents & Int16(POLLIN)) != 0
}

struct InputSplitter: IteratorProtocol {
  enum Separator: UInt8 {
    case null = 0
    case lineFeed = 10
  }
  let separator: Separator
  var buffer = Data(capacity: Int(PATH_MAX))

  mutating func result() -> String? {
    defer { buffer.removeAll(keepingCapacity: true) }
    return buffer.isEmpty ? nil : String(data: buffer, encoding: .utf8)
  }
  mutating func next() -> String? {
    var char: UInt8 = 0
    while read(STDIN_FILENO, &char, 1) == 1 {
      if char == separator.rawValue {
        return result()
      }
      buffer.append(char)
    }
    return result()
  }
}

var nullSeparated = false
var fileArguments = false

var args = CommandLine.arguments.dropFirst()
loop: while let arg = args.first, arg.starts(with: "-") {
  args = args.dropFirst()

  switch arg {
  case "-0":
    nullSeparated = true
  case "--":
    fileArguments = true
    break loop
  default:
    warnx("invalid option: \(arg)")
    usage()
  }
}

if !(fileArguments || args.isEmpty) {
  fileArguments = true
  warnx("ignoring input on stdin due to file arguments", when: isInputAvailable())
}
warnx("ignoring -0 option due to file arguments", when: fileArguments && nullSeparated)

let urls =
  (fileArguments
  ? AnySequence(args)
  : AnySequence { InputSplitter(separator: nullSeparated ? .null : .lineFeed) })
  .compactMap { URL(fileURLWithPath: $0).absoluteURL }

var exitCode = ExitCode.success
for url in urls where exitCode.rawValue < ExitCode.unknownError.rawValue {
  do {
    try FileManager.default.trashItem(at: url, resultingItemURL: nil)
  } catch CocoaError.fileNoSuchFile {
    exitCode = ExitCode.fileDoesNotExist
    warn("invalid path: \(url.path)")
  } catch {
    exitCode = ExitCode.unknownError
    warn("unexpected error: \(error)")
  }
}
exit(exitCode.rawValue)
