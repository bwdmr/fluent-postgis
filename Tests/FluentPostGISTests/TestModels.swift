import FluentKit
import FluentPostGIS

final class UserLocation: Model {
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

struct UserLocationMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserLocation.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("location", GeometricPoint2D.dataType)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserLocation.schema).delete()
    }
}

/// A model for testing `GeographicPoint2D`-related functionality
final class City: Model {
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

struct CityMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(City.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("location", GeographicPoint2D.dataType)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(City.schema).delete()
    }
}

final class UserPath: Model {
    static var schema: String = "user_path"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "path")
    var path: GeometricLineString2D

    init() {}

    init(path: GeometricLineString2D) {
        self.path = path
    }
}

struct UserPathMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserPath.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("path", GeometricLineString2D.dataType)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserPath.schema).delete()
    }
}

final class UserArea: Model {
    static var schema: String = "user_area"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "area")
    var area: GeometricPolygon2D

    init() {}

    init(area: GeometricPolygon2D) {
        self.area = area
    }
}

struct UserAreaMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserArea.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("area", GeometricPolygon2D.dataType)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserArea.schema).delete()
    }
}

final class UserCollection: Model {
    static var schema: String = "user_collection"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "collection")
    var collection: GeometricGeometryCollection2D

    init() {}

    init(collection: GeometricGeometryCollection2D) {
        self.collection = collection
    }
}

struct UserCollectionMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserCollection.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("collection", GeometricGeometryCollection2D.dataType)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserCollection.schema).delete()
    }
}
