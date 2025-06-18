// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Utility",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Utility",
      targets: ["Utility"]
    ),
  ],
  dependencies: [
    .package(path: "../NetworkClient"),
  ],
  targets: [
    .target(
      name: "Utility",
      dependencies: [
        .product(name: "NetworkClient", package: "NetworkClient"),
      ]
    ),
    .testTarget(
      name: "UtilityTests",
      dependencies: ["Utility"]
    ),
  ]
)
