// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LightwalletClientLib",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LightwalletClientLib",
            targets: ["LightwalletClientLib"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.20.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LightwalletClientLib",
            dependencies: [.product(name: "GRPC", package: "grpc-swift")]
        ),
        .testTarget(
            name: "LightwalletClientLibTests",
            dependencies: ["LightwalletClientLib"]
        ),
    ]
)
