// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "fluent-postgis",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "FluentPostGIS", targets: ["FluentPostGIS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.52.2"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.10.1"),
        .package(url: "https://github.com/rabc/WKCodable.git", from: "0.1.2"),
    ],
    targets: [
        .target(
            name: "FluentPostGIS",
            dependencies: [
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "WKCodable", package: "WKCodable"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FluentPostGISTests",
            dependencies: [
                .target(name: "FluentPostGIS"),
                .product(name: "FluentBenchmark", package: "fluent-kit"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("StrictConcurrency"),
    .enableExperimentalFeature("StrictConcurrency=complete"),
] }
