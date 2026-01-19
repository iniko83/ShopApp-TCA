// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CityManager",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "CityManager",
      targets: ["CityManager"]
    ),
  ],
  dependencies: [
    .package(path: "../../Utility"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.9.2"),
  ],
  targets: [
    .target(
      name: "CityManager",
      dependencies: [
        .product(name: "Utility", package: "Utility"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
  ]
)
