// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeRSS",
  platforms: [.macOS(.v13)],
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
