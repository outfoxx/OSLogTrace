// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "OSLogTrace",
  platforms: [
    .iOS(.v10),
    .macOS(.v10_12),
    .watchOS(.v3),
    .tvOS(.v10),
  ],
  products: [
    .library(
      name: "OSLogTrace",
      targets: ["OSLogTrace"]),
  ],
  dependencies: [
    .package(url: "https://github.com/nicklockwood/SwiftFormat.git", .upToNextMinor(from: "0.40.10"))
  ],
  targets: [
    .target(
      name: "OSLogTrace",
      dependencies: [],
      path: "./Sources"
    ),
    .testTarget(
      name: "OSLogTraceTests",
      dependencies: ["OSLogTrace"],
      path: "./Tests")
  ]
)

