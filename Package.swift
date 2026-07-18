// swift-tools-version:6.4
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "ContributeRSS",
  // macOS 15 matches the root / Publish stack (Synchronization.Mutex).
  // iOS/tvOS/watchOS floors match remote SyndiKit consumption in standalone CI.
  platforms: [
    .macOS(.v15),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9)
  ],
  products: [
    .library(
      name: "ContributeRSS",
      targets: ["ContributeRSS"]
    )
  ],
  dependencies: [
    .package(name: "Contribute", path: "../../BrightDigit/Contribute"),
    .package(name: "SyndiKit", path: "../../BrightDigit/SyndiKit")
  ],
  targets: [
    .target(
      name: "ContributeRSS",
      dependencies: [
        "Contribute",
        .product(name: "SyndiKit", package: "SyndiKit")
      ]
    ),
    .testTarget(
      name: "ContributeRSSTests",
      dependencies: ["ContributeRSS"]
    )
  ]
)
