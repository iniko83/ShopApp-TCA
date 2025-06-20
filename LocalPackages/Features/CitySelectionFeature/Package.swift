// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CitySelectionFeature",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "CitySelectionFeature",
      targets: ["CitySelectionFeature"]
    ),
  ],
  dependencies: [
    .package(path: "../../LocationService"),
    .package(path: "../../NetworkClient"),
    .package(path: "../../NetworkConnectionService"),
    .package(path: "../../RestClient"),
    .package(path: "../../Utility"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "CitySelectionFeature",
      dependencies: [
        .product(name: "LocationService", package: "LocationService"),
        .product(name: "NetworkClient", package: "NetworkClient"),
        .product(name: "NetworkConnectionService", package: "NetworkConnectionService"),
        .product(name: "RestClient", package: "RestClient"),
        .product(name: "Utility", package: "Utility"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "CitySelectionFeatureTests",
      dependencies: ["CitySelectionFeature"]
    ),
  ]
)
