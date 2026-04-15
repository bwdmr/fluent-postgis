// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "fluent-postgis",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "FluentPostGIS", targets: ["FluentPostGIS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-configuration", from: "1.2.0"),
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.56.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.12.0"),
        .package(url: "https://github.com/bwdmr/WKCodable.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "FluentPostGIS",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "WKCodable", package: "WKCodable")
            ],
        ),
        .testTarget(
            name: "FluentPostGISTests",
            dependencies: [
                .target(name: "FluentPostGIS"),
                .product(name: "FluentBenchmark", package: "fluent-kit"),
            ],
        ),
    ]
)
