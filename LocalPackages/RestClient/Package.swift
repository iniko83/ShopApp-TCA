// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RestClient",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "RestClient",
      targets: ["RestClient"]
    ),
  ],
  targets: [
    .target(name: "RestClient"),
  ]
)
