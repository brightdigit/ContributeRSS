// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeRSS",
  // Matches the root package floor (raised to .v15 for issue #44); the vendored
  // Publish stack also requires macOS 15 (Synchronization.Mutex).
  platforms: [.macOS(.v15)],
  products: [
    .library(
      name: "ContributeRSS",
      targets: ["ContributeRSS"]
    )
  ],
  dependencies: [
    .package(path: "../../BrightDigit/Contribute"),
    .package(path: "../../BrightDigit/SyndiKit")
  ],
  targets: [
    .target(
      name: "ContributeRSS",
      dependencies: [
        "Contribute",
        .product(name: "SyndiKit", package: "SyndiKit")
      ]
    )
  ]
)
