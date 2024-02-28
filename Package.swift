// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KDC Parser",
    
    platforms: [
        .macOS(.v10_15),
        // Linux support is implied
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/RougeWare/Swift-Collection-Tools.git", from: "3.2.0"),
        .package(url: "https://github.com/palle-k/Covfefe.git", from: "0.6.0"),
        .package(url: "https://github.com/RougeWare/Swift-Simple-Logging", branch: "feature/New-LogChannel-Architecture"),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "kdc",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Covfefe",
                .product(name: "CollectionTools", package: "Swift-Collection-Tools"),
                .product(name: "SimpleLogging", package: "Swift-Simple-Logging"),
            ],
            resources: [Resource.embedInCode("known_domain_catalog.ebnf")]),
    ]
)
