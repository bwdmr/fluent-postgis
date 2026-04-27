@testable import FluentPostGIS
import FluentKit
import Testing

// MARK: - Test Models

/// A simple parent model with no geometry, used as the query root when testing
/// joined-model geometry filters.
final class Place: Model, @unchecked Sendable {
    static let schema = "place"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "user_area_id")
    var userAreaID: Int

    init() {}

    init(name: String, userAreaID: Int) {
        self.name = name
        self.userAreaID = userAreaID
    }
}

struct PlaceMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(Place.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("user_area_id", .int, .required)
            .foreignKey("user_area_id", references: UserArea.schema, .id)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Place.schema).delete()
    }
}

/// A simple parent model that joins to UserLocation.
final class Venue: Model, @unchecked Sendable {
    static let schema = "venue"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "user_location_id")
    var userLocationID: Int

    init() {}

    init(name: String, userLocationID: Int) {
        self.name = name
        self.userLocationID = userLocationID
    }
}

struct VenueMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(Venue.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("user_location_id", .int, .required)
            .foreignKey("user_location_id", references: UserLocation.schema, .id)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Venue.schema).delete()
    }
}

/// A simple parent model that joins to UserPath.
final class Trail: Model, @unchecked Sendable {
    static let schema = "trail"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "user_path_id")
    var userPathID: Int

    init() {}

    init(name: String, userPathID: Int) {
        self.name = name
        self.userPathID = userPathID
    }
}

struct TrailMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(Trail.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("user_path_id", .int, .required)
            .foreignKey("user_path_id", references: UserPath.schema, .id)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Trail.schema).delete()
    }
}

/// A simple parent model that joins to City (geography).
final class CityInfo: Model, @unchecked Sendable {
    static let schema = "city_info"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "label")
    var label: String

    @Field(key: "city_id")
    var cityID: Int

    init() {}

    init(label: String, cityID: Int) {
        self.label = label
        self.cityID = cityID
    }
}

struct CityInfoMigration: AsyncMigration, Sendable {
    func prepare(on database: any Database) async throws {
        try await database.schema(CityInfo.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("label", .string, .required)
            .field("city_id", .int, .required)
            .foreignKey("city_id", references: City.schema, .id)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(CityInfo.schema).delete()
    }
}

// MARK: - Tests

@Suite("Joined Query Tests", .serialized)
struct JoinedQueryTests {
    static let migrations: [any Migration] = [
        UserLocationMigration(),
        UserPathMigration(),
        UserAreaMigration(),
        CityMigration(),
        PlaceMigration(),
        VenueMigration(),
        TrailMigration(),
        CityInfoMigration(),
    ]

    // MARK: - Contains

    @Test("joined contains")
    func joinedContains() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let testPoint = GeometricPoint2D(x: 5, y: 5)
            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryContains(UserArea.self, \.$area, testPoint)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined contains reversed")
    func joinedContainsReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let testPoint = GeometricPoint2D(x: 5, y: 5)
            let userLocation = UserLocation(location: testPoint)
            try await userLocation.save(on: db)

            let venue = Venue(name: "Test Venue", userLocationID: userLocation.id!)
            try await venue.save(on: db)

            let all = try await Venue.query(on: db)
                .join(UserLocation.self, on: \Venue.$userLocationID == \UserLocation.$id)
                .filterGeometryContains(UserLocation.self, polygon, \.$location)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Crosses

    @Test("joined crosses")
    func joinedCrosses() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryCrosses(UserArea.self, \.$area, testPath)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined crosses reversed")
    func joinedCrossesReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryCrosses(UserPath.self, polygon, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Disjoint

    @Test("joined disjoint")
    func joinedDisjoint() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryDisjoint(UserArea.self, \.$area, testPath)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined disjoint reversed")
    func joinedDisjointReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryDisjoint(UserPath.self, polygon, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Equals

    @Test("joined equals")
    func joinedEquals() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryEquals(UserArea.self, \.$area, polygon)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Intersects

    @Test("joined intersects")
    func joinedIntersects() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryIntersects(UserArea.self, \.$area, testPath)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined intersects reversed")
    func joinedIntersectsReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryIntersects(UserPath.self, polygon, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Overlaps

    @Test("joined overlaps")
    func joinedOverlaps() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryOverlaps(UserPath.self, \.$path, testPath2)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined overlaps reversed")
    func joinedOverlapsReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryOverlaps(UserPath.self, testPath2, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Touches

    @Test("joined touches")
    func joinedTouches() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 1, y: 1),
                GeometricPoint2D(x: 0, y: 2),
            ])

            let testPoint = GeometricPoint2D(x: 0, y: 2)

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryTouches(UserPath.self, \.$path, testPoint)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined touches reversed")
    func joinedTouchesReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let testPath = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 1, y: 1),
                GeometricPoint2D(x: 0, y: 2),
            ])

            let testPoint = GeometricPoint2D(x: 0, y: 2)

            let userPath = UserPath(path: testPath)
            try await userPath.save(on: db)

            let trail = Trail(name: "Test Trail", userPathID: userPath.id!)
            try await trail.save(on: db)

            let all = try await Trail.query(on: db)
                .join(UserPath.self, on: \Trail.$userPathID == \UserPath.$id)
                .filterGeometryTouches(UserPath.self, testPoint, \.$path)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Within

    @Test("joined within")
    func joinedWithin() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userArea = UserArea(area: polygon2)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryWithin(UserArea.self, \.$area, polygon)
                .all()
            #expect(all.count == 1)
        }
    }

    @Test("joined within reversed")
    func joinedWithinReversed() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
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

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryWithin(UserArea.self, polygon2, \.$area)
                .all()
            #expect(all.count == 1)
        }
    }

    // MARK: - Distance Within (geography)

    @Test("joined distance within")
    func joinedDistanceWithin() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

            let potsdam = City(location: GeographicPoint2D(longitude: 13.06566, latitude: 52.39886))
            try await potsdam.save(on: db)

            let munich = City(location: GeographicPoint2D(longitude: 11.57549, latitude: 48.13743))
            try await munich.save(on: db)

            let info1 = CityInfo(label: "Near Berlin", cityID: potsdam.id!)
            try await info1.save(on: db)

            let info2 = CityInfo(label: "Far from Berlin", cityID: munich.id!)
            try await info2.save(on: db)

            let all = try await CityInfo.query(on: db)
                .join(City.self, on: \CityInfo.$cityID == \City.$id)
                .filterGeographyDistanceWithin(City.self, \.$location, berlin, 30 * 1000)
                .all()

            #expect(all.count == 1)
            #expect(all.first?.label == "Near Berlin")
        }
    }

    // MARK: - Sort by Distance

    @Test("joined sort by distance")
    func joinedSortByDistance() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let berlin = GeographicPoint2D(longitude: 13.41053, latitude: 52.52437)

            let hamburg = City(location: GeographicPoint2D(longitude: 10.01534, latitude: 53.57532))
            try await hamburg.save(on: db)

            let munich = City(location: GeographicPoint2D(longitude: 11.57549, latitude: 48.13743))
            try await munich.save(on: db)

            let potsdam = City(location: GeographicPoint2D(longitude: 13.06566, latitude: 52.39886))
            try await potsdam.save(on: db)

            let info1 = CityInfo(label: "Hamburg", cityID: hamburg.id!)
            try await info1.save(on: db)

            let info2 = CityInfo(label: "Munich", cityID: munich.id!)
            try await info2.save(on: db)

            let info3 = CityInfo(label: "Potsdam", cityID: potsdam.id!)
            try await info3.save(on: db)

            let all = try await CityInfo.query(on: db)
                .join(City.self, on: \CityInfo.$cityID == \City.$id)
                .sortByDistance(City.self, between: \.$location, berlin)
                .all()

            #expect(all.map(\.label) == ["Potsdam", "Hamburg", "Munich"])
        }
    }

    // MARK: - Equals

    @Test("joined equals no match")
    func joinedEqualsNoMatch() async throws {
        try await withTestDatabase(suite: "JoinedQueryTests", migrations: Self.migrations) { db in
            let exteriorRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 10, y: 0),
                GeometricPoint2D(x: 10, y: 10),
                GeometricPoint2D(x: 0, y: 10),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let polygon = GeometricPolygon2D(exteriorRing: exteriorRing)

            let userArea = UserArea(area: polygon)
            try await userArea.save(on: db)

            let place = Place(name: "Test Place", userAreaID: userArea.id!)
            try await place.save(on: db)

            // Different polygon — should not match
            let otherRing = GeometricLineString2D(points: [
                GeometricPoint2D(x: 0, y: 0),
                GeometricPoint2D(x: 5, y: 0),
                GeometricPoint2D(x: 5, y: 5),
                GeometricPoint2D(x: 0, y: 5),
                GeometricPoint2D(x: 0, y: 0),
            ])
            let otherPolygon = GeometricPolygon2D(exteriorRing: otherRing)

            let all = try await Place.query(on: db)
                .join(UserArea.self, on: \Place.$userAreaID == \UserArea.$id)
                .filterGeometryEquals(UserArea.self, \.$area, otherPolygon)
                .all()
            #expect(all.count == 0)
        }
    }
}
