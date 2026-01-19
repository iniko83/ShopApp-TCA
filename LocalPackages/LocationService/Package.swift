// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LocationService",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "LocationService",
      targets: ["LocationService"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.9.2"),
  ],
  targets: [
    .target(
      name: "LocationService",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .testTarget(
      name: "LocationServiceTests",
      dependencies: ["LocationService"]
    ),
  ]
)
