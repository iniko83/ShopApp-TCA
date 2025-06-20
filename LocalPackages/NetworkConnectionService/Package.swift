// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NetworkConnectionService",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "NetworkConnectionService",
      targets: ["NetworkConnectionService"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "NetworkConnectionService",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
  ]
)
