// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "fluent-postgis",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        // FluentPostgreSQL support for PostGIS
        .library(
            name: "FluentPostGIS",
            targets: ["FluentPostGIS"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),

        // Well Known Binary Encoding and Decoding
        .package(url: "https://github.com/rabc/WKCodable.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "FluentPostGIS",
            dependencies: [
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "WKCodable", package: "WKCodable"),
            ]
        ),
        .testTarget(
            name: "FluentPostGISTests",
            dependencies: [
                .target(name: "FluentPostGIS"),
                .product(name: "FluentBenchmark", package: "fluent-kit"),
            ]
        ),
    ]
)
