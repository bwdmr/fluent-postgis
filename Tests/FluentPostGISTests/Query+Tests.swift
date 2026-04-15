@testable import FluentPostGIS
import FluentKit
import Testing

@Suite("Query Tests", .serialized)
struct QueryTests {
    static let migrations: [any Migration] = [
        UserLocationMigration(),
        UserPathMigration(),
        UserAreaMigration(),
        CityMigration(),
    ]

    @Test("contains")
    func contains() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let testPoint = GeometricPoint2D(x: 5, y: 5)
            let all = try await UserArea.query(on: db)
                .filterGeometryContains(\.$area, testPoint)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("contains reversed")
    func containsReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPoint = GeometricPoint2D(x: 5, y: 5)
            let user = UserLocation(location: testPoint)
            try await user.save(on: db)

            let all = try await UserLocation.query(on: db)
                .filterGeometryContains(polygon, \.$location)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("contains with hole")
    func containsWithHole() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let hole = GeometricLineString2D(points: [
                GeometricPoint2D(x: 2.5, y: 2.5),
                GeometricPoint2D(x: 7.5, y: 2.5),
                GeometricPoint2D(x: 7.5, y: 7.5),
                GeometricPoint2D(x: 2.5, y: 7.5),
                GeometricPoint2D(x: 2.5, y: 2.5),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing, interiorRings: [hole])

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let testPoint = GeometricPoint2D(x: 5, y: 5)
            let all = try await UserArea.query(on: db)
                .filterGeometryContains(\.$area, testPoint)
                .all()
            #expect(all.count == 0)

            let testPoint2 = GeometricPoint2D(x: 1, y: 5)
            let all2 = try await UserArea.query(on: db)
                .filterGeometryContains(\.$area, testPoint2)
                .all()
            #expect(all2.count == 1)
        }
    }

    @Test("crosses")
    func crosses() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 5, y: 5),
            ])

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let all = try await UserArea.query(on: db)
                .filterGeometryCrosses(\.$area, testPath)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("crosses reversed")
    func crossesReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 5, y: 5),
            ])

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryCrosses(polygon, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("disjoint")
    func disjoint() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 11, y: 5),
            ])

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let all = try await UserArea.query(on: db)
                .filterGeometryDisjoint(\.$area, testPath)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("disjoint reversed")
    func disjointReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 11, y: 5),
            ])

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryDisjoint(polygon, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("equals")
    func equals() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let all = try await UserArea.query(on: db)
                .filterGeometryEquals(\.$area, polygon)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("intersects")
    func intersects() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 5, y: 5),
            ])

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let all = try await UserArea.query(on: db)
                .filterGeometryIntersects(\.$area, testPath)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("intersects reversed")
    func intersectsReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 5, y: 5),
            ])

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryIntersects(polygon, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("overlaps")
    func overlaps() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 5, y: 5),
                GeometricPoint2D(x: 6, y: 6),
                GeometricPoint2D(x: 0, y: 0),
            ])

            let testPath2 = GeometricLineString2D(points: [
                GeometricPoint2D(x: 16, y: 0),
                GeometricPoint2D(x: 5, y: 5),
                GeometricPoint2D(x: 6, y: 6),
                GeometricPoint2D(x: 2, y: 0),
            ])

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryOverlaps(\.$path, testPath2)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("overlaps reversed")
    func overlapsReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 15, y: 0),
                GeometricPoint2D(x: 5, y: 5),
                GeometricPoint2D(x: 6, y: 6),
                GeometricPoint2D(x: 0, y: 0),
            ])

            let testPath2 = GeometricLineString2D(points: [
                GeometricPoint2D(x: 16, y: 0),
                GeometricPoint2D(x: 5, y: 5),
                GeometricPoint2D(x: 6, y: 6),
                GeometricPoint2D(x: 2, y: 0),
            ])

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryOverlaps(testPath2, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("touches")
    func touches() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 1, y: 1),
                GeometricPoint2D(x: 0, y: 2),
            ])

            let testPoint = GeometricPoint2D(x: 0, y: 2)

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryTouches(\.$path, testPoint)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("touches reversed")
    func touchesReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 1, y: 1),
                GeometricPoint2D(x: 0, y: 2),
            ])

            let testPoint = GeometricPoint2D(x: 0, y: 2)

            let user = UserPath(path: testPath)
            try await user.save(on: db)

            let all = try await UserPath.query(on: db)
                .filterGeometryTouches(testPoint, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("within")
    func within() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
            let hole = GeometricLineString2D(points: [
                GeometricPoint2D(x: 2.5, y: 2.5),
                GeometricPoint2D(x: 7.5, y: 2.5),
                GeometricPoint2D(x: 7.5, y: 7.5),
                GeometricPoint2D(x: 2.5, y: 7.5),
                GeometricPoint2D(x: 2.5, y: 2.5),
            ])
            let polygon2 = GeometricPolygon2D(exteriorRing: hole)

            let user = UserArea(area: polygon2)
            try await user.save(on: db)

            let all = try await UserArea.query(on: db)
                .filterGeometryWithin(\.$area, polygon)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("within reversed")
    func withinReversed() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)
            let hole = GeometricLineString2D(points: [
                GeometricPoint2D(x: 2.5, y: 2.5),
                GeometricPoint2D(x: 7.5, y: 2.5),
                GeometricPoint2D(x: 7.5, y: 7.5),
                GeometricPoint2D(x: 2.5, y: 7.5),
                GeometricPoint2D(x: 2.5, y: 2.5),
            ])
            let polygon2 = GeometricPolygon2D(exteriorRing: hole)

            let user = UserArea(area: polygon)
            try await user.save(on: db)

            let all = try await UserArea.query(on: db)
                .filterGeometryWithin(polygon2, \.$area)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("distance within")
    func distanceWithin() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

            let hamburg = City(location: GeographicPoint2D(longitude: 10.01534, latitude: 53.57532))
            try await hamburg.save(on: db)

            let munich = City(location: GeographicPoint2D(longitude: 11.57549, latitude: 48.13743))
            try await munich.save(on: db)

            let potsdam = City(location: GeographicPoint2D(longitude: 13.06566, latitude: 52.39886))
            try await potsdam.save(on: db)

            let all = try await City.query(on: db)
                .filterGeographyDistanceWithin(\.$location, berlin, 30 * 1000)
                .all()

            #expect(all.map(\.id) == [potsdam].map(\.id))
        }
    }

    @Test("sort by distance")
    func sortByDistance() async throws {
        try await withTestDatabase(suite: "QueryTests", migrations: Self.migrations) { db in
            let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

            let hamburg = City(location: GeographicPoint2D(longitude: 10.01534, latitude: 53.57532))
            try await hamburg.save(on: db)

            let munich = City(location: GeographicPoint2D(longitude: 11.57549, latitude: 48.13743))
            try await munich.save(on: db)

            let potsdam = City(location: GeographicPoint2D(longitude: 13.06566, latitude: 52.39886))
            try await potsdam.save(on: db)

            let all = try await City.query(on: db)
                .sortByDistance(between: \.$location, berlin)
                .all()
            #expect(all.map(\.id) == [potsdam, hamburg, munich].map(\.id))
        }
    }
}


final class City: Model, @unchecked Sendable {
    static let schema = "city_location"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "location")
    var location: GeographicPoint2D

    init() {}

    init(location: GeographicPoint2D) {
        self.location = location
    }
}

struct CityMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(City.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("location", .geographicPoint2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(City.schema).delete()
    }
}

final class UserLocation: Model, @unchecked Sendable {
    static let schema = "user_location"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "location")
    var location: GeometricPoint2D

    init() {}

    init(location: GeometricPoint2D) {
        self.location = location
    }
}

struct UserLocationMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserLocation.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("location", .geometricPoint2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserLocation.schema).delete()
    }
}


final class UserPath: Model, @unchecked Sendable {
    static let schema: String = "user_path"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "path")
    var path: GeometricLineString2D

    init() {}

    init(path: GeometricLineString2D) {
        self.path = path
    }
}

struct UserPathMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserPath.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("path", .geometricLineString2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserPath.schema).delete()
    }
}


final class UserArea: Model, @unchecked Sendable {
    static let schema: String = "user_area"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "area")
    var area: GeometricPolygon2D

    init() {}

    init(area: GeometricPolygon2D) {
        self.area = area
    }
}

struct UserAreaMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserArea.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("area", .geometricPolygon2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserArea.schema).delete()
    }
}

final class UserCollection: Model, @unchecked Sendable {
    static let schema: String = "user_collection"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "collection")
    var collection: GeometricGeometryCollection2D

    init() {}

    init(collection: GeometricGeometryCollection2D) {
        self.collection = collection
    }
}

struct UserCollectionMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserCollection.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("collection", .geometricGeometryCollection2D)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserCollection.schema).delete()
    }
}
