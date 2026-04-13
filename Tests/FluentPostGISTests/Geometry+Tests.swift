@testable import FluentPostGIS
import FluentKit
import Testing

@Suite("Geometry Tests", .serialized)
struct GeometryTests {
    static let migrations: [any Migration] = [
        GeoUserLocationMigration(),
        GeoUserPathMigration(),
        GeoUserAreaMigration(),
        GeoUserCollectionMigration()
    ]

    @Test("point save, fetch and distance-within query")
    func point() async throws {
        try await withTestDatabase(suite: "GeometryTests", migrations: Self.migrations) { db in
            let point = GeometricPoint2D(x: 1, y: 2)

            let user = GeoUserLocation(location: point)
            try await user.save(on: db)

            let fetched = try await GeoUserLocation.find(1, on: db)
            #expect(fetched?.location == point)

            let all = try await GeoUserLocation.query(on: db)
                .filterGeometryDistanceWithin(\.$location, user.location, 1000)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("line string save and fetch")
    func lineString() async throws {
        try await withTestDatabase(suite: "GeometryTests", migrations: Self.migrations) { db in
            let point = GeometricPoint2D(x: 1, y: 2)
            let point2 = GeometricPoint2D(x: 2, y: 3)
            let point3 = GeometricPoint2D(x: 3, y: 2)
            let lineString = GeometricLineString2D(points: [point, point2, point3, point])

            let user = GeoUserPath(path: lineString)
            try await user.save(on: db)

            let fetched = try await GeoUserPath.find(1, on: db)
            #expect(fetched?.path == lineString)
        }
    }

    @Test("polygon with interior rings save and fetch")
    func polygon() async throws {
        try await withTestDatabase(suite: "GeometryTests", migrations: Self.migrations) { db in
            let point = GeometricPoint2D(x: 1, y: 2)
            let point2 = GeometricPoint2D(x: 2, y: 3)
            let point3 = GeometricPoint2D(x: 3, y: 2)
            let lineString = GeometricLineString2D(points: [point, point2, point3, point])
            let polygon = GeometricPolygon2D(
                exteriorRing: lineString,
                interiorRings: [lineString, lineString]
            )

            let user = GeoUserArea(area: polygon)
            try await user.save(on: db)

            let fetched = try await GeoUserArea.find(1, on: db)
            #expect(fetched?.area == polygon)
        }
    }

    @Test("geometry collection save and fetch")
    func geometryCollection() async throws {
        try await withTestDatabase(suite: "GeometryTests", migrations: Self.migrations) { db in
            let point = GeometricPoint2D(x: 1, y: 2)
            let point2 = GeometricPoint2D(x: 2, y: 3)
            let point3 = GeometricPoint2D(x: 3, y: 2)
            let lineString = GeometricLineString2D(points: [point, point2, point3, point])
            let polygon = GeometricPolygon2D(
                exteriorRing: lineString,
                interiorRings: [lineString, lineString]
            )
            let geometries: [any GeometryCollectable] = [point, point2, point3, lineString, polygon]
            let geometryCollection = GeometricGeometryCollection2D(geometries: geometries)

            let user = GeoUserCollection(collection: geometryCollection)
            try await user.save(on: db)

            let fetched = try await GeoUserCollection.find(1, on: db)
            #expect(fetched?.collection == geometryCollection)
        }
    }
}


final class GeoUserLocation: Model, @unchecked Sendable {
    static let schema = "geo_user_location"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "location")
    var location: GeometricPoint2D

    init() {}

    init(location: GeometricPoint2D) {
        self.location = location
    }
}

struct GeoUserLocationMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(GeoUserLocation.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("location", .geometricPoint2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GeoUserLocation.schema).delete()
    }
}


final class GeoUserPath: Model, @unchecked Sendable {
    static let schema: String = "geo_user_path"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "path")
    var path: GeometricLineString2D

    init() {}

    init(path: GeometricLineString2D) {
        self.path = path
    }
}

struct GeoUserPathMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(GeoUserPath.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("path", .geometricLineString2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GeoUserPath.schema).delete()
    }
}


final class GeoUserArea: Model, @unchecked Sendable {
    static let schema: String = "geo_user_area"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "area")
    var area: GeometricPolygon2D

    init() {}

    init(area: GeometricPolygon2D) {
        self.area = area
    }
}

struct GeoUserAreaMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(GeoUserArea.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("area", .geometricPolygon2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GeoUserArea.schema).delete()
    }
}

final class GeoUserCollection: Model, @unchecked Sendable {
    static let schema: String = "geo_user_collection"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "collection")
    var collection: GeometricGeometryCollection2D

    init() {}

    init(collection: GeometricGeometryCollection2D) {
        self.collection = collection
    }
}

struct GeoUserCollectionMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(GeoUserCollection.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("collection", .geometricGeometryCollection2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(GeoUserCollection.schema).delete()
    }
}
