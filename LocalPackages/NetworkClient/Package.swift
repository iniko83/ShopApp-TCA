// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NetworkClient",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "NetworkClient",
      targets: ["NetworkClient"]
    ),
  ],
  dependencies: [
    .package(path: "../RestClient"),
  ],
  targets: [
    .target(
      name: "NetworkClient",
      dependencies: [
        .product(name: "RestClient", package: "RestClient"),
      ]
    ),
  ]
)
