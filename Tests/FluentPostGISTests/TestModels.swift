// Created on 05/05/2020

import Foundation
import FluentPostgresDriver
@testable import FluentPostGIS

final class UserLocation: Model {
    static let schema = "user_location"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    @Field(key: "location")
    var location: GeometricPoint2D
}

struct UserLocationMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserLocation.schema)
            .field("id", .int, .identifier(auto: true))
            .field("location", GeometricPoint2D.dataType)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserLocation.schema).delete()
    }
}

final class UserPath: Model {
    static var schema: String = "user_path"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    @Field(key: "path")
    var path: GeometricLineString2D
}
struct UserPathMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserPath.schema)
            .field("id", .int, .identifier(auto: true))
            .field("path", GeometricLineString2D.dataType)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserPath.schema).delete()
    }
}

final class UserArea: Model {
    static var schema: String = "user_area"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    @Field(key: "area")
    var area: GeometricPolygon2D
}
struct UserAreaMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserArea.schema)
            .field("id", .int, .identifier(auto: true))
            .field("area", GeometricPolygon2D.dataType)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserArea.schema).delete()
    }
}

final class UserCollection: Model {
    static var schema: String = "user_collection"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    @Field(key: "collection")
    var collection: GeometricGeometryCollection2D
}
struct UserCollectionMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserCollection.schema)
            .field("id", .int, .identifier(auto: true))
            .field("collection", GeometricGeometryCollection2D.dataType)
            .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserCollection.schema).delete()
    }
}
