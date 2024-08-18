// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "trash",
  platforms: [.macOS(.v14)],
  products: [
    .executable(name: "trash", targets: ["trash"])
  ],
  dependencies: [],
  targets: [
    .executableTarget(
      name: "trash",
      dependencies: []
    )
  ]
)
