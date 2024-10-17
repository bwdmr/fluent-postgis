// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "fluent-postgis",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library( name: "FluentPostGIS", targets: ["FluentPostGIS"] ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.49.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.10.0"),
        .package(url: "https://github.com/GEOSwift/GEOSwift.git", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "FluentPostGIS",
            dependencies: [
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "GEOSwift", package: "GEOSwift"),
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
