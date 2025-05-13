import FluentKit
import SQLKit

public struct EnablePostGISMigration: AsyncMigration, Sendable {
    public init() {}

    public enum EnablePostGISMigrationError: Error {
        case notSqlDatabase
    }

    public func prepare(on database: any Database) async throws {
        guard let db = database as? any SQLDatabase else {
            throw EnablePostGISMigrationError.notSqlDatabase
        }
        try await db.raw("CREATE EXTENSION IF NOT EXISTS \"postgis\"").run()
    }

    public func revert(on database: any Database) async throws {
        guard let db = database as? any SQLDatabase else {
            throw EnablePostGISMigrationError.notSqlDatabase
        }
        try await db.raw("DROP EXTENSION IF EXISTS \"postgis\"").run()
    }
}

public let FluentPostGISSrid: UInt = 4326
